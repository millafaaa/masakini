// Script untuk menambahkan data sample resep dengan kategori lengkap
// Jalankan dengan: node add_more_recipes.js
// Catatan: membutuhkan Node.js >= 18 dan package "firebase" v12+

import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, Timestamp, connectFirestoreEmulator } from 'firebase/firestore';

// Konfigurasi Firebase
const firebaseConfig = {
  projectId: "masakini-ba32a"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Connect ke Firestore Emulator
connectFirestoreEmulator(db, 'localhost', 8081);

// Sample recipes dengan kategori lengkap
const sampleRecipes = [
  // === INDONESIAN ===
  {
    title: "Nasi Goreng Spesial",
    description: "Nasi goreng dengan bumbu rahasia yang lezat dan gurih",
    ingredients: ["2 piring nasi putih", "2 butir telur", "3 siung bawang putih", "5 siung bawang merah", "2 sdm kecap manis", "1 sdt garam", "Cabai sesuai selera", "Daun bawang"],
    steps: ["Tumis bawang putih dan bawang merah hingga harum", "Masukkan telur, orak-arik sebentar", "Tambahkan nasi putih, aduk rata", "Beri kecap manis dan garam", "Masak hingga matang dan harum", "Taburi daun bawang, sajikan dengan kerupuk"],
    image: "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500",
    userId: "sample-user", userName: "Chef Budi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Budi&background=FF6B9D&color=fff",
    category: "Indonesian", cookingTime: 30, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 4.5, 5], reviews: []
  },
  {
    title: "Rendang Daging Sapi",
    description: "Rendang khas Padang yang empuk, gurih, dan kaya rempah",
    ingredients: ["500g daging sapi", "400ml santan kental", "5 lembar daun jeruk", "2 batang serai", "3 lembar daun kunyit", "Bumbu halus: bawang merah, bawang putih, cabai, lengkuas, kunyit, jahe"],
    steps: ["Tumis bumbu halus hingga harum", "Masukkan daging, aduk rata", "Tuang santan, tambahkan daun jeruk dan serai", "Masak api kecil 2-3 jam", "Aduk sesekali", "Masak hingga kuah mengering"],
    image: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500",
    userId: "sample-user", userName: "Chef Siti", userAvatar: "https://ui-avatars.com/api/?name=Chef+Siti&background=FF9A56&color=fff",
    category: "Indonesian", cookingTime: 180, servings: 4, difficulty: "hard",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 5, 4.5, 5], reviews: []
  },
  {
    title: "Soto Ayam Kuning",
    description: "Soto ayam dengan kuah kuning yang segar dan harum rempah",
    ingredients: ["500g ayam kampung", "2 liter air", "100g tauge", "2 batang seledri", "3 lembar daun jeruk", "Bumbu halus: kunyit, jahe, kemiri"],
    steps: ["Rebus ayam hingga empuk, suwir", "Tumis bumbu halus", "Masukkan ke kaldu ayam", "Tambahkan serai dan daun jeruk", "Masak hingga mendidih", "Sajikan dengan nasi dan sambal"],
    image: "https://images.unsplash.com/photo-1604908816519-b04bc1813e15?w=500",
    userId: "sample-user", userName: "Chef Budi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Budi&background=FF6B9D&color=fff",
    category: "Indonesian", cookingTime: 60, servings: 4, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.5, 5, 4], reviews: []
  },
  {
    title: "Gado-Gado Jakarta",
    description: "Salad sayuran dengan bumbu kacang kental yang nikmat",
    ingredients: ["Kol, kangkung, tauge, wortel rebus", "Kentang rebus", "Telur rebus", "Tempe goreng", "Tahu goreng", "200g kacang tanah sangrai", "Gula merah, kecap manis"],
    steps: ["Sangrai kacang tanah", "Haluskan kacang dengan cabai dan gula merah", "Tambahkan air hingga kental", "Tata sayuran di piring", "Siram dengan bumbu kacang", "Taburi bawang goreng"],
    image: "https://images.unsplash.com/photo-1562158147-f8a58040ede2?w=500",
    userId: "sample-user", userName: "Chef Siti", userAvatar: "https://ui-avatars.com/api/?name=Chef+Siti&background=FF9A56&color=fff",
    category: "Indonesian", cookingTime: 45, servings: 3, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.5, 4.5, 5], reviews: []
  },
  {
    title: "Sate Ayam Madura",
    description: "Sate ayam dengan bumbu kacang khas Madura yang gurih manis",
    ingredients: ["500g daging ayam potong dadu", "Bumbu marinasi: bawang putih, ketumbar, kecap manis", "200g kacang tanah", "5 cabai rawit", "Air asam jawa", "Tusuk sate"],
    steps: ["Marinasi ayam 1 jam", "Tusuk ayam ke tusukan sate", "Bakar sambil diolesi kecap", "Haluskan kacang dengan cabai", "Tambahkan kecap dan asam jawa", "Sajikan dengan lontong"],
    image: "https://images.unsplash.com/photo-1529563021893-cc83c992d75d?w=500",
    userId: "sample-user", userName: "Chef Budi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Budi&background=FF6B9D&color=fff",
    category: "Indonesian", cookingTime: 50, servings: 4, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 4.5, 5, 5], reviews: []
  },

  // === WESTERN ===
  {
    title: "Spaghetti Carbonara",
    description: "Pasta Italia dengan saus krim yang creamy dan bacon crispy",
    ingredients: ["200g spaghetti", "100g bacon", "2 butir telur", "50g keju parmesan", "2 siung bawang putih", "Merica hitam", "Garam"],
    steps: ["Rebus spaghetti al dente", "Tumis bacon dan bawang putih hingga crispy", "Kocok telur dengan keju parmesan", "Campurkan spaghetti dengan bacon", "Matikan api, tuang campuran telur", "Aduk cepat, taburi merica hitam"],
    image: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=500",
    userId: "sample-user", userName: "Chef Mario", userAvatar: "https://ui-avatars.com/api/?name=Chef+Mario&background=4CAF50&color=fff",
    category: "Western", cookingTime: 25, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.8, 5, 4.5], reviews: []
  },
  {
    title: "Beef Steak with Mushroom Sauce",
    description: "Daging sapi panggang dengan saus jamur yang lezat",
    ingredients: ["300g daging sapi sirloin", "200g jamur kancing", "2 sdm butter", "1 cup cream", "Bawang putih", "Rosemary", "Garam, merica"],
    steps: ["Marinasi daging dengan garam, merica, rosemary", "Panggang daging di grill pan hingga medium", "Tumis bawang putih dan jamur", "Tambahkan cream, masak hingga mengental", "Sajikan steak dengan saus jamur"],
    image: "https://images.unsplash.com/photo-1600891964092-4316c288032e?w=500",
    userId: "sample-user", userName: "Chef Mario", userAvatar: "https://ui-avatars.com/api/?name=Chef+Mario&background=4CAF50&color=fff",
    category: "Western", cookingTime: 40, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 5, 4.8], reviews: []
  },
  {
    title: "Caesar Salad",
    description: "Salad segar dengan dressing Caesar yang creamy",
    ingredients: ["Selada romaine", "Crouton", "Keju parmesan", "Ayam panggang", "Dressing: mayones, mustard, lemon juice, bawang putih, anchovy"],
    steps: ["Cuci dan potong selada", "Buat dressing dengan blender semua bahan", "Panggang ayam, potong dadu", "Campur selada dengan dressing", "Tambahkan crouton, ayam, dan keju parmesan"],
    image: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500",
    userId: "sample-user", userName: "Chef Mario", userAvatar: "https://ui-avatars.com/api/?name=Chef+Mario&background=4CAF50&color=fff",
    category: "Western", cookingTime: 20, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.5, 4, 4.5], reviews: []
  },

  // === CHINESE ===
  {
    title: "Mapo Tofu",
    description: "Tahu pedas khas Sichuan dengan daging cincang",
    ingredients: ["400g tahu sutra", "200g daging sapi cincang", "2 sdm doubanjiang", "Sichuan pepper", "Bawang putih, jahe", "Daun bawang", "Kaldu ayam"],
    steps: ["Potong tahu kotak kecil, rebus sebentar", "Tumis daging cincang hingga berubah warna", "Tambahkan doubanjiang, bawang putih, jahe", "Masukkan tahu dan kaldu", "Tambahkan sichuan pepper", "Taburi daun bawang, sajikan"],
    image: "https://images.unsplash.com/photo-1633964913295-ceb43826ab80?w=500",
    userId: "sample-user", userName: "Chef Li", userAvatar: "https://ui-avatars.com/api/?name=Chef+Li&background=F44336&color=fff",
    category: "Chinese", cookingTime: 30, servings: 3, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.8, 5, 4.5], reviews: []
  },
  {
    title: "Kung Pao Chicken",
    description: "Ayam tumis pedas dengan kacang mete ala Sichuan",
    ingredients: ["400g daging ayam potong dadu", "100g kacang mete sangrai", "5 cabai kering", "2 sdm kecap asin", "1 sdm cuka beras", "1 sdm gula", "Bawang putih, jahe"],
    steps: ["Marinasi ayam dengan kecap dan tepung maizena", "Tumis cabai kering hingga harum", "Masukkan ayam, masak hingga matang", "Tambahkan saus (kecap, cuka, gula)", "Masukkan kacang mete", "Aduk rata, sajikan"],
    image: "https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=500",
    userId: "sample-user", userName: "Chef Li", userAvatar: "https://ui-avatars.com/api/?name=Chef+Li&background=F44336&color=fff",
    category: "Chinese", cookingTime: 35, servings: 3, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 4.5, 5], reviews: []
  },

  // === JAPANESE ===
  {
    title: "Ramen Shoyu",
    description: "Mie ramen dengan kuah shoyu yang gurih dan hangat",
    ingredients: ["200g mie ramen", "1 liter kaldu ayam", "3 sdm kecap asin Jepang", "2 sdm mirin", "Telur rebus setengah matang", "Chashu pork", "Daun bawang, nori"],
    steps: ["Rebus kaldu ayam hingga mendidih", "Tambahkan kecap asin dan mirin", "Rebus mie ramen terpisah", "Masukkan mie ke mangkuk", "Tuang kuah panas", "Tambahkan chashu, telur, daun bawang, dan nori"],
    image: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500",
    userId: "sample-user", userName: "Chef Tanaka", userAvatar: "https://ui-avatars.com/api/?name=Chef+Tanaka&background=2196F3&color=fff",
    category: "Japanese", cookingTime: 45, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 5, 4.8], reviews: []
  },
  {
    title: "Chicken Katsu Curry",
    description: "Ayam goreng tepung dengan kuah kari Jepang yang kental",
    ingredients: ["2 potong dada ayam", "Tepung panir", "Telur", "Tepung terigu", "Bumbu kari Jepang (roux)", "Kentang, wortel, bawang bombay", "Nasi putih"],
    steps: ["Potong ayam, pipihkan", "Lumuri tepung, telur, tepung panir", "Goreng hingga golden brown", "Tumis bawang bombay, wortel, kentang", "Tambahkan air, masukkan roux kari", "Masak hingga mengental", "Sajikan ayam dengan kari dan nasi"],
    image: "https://images.unsplash.com/photo-1633964913267-320de3bd6f2c?w=500",
    userId: "sample-user", userName: "Chef Tanaka", userAvatar: "https://ui-avatars.com/api/?name=Chef+Tanaka&background=2196F3&color=fff",
    category: "Japanese", cookingTime: 50, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.8, 5, 4.5], reviews: []
  },

  // === KOREAN ===
  {
    title: "Bibimbap",
    description: "Nasi campur Korea dengan sayuran dan telur mata sapi",
    ingredients: ["2 mangkuk nasi putih", "100g daging sapi iris tipis", "Bayam, wortel, tauge, jamur", "2 butir telur", "Gochujang (pasta cabai Korea)", "Minyak wijen", "Bawang putih"],
    steps: ["Tumis daging dengan bawang putih dan kecap", "Rebus sayuran terpisah, beri sedikit garam", "Goreng telur mata sapi", "Tata nasi di mangkuk", "Susun daging dan sayuran di atas nasi", "Taruh telur di tengah", "Beri gochujang dan minyak wijen"],
    image: "https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500",
    userId: "sample-user", userName: "Chef Kim", userAvatar: "https://ui-avatars.com/api/?name=Chef+Kim&background=FFC107&color=000",
    category: "Korean", cookingTime: 40, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 4.5, 5], reviews: []
  },
  {
    title: "Korean Fried Chicken",
    description: "Ayam goreng Korea dengan saus gochujang yang pedas manis",
    ingredients: ["500g sayap ayam", "Tepung terigu", "Tepung maizena", "Gochujang", "Gochugaru (bubuk cabai Korea)", "Madu", "Kecap asin", "Bawang putih", "Jahe", "Wijen"],
    steps: ["Marinasi ayam dengan garam dan merica", "Balut dengan campuran tepung", "Goreng hingga crispy", "Buat saus: campur gochujang, madu, kecap, bawang putih", "Tumis saus hingga mendidih", "Masukkan ayam goreng, aduk rata", "Taburi wijen dan daun bawang"],
    image: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500",
    userId: "sample-user", userName: "Chef Kim", userAvatar: "https://ui-avatars.com/api/?name=Chef+Kim&background=FFC107&color=000",
    category: "Korean", cookingTime: 50, servings: 3, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 5, 4.8, 5], reviews: []
  },

  // === DESSERT ===
  {
    title: "Tiramisu Classic",
    description: "Dessert Italia dengan perpaduan kopi dan mascarpone cheese",
    ingredients: ["200g ladyfinger biscuits", "250g mascarpone cheese", "3 butir telur (pisahkan kuning dan putih)", "100g gula", "1 cup espresso kopi", "2 sdm rum (opsional)", "Bubuk coklat"],
    steps: ["Kocok kuning telur dengan gula hingga pucat", "Tambahkan mascarpone, aduk rata", "Kocok putih telur hingga kaku", "Campurkan putih telur ke adonan mascarpone", "Celup ladyfinger ke espresso", "Susun ladyfinger di wadah", "Tuang cream, ulangi layer", "Taburi bubuk coklat, dinginkan 4 jam"],
    image: "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=500",
    userId: "sample-user", userName: "Chef Mario", userAvatar: "https://ui-avatars.com/api/?name=Chef+Mario&background=4CAF50&color=fff",
    category: "Dessert", cookingTime: 30, servings: 6, difficulty: "medium",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 5, 4.8], reviews: []
  },
  {
    title: "Brownies Fudgy",
    description: "Brownies coklat yang lembut dan fudgy di tengah",
    ingredients: ["200g dark chocolate", "150g butter", "3 butir telur", "150g gula", "100g tepung terigu", "30g coklat bubuk", "1 sdt vanilla extract"],
    steps: ["Lelehkan chocolate dan butter", "Kocok telur dan gula hingga mengembang", "Masukkan coklat leleh, aduk rata", "Tambahkan tepung, coklat bubuk, vanilla", "Tuang ke loyang yang sudah diolesi margarin", "Panggang 180°C selama 25-30 menit", "Jangan over-bake agar tetap fudgy"],
    image: "https://images.unsplash.com/photo-1607920591413-4ec007e70023?w=500",
    userId: "sample-user", userName: "Chef Siti", userAvatar: "https://ui-avatars.com/api/?name=Chef+Siti&background=FF9A56&color=fff",
    category: "Dessert", cookingTime: 45, servings: 8, difficulty: "easy",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 4.5, 5, 5], reviews: []
  },

  // === MINUMAN ===
  {
    title: "Es Teh Tarik",
    description: "Minuman teh manis yang di-tarik dengan susu kental manis",
    ingredients: ["2 kantong teh celup", "3 sdm gula pasir", "2 sdm susu kental manis", "Es batu", "Air panas 200ml"],
    steps: ["Seduh teh dengan air panas", "Tambahkan gula, aduk rata", "Tuang teh ke gelas lain dari ketinggian (tarik)", "Ulangi 5-7 kali hingga berbusa", "Tambahkan susu kental manis", "Tuang ke gelas berisi es batu"],
    image: "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500",
    userId: "sample-user", userName: "Chef Budi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Budi&background=FF6B9D&color=fff",
    category: "Minuman", cookingTime: 10, servings: 1, difficulty: "easy",
    createdAt: Timestamp.now(), favorites: [], ratings: [4.5, 5, 4], reviews: []
  },
  {
    title: "Smoothie Bowl Mangga",
    description: "Smoothie mangga yang thick dan creamy untuk sarapan sehat",
    ingredients: ["2 buah mangga beku", "1 pisang beku", "100ml yogurt plain", "2 sdm madu", "Topping: granola, chia seeds, buah segar"],
    steps: ["Blender mangga, pisang, yogurt, madu hingga smooth", "Tuang ke mangkuk", "Hias dengan topping granola, chia seeds", "Tambahkan potongan buah segar", "Sajikan segera"],
    image: "https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500",
    userId: "sample-user", userName: "Chef Siti", userAvatar: "https://ui-avatars.com/api/?name=Chef+Siti&background=FF9A56&color=fff",
    category: "Minuman", cookingTime: 10, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favorites: [], ratings: [5, 4.5, 5], reviews: []
  }
];

async function addSampleData() {
  try {
    console.log('🔥 Menambahkan 20 sample recipes ke Firestore Emulator...\n');
    
    for (const recipe of sampleRecipes) {
      const docRef = await addDoc(collection(db, 'recipes'), recipe);
      console.log(`✅ ${recipe.title} (${recipe.category}) - ID: ${docRef.id}`);
    }
    
    console.log('\n🎉 Semua 20 sample recipes berhasil ditambahkan!');
    console.log('📱 Coba refresh aplikasi Flutter Anda.');
    console.log('🌐 Cek di Emulator UI: http://localhost:4000/firestore');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

addSampleData();
