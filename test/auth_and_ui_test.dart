import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care/screens/auth/login_screen.dart';
import 'package:plant_care/screens/auth/register_screen.dart';
import 'package:plant_care/screens/home/home_screen.dart';
import 'package:plant_care/screens/plants/my_plants_screen.dart';
import 'package:plant_care/screens/reminders/reminders_screen.dart';
import 'package:plant_care/screens/profile/profile_screen.dart';
import 'package:plant_care/screens/settings/settings_screen.dart';
import 'package:plant_care/screens/onboarding/onboarding_screen.dart';
import 'package:plant_care/screens/plants/plant_details_screen.dart';
import 'package:plant_care/screens/main_navigation_screen.dart';
import 'package:plant_care/config/mock_data.dart';
import 'package:plant_care/utils/validators.dart';
import 'package:plant_care/theme/app_theme.dart';

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final Uint8List _transparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('Validators Unit Tests', () {
    test('validateName validates length and alphabetic characters', () {
      expect(Validators.validateName(null, 'First Name'), 'First Name is required');
      expect(Validators.validateName('', 'First Name'), 'First Name is required');
      expect(Validators.validateName('A', 'First Name'), 'First Name must be at least 2 characters long');
      expect(Validators.validateName('Alex123', 'First Name'), 'First Name must contain letters only');
      expect(Validators.validateName('Alex', 'First Name'), isNull);
      expect(Validators.validateName('Mary-Jane', 'First Name'), isNull);
      expect(Validators.validateName("O'Connor", 'Surname'), isNull);
    });

    test('validateMobileNumber requires exactly 10 digits', () {
      expect(Validators.validateMobileNumber(null), 'Mobile number is required');
      expect(Validators.validateMobileNumber(''), 'Mobile number is required');
      expect(Validators.validateMobileNumber('12345'), 'Mobile number must be exactly 10 digits');
      expect(Validators.validateMobileNumber('12345678901'), 'Mobile number must be exactly 10 digits');
      expect(Validators.validateMobileNumber('98765abcde'), 'Mobile number must contain digits only');
      expect(Validators.validateMobileNumber('9876543210'), isNull);
    });

    test('validateEmail strictly checks email formats', () {
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('test@'), 'Please enter a valid email address');
      expect(Validators.validateEmail('test@domain'), 'Please enter a valid email address');
      expect(Validators.validateEmail('test@domain..com'), 'Please enter a valid email address');
      expect(Validators.validateEmail('valid.user@example.com'), isNull);
      expect(Validators.validateEmail('user_123@sub.domain.co'), isNull);
    });

    test('validatePassword and validateConfirmPassword work as expected', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword('123'), 'Password must be at least 6 characters long');
      expect(Validators.validatePassword('password123'), isNull);

      expect(Validators.validateConfirmPassword('pass1', 'pass2'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
    });
  });

  group('Authentication UI Tests', () {
    testWidgets('LoginScreen contains only Username and Password fields, no Google or Apple', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );

      // Verify Username (Email) and Password fields exist
      expect(find.text('Username (Email)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Verify Google and Apple buttons do NOT exist
      expect(find.text('Google'), findsNothing);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('OR'), findsNothing);
    });

    testWidgets('RegisterScreen contains Name, Surname, 10-digit Mobile, and Email fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Surname'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('HomeScreen header displays greeting and name without right-side avatar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(
            onNavigateToIdentify: () {},
            onNavigateToMyPlants: () {},
            onNavigateToReminders: () {},
          ),
        ),
      );

      expect(find.text('Welcome 👋'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      // Right-side CircleAvatar should not exist in the header
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('RegisterScreen validates 10-digit mobile number and strict email on submit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      // Check Terms & Conditions
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Enter invalid data
      await tester.enterText(find.byType(TextFormField).at(0), 'John'); // First Name
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe'); // Surname
      await tester.enterText(find.byType(TextFormField).at(2), '12345'); // Invalid 5-digit phone
      await tester.enterText(find.byType(TextFormField).at(3), 'bad-email'); // Invalid email
      await tester.enterText(find.byType(TextFormField).at(4), 'secret123'); // Password
      await tester.enterText(find.byType(TextFormField).at(5), 'secret123'); // Confirm password

      // Tap Create Account
      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Validation errors should be displayed
      expect(find.text('Mobile number must be exactly 10 digits'), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });

  group('Mobile & Laptop Responsiveness (Zero Overflow across all screens)', () {
    testWidgets('All primary screens render without RenderFlex overflow on small mobile viewport (360x640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. LoginScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 2. RegisterScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const RegisterScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 3. MainNavigationScreen (Tabs, Dock, and HomeScreen)
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const MainNavigationScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 4. MyPlantsScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const MyPlantsScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 5. RemindersScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const RemindersScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 6. ProfileScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const ProfileScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 7. SettingsScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 8. OnboardingScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const OnboardingScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 9. PlantDetailsScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: PlantDetailsScreen(plant: MockData.initialPlants.first)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('All primary screens render without RenderFlex overflow on laptop viewport (1280x800)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. LoginScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 2. RegisterScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const RegisterScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 3. MainNavigationScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const MainNavigationScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 4. MyPlantsScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const MyPlantsScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 5. PlantDetailsScreen
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: PlantDetailsScreen(plant: MockData.initialPlants.first)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
