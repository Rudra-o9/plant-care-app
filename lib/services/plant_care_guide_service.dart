import '../models/plant_identification_model.dart';

/// Conservative, offline care suggestions. Pl@ntNet identifies species but
/// does not return horticultural care instructions, so these are kept separate
/// from the API response and labelled as general guidance in the UI.
class PlantCareGuide {
  final String careLevel;
  final int wateringFrequencyDays;
  final String watering;
  final String sunlight;
  final String temperature;
  final String soil;
  final String note;

  const PlantCareGuide({
    required this.careLevel,
    required this.wateringFrequencyDays,
    required this.watering,
    required this.sunlight,
    required this.temperature,
    required this.soil,
    required this.note,
  });
}

class PlantCareGuideService {
  static PlantCareGuide general() => const PlantCareGuide(
    careLevel: 'Medium',
    wateringFrequencyDays: 7,
    watering: 'Water when the top 2–5 cm of soil is dry. Never leave roots sitting in water.',
    sunlight: 'Bright, indirect light until the species is confirmed.',
    temperature: '18–27°C; avoid frost and heating/AC drafts.',
    soil: 'Well-draining potting mix in a pot with drainage holes.',
    note: 'General guidance only—adjust once the species is confirmed.',
  );

  static PlantCareGuide forMatch(PlantIdentificationResult match) {
    final name = '${match.displayName} ${match.commonName}'.toLowerCase();
    if (name.contains('ashwagandha') ||
        name.contains('withania') ||
        name.contains('ginseng') ||
        name.contains('winter cherry')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 5,
        watering: 'Water only when the top 2–3 inches of soil are dry. Sensitive to waterlogging.',
        sunlight: 'Full direct sunlight (at least 6–8 hours daily).',
        temperature: '20–35°C; prefers warm, dry climates. Protect from frost.',
        soil: 'Sandy, well-draining soil with neutral to slightly alkaline pH (7.5–8.0).',
        note: 'Famous Ayurvedic medicinal herb. Harvest roots after 150–180 days when leaves start drying.',
      );
    }
    if (name.contains('neem') || name.contains('azadirachta indica')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 7,
        watering: 'Water deeply when the top 3–5 cm of soil is dry; established outdoor trees need less frequent watering.',
        sunlight: 'Full sun is best: at least 6 hours daily.',
        temperature: '20–35°C; protect young plants from frost.',
        soil: 'Loose, well-draining loam or potting mix; use a pot with drainage.',
        note: 'Let excess water drain completely. Young container plants need more regular checks than established trees.',
      );
    }
    if (name.contains('ocimum') ||
        name.contains('tulsi') ||
        name.contains('basil')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 3,
        watering:
            'Keep soil lightly moist; water when the top 1–2 cm feels dry.',
        sunlight: '4–6 hours of gentle sun, preferably morning sun.',
        temperature: '18–32°C; keep warm and frost-free.',
        soil: 'Rich, well-draining potting mix with compost.',
        note: 'Pinch flower buds and growing tips regularly to encourage fuller leafy growth.',
      );
    }
    if (name.contains('monstera') ||
        name.contains('philodendron') ||
        name.contains('pothos') ||
        name.contains('epipremnum')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 7,
        watering: 'Water when the top 2–5 cm of soil is dry; empty the saucer.',
        sunlight: 'Bright, indirect light. Avoid harsh midday sun.',
        temperature: '18–29°C; protect from cold drafts.',
        soil: 'Loose, airy, well-draining indoor potting mix.',
        note: 'Reduce watering in cooler or lower-light months.',
      );
    }
    if (name.contains('cactus') ||
        name.contains('succulent') ||
        name.contains('aloe') ||
        name.contains('echeveria')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 14,
        watering:
            'Soak fully only after the potting mix has dried out completely.',
        sunlight:
            'Several hours of bright light; acclimate gradually to direct sun.',
        temperature: '18–32°C; keep frost-free.',
        soil: 'Fast-draining cactus or succulent mix in a pot with drainage.',
        note: 'Overwatering is the most common problem.',
      );
    }
    if (name.contains('coconut') ||
        name.contains('cocos') ||
        name.contains('palm') ||
        name.contains('areca') ||
        name.contains('dypsis')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 4,
        watering: 'Keep soil consistently moist. Water 1–2 times weekly in summer, letting excess drain.',
        sunlight: 'Full direct sunlight (at least 6 hours daily).',
        temperature: '21–35°C; loves humid tropical heat, protect from cold below 15°C.',
        soil: 'Well-draining sandy loam or rich palm potting mix.',
        note: 'Coconut trees love warmth, high humidity, and plenty of natural sunshine.',
      );
    }
    if (name.contains('religiosa') ||
        name.contains('bodhi') ||
        name.contains('peepal') ||
        name.contains('sacred fig') ||
        name.contains('benghalensis') ||
        name.contains('banyan') ||
        name.contains('ficus')) {
      return const PlantCareGuide(
        careLevel: 'Easy',
        wateringFrequencyDays: 5,
        watering: 'Water moderately when the top 3 cm of soil feels dry. Reduce in winter.',
        sunlight: 'Full direct to bright filtered sunlight (at least 5-6 hours daily).',
        temperature: '20–35°C; thrives in warm tropical climates, keep away from severe cold.',
        soil: 'Rich, fertile, well-draining garden soil or standard potting mix.',
        note: 'Sacred Fig and Banyan grow vigorously in natural sunlight. Provide occasional pruning to shape indoor bonsai.',
      );
    }
    if (name.contains('sansevieria') ||
        name.contains('snake plant') ||
        name.contains('dracaena trifasciata')) {
      return const PlantCareGuide(
        careLevel: 'Very Easy',
        wateringFrequencyDays: 14,
        watering: 'Allow soil to dry out completely between waterings. Water once every 2–3 weeks.',
        sunlight: 'Tolerates low light, but thrives in medium to bright indirect sunlight.',
        temperature: '15–30°C; avoid temperatures below 10°C.',
        soil: 'Well-draining succulent or cactus mix.',
        note: 'One of the best natural air-purifying indoor plants. Never let water sit in the rosette.',
      );
    }
    if (name.contains('rose') || name.contains('rosa')) {
      return const PlantCareGuide(
        careLevel: 'Medium',
        wateringFrequencyDays: 3,
        watering: 'Water deeply 2–3 times a week at the base. Keep foliage dry to avoid fungal issues.',
        sunlight: 'Full direct sunlight (at least 6 hours per day).',
        temperature: '15–28°C.',
        soil: 'Rich, well-drained loamy soil with plenty of organic compost.',
        note: 'Deadhead faded flowers regularly to stimulate vibrant new blooms.',
      );
    }
    return general();
  }
}
