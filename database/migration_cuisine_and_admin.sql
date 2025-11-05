-- ============================================
-- Migration: Add cuisine_type to recipes and role to users
-- Date: 2025-11-04
-- ============================================

-- 1. Add cuisine_type column to recipes table
ALTER TABLE public.recipes 
ADD COLUMN IF NOT EXISTS cuisine_type TEXT DEFAULT 'Indonesian';

-- Add index for better search performance
CREATE INDEX IF NOT EXISTS idx_recipes_cuisine_type ON public.recipes(cuisine_type);

-- 2. Add role column to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin'));

-- Create index for role
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- ============================================
-- 3. CREATE ACTIVITY_LOGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for activity_logs
-- Drop existing policies first to avoid conflicts
DROP POLICY IF EXISTS "Admins can view all activity logs" ON public.activity_logs;
DROP POLICY IF EXISTS "Users can view their own activity logs" ON public.activity_logs;
DROP POLICY IF EXISTS "System can insert activity logs" ON public.activity_logs;

-- Create policies
CREATE POLICY "Admins can view all activity logs"
  ON public.activity_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Users can view their own activity logs"
  ON public.activity_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "System can insert activity logs"
  ON public.activity_logs FOR INSERT
  WITH CHECK (true);

-- Indexes for activity_logs
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_action ON public.activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON public.activity_logs(created_at DESC);

-- ============================================
-- 4. FUNCTION: Log Activity
-- ============================================
CREATE OR REPLACE FUNCTION public.log_activity(
  p_user_id UUID,
  p_action TEXT,
  p_description TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO public.activity_logs (user_id, action, description, metadata)
  VALUES (p_user_id, p_action, p_description, p_metadata)
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. TRIGGER: Auto log recipe actions
-- ============================================
CREATE OR REPLACE FUNCTION public.log_recipe_activity()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(
      NEW.user_id,
      'create_recipe',
      'Created recipe: ' || NEW.title,
      jsonb_build_object('recipe_id', NEW.id, 'title', NEW.title)
    );
  ELSIF TG_OP = 'UPDATE' THEN
    PERFORM public.log_activity(
      NEW.user_id,
      'update_recipe',
      'Updated recipe: ' || NEW.title,
      jsonb_build_object('recipe_id', NEW.id, 'title', NEW.title)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM public.log_activity(
      OLD.user_id,
      'delete_recipe',
      'Deleted recipe: ' || OLD.title,
      jsonb_build_object('recipe_id', OLD.id, 'title', OLD.title)
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_log_recipe_activity ON public.recipes;
CREATE TRIGGER trigger_log_recipe_activity
  AFTER INSERT OR UPDATE OR DELETE ON public.recipes
  FOR EACH ROW EXECUTE FUNCTION public.log_recipe_activity();

-- ============================================
-- 6. TRIGGER: Auto log rating actions
-- ============================================
CREATE OR REPLACE FUNCTION public.log_rating_activity()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(
      NEW.user_id,
      'add_rating',
      'Added rating to recipe',
      jsonb_build_object('recipe_id', NEW.recipe_id, 'rating', NEW.rating)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_log_rating_activity ON public.ratings;
CREATE TRIGGER trigger_log_rating_activity
  AFTER INSERT ON public.ratings
  FOR EACH ROW EXECUTE FUNCTION public.log_rating_activity();

-- ============================================
-- 7. TRIGGER: Auto log favorite actions
-- ============================================
CREATE OR REPLACE FUNCTION public.log_favorite_activity()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_activity(
      NEW.user_id,
      'add_favorite',
      'Added recipe to favorites',
      jsonb_build_object('recipe_id', NEW.recipe_id)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM public.log_activity(
      OLD.user_id,
      'remove_favorite',
      'Removed recipe from favorites',
      jsonb_build_object('recipe_id', OLD.recipe_id)
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_log_favorite_activity ON public.favorites;
CREATE TRIGGER trigger_log_favorite_activity
  AFTER INSERT OR DELETE ON public.favorites
  FOR EACH ROW EXECUTE FUNCTION public.log_favorite_activity();

-- ============================================
-- 8. UPDATE EXISTING RECIPES VIEW
-- ============================================
-- Recreate the view to include cuisine_type
-- Use CASCADE to drop dependent objects (functions will be recreated automatically)
DROP VIEW IF EXISTS public.recipes_with_stats CASCADE;

CREATE VIEW public.recipes_with_stats AS
SELECT 
  r.*,
  u.display_name as user_name,
  u.photo_url as user_avatar,
  COALESCE(AVG(rt.rating), 0) as avg_rating,
  COUNT(DISTINCT rt.id) as rating_count,
  COUNT(DISTINCT f.id) as favorite_count,
  ARRAY_AGG(DISTINCT rt.rating) FILTER (WHERE rt.rating IS NOT NULL) as ratings,
  ARRAY_AGG(DISTINCT rt.review) FILTER (WHERE rt.review IS NOT NULL) as reviews,
  ARRAY_AGG(DISTINCT f.user_id) FILTER (WHERE f.user_id IS NOT NULL) as favorites
FROM public.recipes r
LEFT JOIN public.users u ON r.user_id = u.id
LEFT JOIN public.ratings rt ON r.id = rt.recipe_id
LEFT JOIN public.favorites f ON r.id = f.recipe_id
GROUP BY r.id, u.display_name, u.photo_url;

-- ============================================
-- 8b. RECREATE DEPENDENT FUNCTIONS
-- ============================================
-- Recreate get_user_favorites function
CREATE OR REPLACE FUNCTION public.get_user_favorites(p_user_id UUID)
RETURNS SETOF public.recipes_with_stats AS $$
BEGIN
  RETURN QUERY
  SELECT r.*
  FROM public.recipes_with_stats r
  INNER JOIN public.favorites f ON r.id = f.recipe_id
  WHERE f.user_id = p_user_id
  ORDER BY f.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate search_recipes function
CREATE OR REPLACE FUNCTION public.search_recipes(search_query TEXT DEFAULT NULL)
RETURNS SETOF public.recipes_with_stats AS $$
BEGIN
  IF search_query IS NULL OR search_query = '' THEN
    RETURN QUERY
    SELECT * FROM public.recipes_with_stats
    ORDER BY created_at DESC;
  ELSE
    RETURN QUERY
    SELECT * FROM public.recipes_with_stats
    WHERE 
      title ILIKE '%' || search_query || '%' OR
      description ILIKE '%' || search_query || '%' OR
      ingredients ILIKE '%' || search_query || '%' OR
      category ILIKE '%' || search_query || '%' OR
      cuisine_type ILIKE '%' || search_query || '%'
    ORDER BY created_at DESC;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 9. UPDATE EXISTING DATA (if any)
-- ============================================
-- Set default cuisine_type for existing recipes based on category
UPDATE public.recipes 
SET cuisine_type = 'Indonesian'
WHERE cuisine_type IS NULL;

-- ============================================
-- 10. ADMIN USER SETUP (OPTIONAL)
-- ============================================
-- To make a user admin, run this query with the user's ID:
UPDATE public.users SET role = 'admin' WHERE email = 'farhansik13@gmail.com';

-- Example: Make demo user an admin
UPDATE public.users SET role = 'admin' WHERE email = 'demo@masakini.com';

-- ============================================
-- MIGRATION COMPLETE
-- ============================================
-- New features:
-- ✅ cuisine_type field in recipes (Indonesian, Western, Chinese, etc)
-- ✅ role field in users (user, admin)
-- ✅ activity_logs table for tracking user activities
-- ✅ Auto-logging triggers for recipes, ratings, and favorites
-- ✅ Updated recipes_with_stats view
-- ✅ Admin RLS policies
