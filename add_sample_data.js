// Script untuk menambahkan data sample ke Firebase Emulator
// Jalankan dengan: node add_sample_data.js

const { initializeApp } = require('firebase/app');
const { getFirestore, collection, addDoc, Timestamp } = require('firebase/firestore');

// Konfigurasi Firebase (gunakan emulator)
const firebaseConfig = {
  projectId: "masakini-ba32a"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Connect ke Firestore Emulator
const { connectFirestoreEmulator } = require('firebase/firestore');
connectFirestoreEmulator(db, 'localhost', 8081);

// Sample recipes data - 15 resep beragam
const sampleRecipes = [
  {
    title: "Nasi Goreng Spesial",
    description: "Nasi goreng dengan bumbu rahasia yang lezat",
    ingredients: ["2 piring nasi putih", "2 butir telur", "3 siung bawang putih", "5 siung bawang merah", "2 sdm kecap manis", "1 sdt garam", "Cabai sesuai selera"],
    steps: ["Tumis bawang putih dan bawang merah hingga harum", "Masukkan telur, orak-arik sebentar", "Tambahkan nasi putih, aduk rata", "Beri kecap manis dan garam", "Sajikan dengan kerupuk"],
    image: "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500",
    userId: "sample-user-id", userName: "Chef Budi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Budi",
    category: "Indonesian", cookingTime: 30, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.5, reviews: []
  },
  {
    title: "Rendang Daging Sapi",
    description: "Rendang khas Padang yang empuk dan gurih",
    ingredients: ["500g daging sapi", "400ml santan kental", "5 lembar daun jeruk", "2 batang serai", "Bumbu halus: bawang merah, bawang putih, cabai, lengkuas, kunyit, jahe"],
    steps: ["Tumis bumbu halus hingga harum", "Masukkan daging, aduk hingga berubah warna", "Tuang santan, tambahkan daun jeruk dan serai", "Masak dengan api kecil hingga bumbu meresap (2-3 jam)", "Masak hingga kuah mengering"],
    image: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500",
    userId: "sample-user-id", userName: "Chef Siti", userAvatar: "https://ui-avatars.com/api/?name=Chef+Siti",
    category: "Indonesian", cookingTime: 180, servings: 4, difficulty: "hard",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 5.0, reviews: []
  },
  {
    title: "Spaghetti Carbonara",
    description: "Pasta Italia dengan saus krim yang creamy",
    ingredients: ["200g spaghetti", "100g bacon", "2 butir telur", "50g keju parmesan", "2 siung bawang putih", "Merica hitam", "Garam secukupnya"],
    steps: ["Rebus spaghetti hingga al dente", "Tumis bacon dan bawang putih hingga crispy", "Kocok telur dengan keju parmesan", "Campurkan spaghetti dengan bacon", "Matikan api, tuang campuran telur", "Taburi merica hitam"],
    image: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=500",
    userId: "sample-user-id", userName: "Chef Marco", userAvatar: "https://ui-avatars.com/api/?name=Chef+Marco",
    category: "Western", cookingTime: 25, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.8, reviews: []
  },
  {
    title: "Soto Ayam Kuning",
    description: "Soto ayam khas Jawa dengan kuah kuning yang segar",
    ingredients: ["500g ayam", "2 liter air", "Kunyit, jahe, lengkuas", "Daun jeruk, serai", "Kol, tauge, telur rebus", "Bawang goreng"],
    steps: ["Rebus ayam dengan bumbu hingga empuk", "Suwir daging ayam", "Siapkan mangkuk dengan kol dan tauge", "Tuang kuah panas", "Taburi bawang goreng dan seledri"],
    image: "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500",
    userId: "sample-user-id", userName: "Chef Dewi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Dewi",
    category: "Indonesian", cookingTime: 60, servings: 4, difficulty: "medium",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.7, reviews: []
  },
  {
    title: "Gado-Gado Jakarta",
    description: "Salad sayuran dengan saus kacang yang nikmat",
    ingredients: ["Kangkung, kol, tauge", "Kentang rebus", "Telur rebus", "Tahu goreng", "Kerupuk", "Bumbu kacang"],
    steps: ["Rebus semua sayuran", "Potong kentang dan tahu", "Susun di piring", "Siram dengan bumbu kacang", "Tambahkan kerupuk dan bawang goreng"],
    image: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500",
    userId: "sample-user-id", userName: "Chef Rina", userAvatar: "https://ui-avatars.com/api/?name=Chef+Rina",
    category: "Indonesian", cookingTime: 30, servings: 3, difficulty: "easy",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.6, reviews: []
  },
  {
    title: "Ayam Geprek Sambal Matah",
    description: "Ayam goreng crispy dengan sambal matah yang pedas segar",
    ingredients: ["1 ayam fillet", "Tepung bumbu", "Bawang merah, cabai rawit", "Serai, daun jeruk", "Jeruk nipis", "Terasi"],
    steps: ["Goreng ayam dengan tepung bumbu hingga crispy", "Geprek ayam dengan ulekan", "Iris tipis bawang merah dan cabai", "Campur dengan minyak panas", "Siram di atas ayam geprek"],
    image: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500",
    userId: "sample-user-id", userName: "Chef Andi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Andi",
    category: "Indonesian", cookingTime: 40, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.9, reviews: []
  },
  {
    title: "Chicken Teriyaki Rice Bowl",
    description: "Nasi dengan ayam teriyaki ala Jepang",
    ingredients: ["300g daging ayam", "4 sdm saus teriyaki", "2 sdm mirin", "1 sdm gula", "Wijen", "Nasi putih", "Sayuran rebus"],
    steps: ["Potong ayam kotak-kotak", "Marinasi dengan teriyaki, mirin, gula", "Tumis hingga matang dan mengental", "Sajikan di atas nasi", "Taburi wijen"],
    image: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500",
    userId: "sample-user-id", userName: "Chef Yuki", userAvatar: "https://ui-avatars.com/api/?name=Chef+Yuki",
    category: "Japanese", cookingTime: 35, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.7, reviews: []
  },
  {
    title: "Tom Yum Goong",
    description: "Sup udang Thailand yang asam pedas segar",
    ingredients: ["300g udang", "2 batang serai", "5 lembar daun jeruk", "Lengkuas", "Cabai rawit", "Jeruk nipis", "Fish sauce", "Jamur"],
    steps: ["Rebus air dengan serai, daun jeruk, lengkuas", "Masukkan udang dan jamur", "Beri fish sauce dan gula", "Tambahkan jeruk nipis dan cabai", "Masak sebentar, sajikan panas"],
    image: "https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=500",
    userId: "sample-user-id", userName: "Chef Somchai", userAvatar: "https://ui-avatars.com/api/?name=Chef+Somchai",
    category: "Thai", cookingTime: 25, servings: 3, difficulty: "medium",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.8, reviews: []
  },
  {
    title: "Beef Burger Homemade",
    description: "Burger daging sapi juicy dengan keju dan sayuran",
    ingredients: ["300g daging sapi giling", "Roti burger", "Keju cheddar", "Tomat, selada, bawang bombay", "Saus mayo dan mustard"],
    steps: ["Bentuk daging menjadi patty, bumbui dengan garam dan merica", "Panggang di wajan hingga matang", "Panggang roti sebentar", "Susun: roti, patty, keju, sayuran, saus", "Tutup dengan roti atas"],
    image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500",
    userId: "sample-user-id", userName: "Chef John", userAvatar: "https://ui-avatars.com/api/?name=Chef+John",
    category: "Western", cookingTime: 30, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.6, reviews: []
  },
  {
    title: "Nasi Uduk Betawi",
    description: "Nasi gurih khas Betawi dengan lauk lengkap",
    ingredients: ["500g beras", "400ml santan", "Daun salam, serai", "Lauk: ayam goreng, telur, tempe orek", "Sambal kacang", "Kerupuk"],
    steps: ["Masak beras dengan santan, daun salam, serai", "Siapkan lauk ayam, telur, tempe", "Buat sambal kacang", "Tata nasi uduk di piring", "Susun dengan lauk-pauk"],
    image: "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500",
    userId: "sample-user-id", userName: "Chef Hadi", userAvatar: "https://ui-avatars.com/api/?name=Chef+Hadi",
    category: "Indonesian", cookingTime: 50, servings: 4, difficulty: "medium",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.7, reviews: []
  },
  {
    title: "Pad Thai",
    description: "Mie goreng Thailand dengan saus tamarind",
    ingredients: ["200g rice noodles", "100g udang", "2 butir telur", "Tauge", "Kacang tanah", "Saus tamarind", "Fish sauce", "Jeruk nipis"],
    steps: ["Rendam rice noodles hingga lembut", "Tumis udang dan telur", "Masukkan noodles dan saus", "Tambahkan tauge", "Sajikan dengan kacang dan jeruk nipis"],
    image: "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=500",
    userId: "sample-user-id", userName: "Chef Nong", userAvatar: "https://ui-avatars.com/api/?name=Chef+Nong",
    category: "Thai", cookingTime: 30, servings: 2, difficulty: "medium",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.8, reviews: []
  },
  {
    title: "Nasi Kuning Tumpeng",
    description: "Nasi kuning dengan lauk lengkap untuk perayaan",
    ingredients: ["500g beras", "Kunyit, santan, serai", "Ayam goreng, telur, perkedel", "Sambal goreng ati", "Urap sayuran", "Kerupuk"],
    steps: ["Masak nasi dengan kunyit dan santan", "Siapkan semua lauk", "Bentuk nasi menjadi kerucut", "Susun lauk di sekitar tumpeng", "Hias dengan sayuran"],
    image: "https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=500",
    userId: "sample-user-id", userName: "Chef Lestari", userAvatar: "https://ui-avatars.com/api/?name=Chef+Lestari",
    category: "Indonesian", cookingTime: 90, servings: 8, difficulty: "hard",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 5.0, reviews: []
  },
  {
    title: "Martabak Manis Coklat Keju",
    description: "Martabak manis dengan topping coklat dan keju",
    ingredients: ["250g tepung terigu", "2 butir telur", "300ml susu", "Ragi instant", "Gula pasir", "Topping: coklat, keju, kacang"],
    steps: ["Campur tepung, telur, susu, ragi, gula", "Diamkan 1 jam hingga mengembang", "Tuang adonan di loyang panas", "Taburi topping coklat dan keju", "Lipat dan potong"],
    image: "https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500",
    userId: "sample-user-id", userName: "Chef Tono", userAvatar: "https://ui-avatars.com/api/?name=Chef+Tono",
    category: "Indonesian", cookingTime: 90, servings: 4, difficulty: "medium",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.9, reviews: []
  },
  {
    title: "Sushi Roll California",
    description: "Sushi roll dengan alpukat, kepiting, dan timun",
    ingredients: ["300g nasi sushi", "4 lembar nori", "100g stick kepiting", "1 buah alpukat", "Timun", "Saus mayo Jepang", "Wijen"],
    steps: ["Ratakan nasi di atas nori", "Balik nori", "Susun kepiting, alpukat, timun", "Gulung dengan bamboo mat", "Potong-potong, taburi wijen"],
    image: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500",
    userId: "sample-user-id", userName: "Chef Kenji", userAvatar: "https://ui-avatars.com/api/?name=Chef+Kenji",
    category: "Japanese", cookingTime: 45, servings: 4, difficulty: "hard",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.7, reviews: []
  },
  {
    title: "Es Cendol Durian",
    description: "Minuman segar cendol dengan durian",
    ingredients: ["Cendol hijau", "Santan kental", "Gula merah cair", "Durian kupas", "Es batu", "Nangka (opsional)"],
    steps: ["Siapkan gelas tinggi", "Masukkan cendol dan durian", "Tuang gula merah cair", "Tambahkan es batu", "Siram dengan santan", "Aduk sebelum diminum"],
    image: "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500",
    userId: "sample-user-id", userName: "Chef Maya", userAvatar: "https://ui-avatars.com/api/?name=Chef+Maya",
    category: "Indonesian", cookingTime: 15, servings: 2, difficulty: "easy",
    createdAt: Timestamp.now(), favoritedBy: [], rating: 4.8, reviews: []
  }
];

async function addSampleData() {
  try {
    console.log('🔥 Menambahkan sample recipes ke Firestore Emulator...');
    
    for (const recipe of sampleRecipes) {
      const docRef = await addDoc(collection(db, 'recipes'), recipe);
      console.log(`✅ Recipe ditambahkan: ${recipe.title} (ID: ${docRef.id})`);
    }
    
    console.log('\n🎉 Semua sample data berhasil ditambahkan!');
    console.log('📱 Coba refresh aplikasi Flutter Anda.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

addSampleData();
