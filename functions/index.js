const {setGlobalOptions} = require("firebase-functions/v2");
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Global options for Cloud Functions v2
setGlobalOptions({maxInstances: 10, region: "us-central1"});

let _admin;
function getAdmin() {
  if (!_admin) {
    _admin = require("firebase-admin");
    if (!_admin.apps.length) {
      _admin.initializeApp();
    }
  }
  return _admin;
}

function getDb() {
  return getAdmin().firestore();
}

/**
 * Health check endpoint to verify backend connectivity.
 */
exports.healthCheck = onRequest({cors: true}, (req, res) => {
  logger.info("Health check ping received");
  res.status(200).json({
    status: "ok",
    app: "Hana Masr",
    database: "hena-masar",
    timestamp: new Date().toISOString(),
  });
});

/**
 * Seed initial categories & cities into Firestore.
 */
exports.seedInitialData = onRequest({cors: true}, async (req, res) => {
  try {
    const db = getDb();
    const citiesRef = db.collection("cities");
    const categoriesRef = db.collection("categories");

    const batch = db.batch();

    // 1. Initial Cities
    const initialCities = [
      {
        id: "cairo",
        name: {
          ar: "القاهرة",
          en: "Cairo",
          ru: "Каир",
          de: "Kairo",
          fr: "Le Caire",
        },
        imageUrl: "https://images.unsplash.com/photo-1572252009286-268acec5ca0a",
        isPopular: true,
      },
      {
        id: "giza",
        name: {
          ar: "الجيزة",
          en: "Giza",
          ru: "Гиза",
          de: "Gizeh",
          fr: "Gizeh",
        },
        imageUrl: "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368",
        isPopular: true,
      },
      {
        id: "luxor",
        name: {
          ar: "الأقصر",
          en: "Luxor",
          ru: "Луксор",
          de: "Luxor",
          fr: "Louxor",
        },
        imageUrl: "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
        isPopular: true,
      },
      {
        id: "aswan",
        name: {
          ar: "أسوان",
          en: "Aswan",
          ru: "Асуан",
          de: "Assuan",
          fr: "Assouan",
        },
        imageUrl: "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
        isPopular: true,
      },
      {
        id: "alexandria",
        name: {
          ar: "الإسكندرية",
          en: "Alexandria",
          ru: "Александрия",
          de: "Alexandria",
          fr: "Alexandrie",
        },
        imageUrl: "https://images.unsplash.com/photo-1569154941061-e231b4725ef1",
        isPopular: true,
      },
    ];

    // 2. Initial Categories
    const initialCategories = [
      {
        id: "pharaonic",
        name: {ar: "آثار فرعونية", en: "Ancient Pharaonic"},
        icon: "ankh",
      },
      {
        id: "islamic_coptic",
        name: {ar: "تراث إسلامي وقبطي", en: "Islamic & Coptic Heritage"},
        icon: "heritage",
      },
      {
        id: "museums",
        name: {ar: "متاحف", en: "Museums"},
        icon: "museum",
      },
      {
        id: "nature_nile",
        name: {ar: "النيل والطبيعة", en: "Nile & Nature"},
        icon: "nature",
      },
      {
        id: "food_markets",
        name: {ar: "أسواق وأكلات شعبية", en: "Markets & Egyptian Food"},
        icon: "market",
      },
    ];

    for (const city of initialCities) {
      batch.set(citiesRef.doc(city.id), city, {merge: true});
    }

    for (const cat of initialCategories) {
      batch.set(categoriesRef.doc(cat.id), cat, {merge: true});
    }

    await batch.commit();

    logger.info("Database seeded successfully with cities and categories");
    res.status(200).json({
      success: true,
      message: "Seeded initial cities and categories into hena-masar.",
    });
  } catch (error) {
    logger.error("Error seeding initial data", error);
    res.status(500).json({success: false, error: error.message});
  }
});
