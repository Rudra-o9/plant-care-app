import 'plant_care_guide_service.dart';

class PlantLibraryEntry {
  final String name;
  final String scientificName;
  final String description;
  final PlantCareGuide care;

  const PlantLibraryEntry({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.care,
  });
}

/// A useful offline catalogue for adding common plants without a photo.
class PlantLibraryService {
  static final List<PlantLibraryEntry> entries = [
    PlantLibraryEntry(
      name: 'Aloe Vera',
      scientificName: 'Aloe vera',
      description:
          'A sun-loving succulent known for its thick, soothing leaves.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 14,
        watering: 'Water only when soil is completely dry.',
        sunlight: 'Bright light with a few hours of gentle direct sun.',
        temperature: '18–30°C; protect from frost.',
        soil: 'Fast-draining cactus mix.',
        note: 'Overwatering is the main risk.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Snake Plant',
      scientificName: 'Dracaena trifasciata',
      description: 'A resilient upright houseplant with architectural leaves.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 14,
        watering: 'Let the soil dry out completely between waterings.',
        sunlight: 'Low to bright indirect light.',
        temperature: '18–30°C; avoid cold drafts.',
        soil: 'Well-draining indoor or cactus mix.',
        note: 'Water less during low-light months.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Money Plant',
      scientificName: 'Epipremnum aureum',
      description: 'A fast-growing trailing vine, also called pothos.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 7,
        watering: 'Water when the top 2–5 cm of soil feels dry.',
        sunlight: 'Bright, indirect light; tolerates lower light.',
        temperature: '18–29°C.',
        soil: 'Loose, airy potting mix.',
        note: 'Trim long vines to encourage fuller growth.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Tulsi',
      scientificName: 'Ocimum tenuiflorum',
      description: 'A fragrant holy basil widely grown in Indian homes.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 3,
        watering: 'Keep soil lightly moist, never waterlogged.',
        sunlight: '4–6 hours of morning sun.',
        temperature: '18–32°C.',
        soil: 'Rich, well-draining mix with compost.',
        note: 'Pinch growing tips regularly.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Spider Plant',
      scientificName: 'Chlorophytum comosum',
      description: 'An adaptable houseplant with arching striped leaves.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 7,
        watering: 'Water once the upper soil layer dries.',
        sunlight: 'Bright, indirect light.',
        temperature: '15–27°C.',
        soil: 'Well-draining all-purpose potting mix.',
        note: 'Trim brown tips with clean scissors.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Peace Lily',
      scientificName: 'Spathiphyllum wallisii',
      description: 'A flowering indoor plant with glossy green leaves.',
      care: PlantCareGuide(
        careLevel: 'Medium',
        wateringFrequencyDays: 5,
        watering: 'Keep soil lightly moist; water when leaves begin to soften.',
        sunlight: 'Medium to bright indirect light.',
        temperature: '18–27°C.',
        soil: 'Moisture-retentive, well-draining mix.',
        note: 'Keep away from pets as it is toxic if eaten.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Monstera',
      scientificName: 'Monstera deliciosa',
      description: 'A tropical foliage plant with distinctive split leaves.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 7,
        watering: 'Water when the top few centimetres of soil are dry.',
        sunlight: 'Bright, indirect light.',
        temperature: '18–29°C.',
        soil: 'Chunky, airy aroid mix.',
        note: 'Give it a moss pole as it matures.',
      ),
    ),
    PlantLibraryEntry(
      name: 'Jade Plant',
      scientificName: 'Crassula ovata',
      description: 'A compact succulent with thick, oval leaves.',
      care: PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 14,
        watering: 'Soak only after the soil dries completely.',
        sunlight: 'Bright light with some direct sun.',
        temperature: '18–28°C.',
        soil: 'Fast-draining succulent mix.',
        note: 'Use a pot with a drainage hole.',
      ),
    ),
    ..._additionalEntries,
  ];

  // These common indoor, balcony and garden plants keep the offline library
  // useful for a classroom demonstration even without an internet connection.
  static final List<PlantLibraryEntry> _additionalEntries = [
    _easy('Areca Palm', 'Dypsis lutescens', 'A feathery palm that brightens warm indoor spaces.', 7, 'Bright, filtered light.'),
    _easy('Rubber Plant', 'Ficus elastica', 'A glossy-leaved statement plant for a bright room.', 7, 'Bright, indirect light.'),
    _easy('Fiddle Leaf Fig', 'Ficus lyrata', 'A dramatic small tree with large violin-shaped leaves.', 8, 'Bright, consistent indirect light.', level: 'Medium'),
    _easy('ZZ Plant', 'Zamioculcas zamiifolia', 'A drought-tolerant houseplant with shiny leaflets.', 14, 'Low to bright indirect light.'),
    _easy('Chinese Evergreen', 'Aglaonema commutatum', 'A forgiving foliage plant with patterned leaves.', 7, 'Low to medium indirect light.'),
    _easy('Philodendron Heartleaf', 'Philodendron hederaceum', 'A trailing vine with soft heart-shaped leaves.', 7, 'Medium to bright indirect light.'),
    _easy('Bird of Paradise', 'Strelitzia reginae', 'A bold tropical plant with paddle-like leaves.', 7, 'Very bright light, with gentle sun.', level: 'Medium'),
    _easy('Dracaena Marginata', 'Dracaena marginata', 'A slender indoor tree with red-edged leaves.', 10, 'Bright, indirect light.'),
    _easy('Lucky Bamboo', 'Dracaena sanderiana', 'A compact water-grown plant often kept on desks.', 7, 'Low to medium indirect light.'),
    _easy('English Ivy', 'Hedera helix', 'A classic trailing vine for a cool, bright spot.', 5, 'Bright indirect light.', level: 'Medium'),
    _easy('Boston Fern', 'Nephrolepis exaltata', 'A lush fern that enjoys humidity and even moisture.', 4, 'Bright, indirect light.', level: 'Medium'),
    _easy('Calathea', 'Goeppertia orbifolia', 'A patterned foliage plant with expressive leaves.', 5, 'Medium indirect light.', level: 'Medium'),
    _easy('Croton', 'Codiaeum variegatum', 'A colourful foliage plant with vivid veined leaves.', 5, 'Bright light.', level: 'Medium'),
    _easy('Anthurium', 'Anthurium andraeanum', 'A long-flowering tropical plant with waxy blooms.', 6, 'Bright, indirect light.', level: 'Medium'),
    _easy('Orchid', 'Phalaenopsis spp.', 'A graceful flowering orchid for an airy bright room.', 7, 'Bright, indirect light.', level: 'Medium'),
    _easy('Kalanchoe', 'Kalanchoe blossfeldiana', 'A cheerful flowering succulent for a sunny sill.', 10, 'Bright light with gentle sun.'),
    _easy('Echeveria', 'Echeveria elegans', 'A rosette succulent with powdery sculptural leaves.', 14, 'Several hours of direct sun.'),
    _easy('String of Pearls', 'Curio rowleyanus', 'A trailing succulent with bead-like leaves.', 14, 'Bright light.', level: 'Medium'),
    _easy('Ponytail Palm', 'Beaucarnea recurvata', 'A drought-tolerant plant with a swollen trunk base.', 14, 'Bright light.'),
    _easy('Basil', 'Ocimum basilicum', 'A fragrant culinary herb for a sunny kitchen.', 3, 'At least 4 hours of sun.'),
    _easy('Mint', 'Mentha spicata', 'A fast-growing herb with refreshing aromatic leaves.', 3, 'Morning sun or bright light.'),
    _easy('Coriander', 'Coriandrum sativum', 'A quick-growing herb best enjoyed fresh.', 2, '4–6 hours of sun.'),
    _easy('Rosemary', 'Salvia rosmarinus', 'A woody Mediterranean herb with fragrant needles.', 6, 'Full sun.'),
    _easy('Curry Leaf Plant', 'Murraya koenigii', 'An aromatic Indian kitchen garden shrub.', 4, '4–6 hours of direct sun.'),
    _easy('Lemongrass', 'Cymbopogon citratus', 'A citrus-scented grass for a sunny balcony.', 4, 'Full sun.'),
    _easy('Chilli Plant', 'Capsicum annuum', 'A productive edible plant for a sunny container.', 3, 'At least 6 hours of sun.'),
    _easy('Tomato', 'Solanum lycopersicum', 'A rewarding fruiting plant for a sunny terrace.', 3, 'Full sun.', level: 'Medium'),
    _easy('Marigold', 'Tagetes erecta', 'A bright, easy annual flower for pots and borders.', 3, 'Full sun.'),
    _easy('Hibiscus', 'Hibiscus rosa-sinensis', 'A tropical shrub with large colourful blooms.', 3, '4–6 hours of sun.', level: 'Medium'),
    _easy('Jasmine', 'Jasminum sambac', 'A fragrant flowering climber for warm balconies.', 3, 'Morning sun.', level: 'Medium'),
    _easy('Bougainvillea', 'Bougainvillea glabra', 'A sun-loving climber with papery colourful bracts.', 7, 'Full sun.'),
    _easy('Rose', 'Rosa chinensis', 'A classic flowering shrub suited to a sunny pot.', 4, 'At least 6 hours of sun.', level: 'Medium'),
    _easy('Sunflower', 'Helianthus annuus', 'A cheerful annual with a striking flower head.', 3, 'Full sun.'),
    _easy('Lavender', 'Lavandula angustifolia', 'A fragrant flowering herb that prefers dry air.', 7, 'Full sun.'),
    _easy('Gardenia', 'Gardenia jasminoides', 'A scented evergreen with creamy white flowers.', 4, 'Bright light with morning sun.', level: 'Medium'),
    _easy('Ixora', 'Ixora coccinea', 'A compact shrub with clusters of small bright flowers.', 4, 'Morning to full sun.'),
    _easy('Adenium', 'Adenium obesum', 'A desert rose with a sculptural trunk and blooms.', 10, 'Full sun.'),
    _easy('Neem', 'Azadirachta indica', 'A hardy native tree valued for its aromatic foliage.', 5, 'Full sun.'),
    _easy('Mango', 'Mangifera indica', 'A tropical fruit tree for a large sunny space.', 5, 'Full sun.', level: 'Medium'),
    _easy('Lemon', 'Citrus limon', 'A fragrant citrus tree that grows well in a large pot.', 4, 'Full sun.', level: 'Medium'),
    _easy('Pomegranate', 'Punica granatum', 'A compact fruiting shrub with vivid flowers.', 5, 'Full sun.'),
    _easy('Guava', 'Psidium guajava', 'A tropical fruit tree for a sunny garden or terrace.', 5, 'Full sun.'),
    _easy('Papaya', 'Carica papaya', 'A fast-growing tropical plant with large leaves.', 4, 'Full sun.'),
    _easy('Banana Plant', 'Musa acuminata', 'A lush tropical plant that likes warmth and moisture.', 3, 'Full sun to bright light.', level: 'Medium'),
    _easy('Bamboo Palm', 'Chamaedorea seifrizii', 'An elegant, shade-tolerant indoor palm.', 7, 'Medium indirect light.'),
    _easy('Peperomia', 'Peperomia obtusifolia', 'A compact foliage plant with thick rounded leaves.', 8, 'Bright, indirect light.'),
    _easy('Nerve Plant', 'Fittonia albivenis', 'A small plant with delicately veined leaves.', 4, 'Medium indirect light.', level: 'Medium'),
    _easy('Prayer Plant', 'Maranta leuconeura', 'A patterned plant whose leaves fold upward at night.', 5, 'Medium indirect light.', level: 'Medium'),
    _easy('Dieffenbachia', 'Dieffenbachia seguine', 'A bold foliage plant with cream-patterned leaves.', 7, 'Medium to bright indirect light.'),
    _easy('Syngonium', 'Syngonium podophyllum', 'An adaptable arrowhead vine for shelves or baskets.', 7, 'Bright, indirect light.'),
  ];

  static PlantLibraryEntry _easy(
    String name,
    String scientificName,
    String description,
    int wateringDays,
    String sunlight, {
    String level = 'Easy',
  }) => PlantLibraryEntry(
    name: name,
    scientificName: scientificName,
    description: description,
    care: PlantCareGuide(
      careLevel: level,
      wateringFrequencyDays: wateringDays,
      watering: 'Water when the top layer of soil is dry; never leave roots standing in water.',
      sunlight: sunlight,
      temperature: '18–30°C; protect from frost and harsh drafts.',
      soil: 'Well-draining potting mix with a pot that has drainage holes.',
      note: 'Adjust watering for heat, rainfall and the size of the pot.',
    ),
  );
}
