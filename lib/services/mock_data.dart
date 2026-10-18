import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../models/plant_journal_entry.dart';
import '../models/reminder_model.dart';

/// Dummy user for development, demonstration, and testing purposes.
/// Login Credentials:
/// Email: alex.green@plantcare.io
/// Password: password123
final UserModel dummyUser = UserModel(
  id: 'usr_dummy_98765',
  name: 'Alex',
  surname: 'Green',
  email: 'alex.green@plantcare.io',
  mobileNumber: '+1 555-0199',
  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
  totalPlants: 10,
  careStreakDays: 14,
  plantsNeedingAttention: 2,
);

/// A curated list of 10 dummy plants belonging to Alex Green.
final List<PlantModel> dummyPlants = [
  PlantModel(
    id: 'plant_001',
    name: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa',
    description: 'A stunning tropical plant known for its dramatic perforated leaves and iconic split foliage.',
    imageUrl: 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Medium',
    wateringFrequencyDays: 7,
    sunlight: 'Bright Indirect',
    temperature: '18°C - 30°C',
    soilType: 'Rich, well-draining peat potting mix',
    lastWatered: DateTime.now().subtract(const Duration(days: 2)),
    careActivityDates: [
      '2026-09-22',
      '2026-09-15',
      '2026-09-08',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_001_1',
        note: 'New fenestrated leaf unfurled today! Looks very healthy.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
    isFavorite: true,
    customNotes: 'Living room corner near east-facing window.',
    matchConfidence: 0.98,
  ),
  PlantModel(
    id: 'plant_002',
    name: 'Snake Plant',
    scientificName: 'Dracaena trifasciata',
    description: 'An exceptionally hardy and resilient architectural succulent with upright sword-like foliage.',
    imageUrl: 'https://images.unsplash.com/photo-1593482892290-f54927ae1bf6?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Easy',
    wateringFrequencyDays: 14,
    sunlight: 'Low to Bright Indirect',
    temperature: '15°C - 29°C',
    soilType: 'Cactus & succulent mix with perlite',
    lastWatered: DateTime.now().subtract(const Duration(days: 12)),
    careActivityDates: [
      '2026-09-12',
      '2026-08-29',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_002_1',
        note: 'Repotted into a terracotta pot with fresh coarse soil.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ],
    isFavorite: true,
    customNotes: 'Bedroom shelf. Thrives even with minimal light.',
    matchConfidence: 0.99,
  ),
  PlantModel(
    id: 'plant_003',
    name: 'Fiddle Leaf Fig',
    scientificName: 'Ficus lyrata',
    description: 'Prized for its large violin-shaped leaves that make a bold statement in any interior space.',
    imageUrl: 'https://images.unsplash.com/photo-1545241047-6083a3684587?auto=format&fit=crop&w=800&q=80',
    careLevel: 'High',
    wateringFrequencyDays: 7,
    sunlight: 'Bright Indirect',
    temperature: '18°C - 26°C',
    soilType: 'Organic potting soil with bark and perlite',
    lastWatered: DateTime.now().subtract(const Duration(days: 8)), // Needs attention
    careActivityDates: [
      '2026-09-16',
      '2026-09-09',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_003_1',
        note: 'Dusted off the leaves and rotated 90 degrees toward the window.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ],
    isFavorite: false,
    customNotes: 'Sensitive to drafts and sudden position changes.',
    matchConfidence: 0.95,
  ),
  PlantModel(
    id: 'plant_004',
    name: 'Golden Pothos',
    scientificName: 'Epipremnum aureum',
    description: 'Vigorous trailing vine featuring heart-shaped leaves marbled with golden and cream yellow splashes.',
    imageUrl: 'https://images.unsplash.com/photo-1596724803697-3f3032f3f1e9?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Easy',
    wateringFrequencyDays: 6,
    sunlight: 'Medium to Bright Indirect',
    temperature: '17°C - 28°C',
    soilType: 'All-purpose well-draining potting soil',
    lastWatered: DateTime.now().subtract(const Duration(days: 3)),
    careActivityDates: [
      '2026-09-21',
      '2026-09-15',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_004_1',
        note: 'Trimmed bottom vines to propagate in water.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
    isFavorite: true,
    customNotes: 'Hanging basket in kitchen near window.',
    matchConfidence: 0.97,
  ),
  PlantModel(
    id: 'plant_005',
    name: 'ZZ Plant',
    scientificName: 'Zamioculcas zamiifolia',
    description: 'Practically indestructible houseplant with glossy, deep-green, feather-like stems.',
    imageUrl: 'https://images.unsplash.com/photo-1632207691143-643e2a9a9361?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Easy',
    wateringFrequencyDays: 14,
    sunlight: 'Low to Bright Indirect',
    temperature: '18°C - 26°C',
    soilType: 'Standard potting mix mixed with sand',
    lastWatered: DateTime.now().subtract(const Duration(days: 6)),
    careActivityDates: [
      '2026-09-18',
      '2026-09-04',
    ],
    journalEntries: [],
    isFavorite: false,
    customNotes: 'Hallway console table where sunlight is low.',
    matchConfidence: 0.99,
  ),
  PlantModel(
    id: 'plant_006',
    name: 'Peace Lily',
    scientificName: 'Spathiphyllum wallisii',
    description: 'Graceful houseplant with dark emerald leaves and elegant white floral spathes.',
    imageUrl: 'https://images.unsplash.com/photo-1593691509543-c55fb32e7355?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Medium',
    wateringFrequencyDays: 4,
    sunlight: 'Medium to Low Indirect',
    temperature: '18°C - 27°C',
    soilType: 'Moisture-retentive, porous potting mix',
    lastWatered: DateTime.now().subtract(const Duration(days: 5)), // Needs attention
    careActivityDates: [
      '2026-09-19',
      '2026-09-15',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_006_1',
        note: 'Leaves slightly droopy, reminders to water regularly.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ],
    isFavorite: false,
    customNotes: 'Shows immediate signs of thirst by drooping gently.',
    matchConfidence: 0.94,
  ),
  PlantModel(
    id: 'plant_007',
    name: 'Aloe Vera',
    scientificName: 'Aloe barbadensis miller',
    description: 'Renowned succulent with fleshy serrated leaves filled with soothing, healing gel.',
    imageUrl: 'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Easy',
    wateringFrequencyDays: 20,
    sunlight: 'Direct Sunlight',
    temperature: '15°C - 32°C',
    soilType: 'Fast-draining sandy cactus mix',
    lastWatered: DateTime.now().subtract(const Duration(days: 10)),
    careActivityDates: [
      '2026-09-14',
      '2026-08-25',
    ],
    journalEntries: [],
    isFavorite: false,
    customNotes: 'Sunny south-facing balcony window.',
    matchConfidence: 0.98,
  ),
  PlantModel(
    id: 'plant_008',
    name: 'Rubber Tree',
    scientificName: 'Ficus elastica',
    description: 'Popular tree-like plant with thick, leathery, dark burgundy and glossy green foliage.',
    imageUrl: 'https://images.unsplash.com/photo-1617173944883-6ffbd35d584d?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Medium',
    wateringFrequencyDays: 9,
    sunlight: 'Bright Indirect',
    temperature: '16°C - 28°C',
    soilType: 'Aerated peat-based potting mix',
    lastWatered: DateTime.now().subtract(const Duration(days: 4)),
    careActivityDates: [
      '2026-09-20',
      '2026-09-11',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_008_1',
        note: 'Wiped leaves with damp cloth to maximize photosynthesis.',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ],
    isFavorite: true,
    customNotes: 'Office desk companion.',
    matchConfidence: 0.96,
  ),
  PlantModel(
    id: 'plant_009',
    name: 'Spider Plant',
    scientificName: 'Chlorophytum comosum',
    description: 'Air-purifying favorite with cascading variegated ribbons and tiny blooming plantlets.',
    imageUrl: 'https://images.unsplash.com/photo-1572688484438-313a6e50c333?auto=format&fit=crop&w=800&q=80',
    careLevel: 'Easy',
    wateringFrequencyDays: 6,
    sunlight: 'Bright to Moderate Indirect',
    temperature: '14°C - 25°C',
    soilType: 'Loamy, well-aerated potting mix',
    lastWatered: DateTime.now().subtract(const Duration(days: 2)),
    careActivityDates: [
      '2026-09-22',
      '2026-09-16',
    ],
    journalEntries: [],
    isFavorite: false,
    customNotes: 'Produces spiderettes ready for potting.',
    matchConfidence: 0.97,
  ),
  PlantModel(
    id: 'plant_010',
    name: 'Calathea Orbifolia',
    scientificName: 'Calathea orbifolia',
    description: 'Exquisite prayer plant showcasing large round leaves with bold metallic silver-green stripes.',
    imageUrl: 'https://images.unsplash.com/photo-1600411833196-7c1f6b1a8b90?auto=format&fit=crop&w=800&q=80',
    careLevel: 'High',
    wateringFrequencyDays: 5,
    sunlight: 'Filtered Medium Light',
    temperature: '18°C - 25°C',
    soilType: 'Peat, pine bark, and perlite blend with high humidity',
    lastWatered: DateTime.now().subtract(const Duration(days: 1)),
    careActivityDates: [
      '2026-09-23',
      '2026-09-18',
    ],
    journalEntries: [
      PlantJournalEntry(
        id: 'j_010_1',
        note: 'Running humidifier nearby to keep humidity at ~60%.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
    isFavorite: true,
    customNotes: 'Needs distilled or filtered water to avoid tip browning.',
    matchConfidence: 0.93,
  ),
];

List<PlantModel> activeDummyPlants = List.from(dummyPlants);

List<ReminderModel> activeDummyReminders = [
  ReminderModel(
    id: 'rem_1',
    plantId: 'plant_001',
    plantName: 'Monstera Deliciosa',
    plantImageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=800&q=80',
    taskType: TaskType.watering,
    scheduledTime: DateTime.now(),
    isCompleted: false,
    repeatFrequency: 'Every 7 days',
  ),
  ReminderModel(
    id: 'rem_2',
    plantId: 'plant_006',
    plantName: 'Peace Lily',
    plantImageUrl:
        'https://images.unsplash.com/photo-1593691509543-c55fb32e7355?auto=format&fit=crop&w=800&q=80',
    taskType: TaskType.watering,
    scheduledTime: DateTime.now(),
    isCompleted: false,
    repeatFrequency: 'Every 4 days',
  ),
];

