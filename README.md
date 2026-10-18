# Plant Care

## Pl@ntNet setup

The Identify Plant screen accepts a camera photo or a file selected from the
phone or laptop, then sends up to five JPG/PNG images of the same plant to the
Pl@ntNet v2 identification API.

1. Create an account at [My Pl@ntNet](https://my.plantnet.org/) and generate a private API key.
2. Run the app with the key (do not commit it):

```bash
flutter run --dart-define=PLANTNET_API_KEY=your_private_key
```

For Android, allow camera access when prompted. The app reports API-key,
network, quota, and unsupported-image errors directly in the identification UI.

Pl@ntNet provides the identification, confidence, scientific/common names,
taxonomy, and predicted plant organ. Its API does not provide care instructions;
the app labels its displayed watering, light, temperature, and soil guidance as
general care suggestions and saves it with the identified plant.
