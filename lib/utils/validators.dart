/// Utility class containing form field validators.
class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a first name or surname.
  static String? validateName(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    final nameRegExp = RegExp(r"^[a-zA-Z\s'-]+$");
    if (!nameRegExp.hasMatch(trimmed)) {
      return '$fieldName must contain letters only';
    }
    return null;
  }

  /// Validates a 10-digit mobile phone number.
  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return 'Mobile number must contain digits only';
    }
    if (trimmed.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }
    return null;
  }

  /// Strictly validates standard email addresses.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(trimmed) || trimmed.contains('..')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
