-- ============================================
-- Masakini Database Schema for Supabase
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE (linked to auth.users)
-- ============================================
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can view their own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. RECIPES TABLE
-- ============================================
CREATE TABLE public.recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  category TEXT DEFAULT 'Lainnya',
  cooking_time INTEGER DEFAULT 30, -- in minutes
  servings INTEGER DEFAULT 2,
  difficulty TEXT DEFAULT 'easy', -- easy, medium, hard
  ingredients TEXT[] NOT NULL DEFAULT '{}',
  steps TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recipes
CREATE POLICY "Anyone can view recipes"
  ON public.recipes FOR SELECT
  USING (true);

CREATE POLICY "Users can create their own recipes"
  ON public.recipes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own recipes"
  ON public.recipes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own recipes"
  ON public.recipes FOR DELETE
  USING (auth.uid() = user_id);

-- Indexes for better performance
CREATE INDEX idx_recipes_user_id ON public.recipes(user_id);
CREATE INDEX idx_recipes_category ON public.recipes(category);
CREATE INDEX idx_recipes_created_at ON public.recipes(created_at DESC);
CREATE INDEX idx_recipes_title ON public.recipes USING GIN(to_tsvector('indonesian', title));

-- ============================================
-- 3. RATINGS TABLE
-- ============================================
CREATE TABLE public.ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  rating NUMERIC(2,1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
  review TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(recipe_id, user_id) -- One rating per user per recipe
);

-- Enable Row Level Security
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for ratings
CREATE POLICY "Anyone can view ratings"
  ON public.ratings FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create ratings"
  ON public.ratings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own ratings"
  ON public.ratings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own ratings"
  ON public.ratings FOR DELETE
  USING (auth.uid() = user_id);

-- Indexes for better performance
CREATE INDEX idx_ratings_recipe_id ON public.ratings(recipe_id);
CREATE INDEX idx_ratings_user_id ON public.ratings(user_id);

-- ============================================
-- 4. FAVORITES TABLE
-- ============================================
CREATE TABLE public.favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(recipe_id, user_id) -- One favorite per user per recipe
);

-- Enable Row Level Security
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- RLS Policies for favorites
CREATE POLICY "Users can view their own favorites"
  ON public.favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can add favorites"
  ON public.favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their own favorites"
  ON public.favorites FOR DELETE
  USING (auth.uid() = user_id);

-- Indexes for better performance
CREATE INDEX idx_favorites_recipe_id ON public.favorites(recipe_id);
CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);

-- ============================================
-- 5. VIEWS FOR EASY QUERIES
-- ============================================

-- View: Recipes with user info, rating stats, and favorite count
CREATE OR REPLACE VIEW recipes_with_stats AS
SELECT 
  r.*,
  u.display_name as user_name,
  u.photo_url as user_avatar,
  COALESCE(AVG(rat.rating), 0) as average_rating,
  COUNT(DISTINCT rat.id) as rating_count,
  COUNT(DISTINCT f.id) as favorite_count,
  ARRAY_AGG(DISTINCT rat.rating) FILTER (WHERE rat.rating IS NOT NULL) as ratings,
  ARRAY_AGG(DISTINCT rat.review) FILTER (WHERE rat.review IS NOT NULL) as reviews
FROM 
  public.recipes r
LEFT JOIN 
  public.users u ON r.user_id = u.id
LEFT JOIN 
  public.ratings rat ON r.id = rat.recipe_id
LEFT JOIN 
  public.favorites f ON r.id = f.recipe_id
GROUP BY 
  r.id, u.display_name, u.photo_url;

-- ============================================
-- 6. FUNCTIONS FOR COMMON OPERATIONS
-- ============================================

-- Function: Toggle favorite
CREATE OR REPLACE FUNCTION toggle_favorite(recipe_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
  favorite_exists BOOLEAN;
BEGIN
  -- Check if favorite exists
  SELECT EXISTS(
    SELECT 1 FROM public.favorites 
    WHERE recipe_id = recipe_uuid AND user_id = user_uuid
  ) INTO favorite_exists;
  
  IF favorite_exists THEN
    -- Remove favorite
    DELETE FROM public.favorites 
    WHERE recipe_id = recipe_uuid AND user_id = user_uuid;
    RETURN FALSE;
  ELSE
    -- Add favorite
    INSERT INTO public.favorites (recipe_id, user_id) 
    VALUES (recipe_uuid, user_uuid);
    RETURN TRUE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get user's favorited recipes
CREATE OR REPLACE FUNCTION get_user_favorites(user_uuid UUID)
RETURNS SETOF recipes_with_stats AS $$
BEGIN
  RETURN QUERY
  SELECT rws.*
  FROM recipes_with_stats rws
  INNER JOIN public.favorites f ON rws.id = f.recipe_id
  WHERE f.user_id = user_uuid
  ORDER BY f.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Search recipes by title or ingredients
CREATE OR REPLACE FUNCTION search_recipes(search_query TEXT)
RETURNS SETOF recipes_with_stats AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM recipes_with_stats
  WHERE 
    title ILIKE '%' || search_query || '%' OR
    EXISTS (
      SELECT 1 
      FROM unnest(ingredients) AS ingredient 
      WHERE ingredient ILIKE '%' || search_query || '%'
    )
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7. TRIGGERS FOR AUTO UPDATE
-- ============================================

-- Trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to users table
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to recipes table
CREATE TRIGGER update_recipes_updated_at
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. STORAGE BUCKETS (Run in Supabase Dashboard or SQL Editor)
-- ============================================
-- Note: Storage buckets are typically created via Supabase Dashboard
-- or using Supabase Management API, but here's the SQL equivalent:

/*
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('recipes', 'recipes', true),
  ('profiles', 'profiles', true);

-- Storage RLS Policies
CREATE POLICY "Anyone can view recipe images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'recipes');

CREATE POLICY "Authenticated users can upload recipe images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'recipes' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update their own recipe images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'recipes' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own recipe images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'recipes' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Anyone can view profile images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profiles');

CREATE POLICY "Users can upload their own profile image"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own profile image"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own profile image"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1]);
*/

-- ============================================
-- SETUP COMPLETE!
-- ============================================
-- Next steps:
-- 1. Run this schema in your Supabase SQL Editor
-- 2. Create storage buckets 'recipes' and 'profiles' in Supabase Dashboard
-- 3. Update your .env file with SUPABASE_URL and SUPABASE_ANON_KEY
-- 4. Run `flutter pub get` to install dependencies
-- ============================================
