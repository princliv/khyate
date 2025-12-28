import 'api_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Register new user
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String userRole, // "customer" or "trainer"
    required String country, // Country ID (ObjectId)
    required String city,
    required String gender,
    required String address,
    required String emiratesId,
    required int age,
    String? profileImage,
    String? fitnessGoals,
    String? uid, // Firebase UID if using social auth
  }) async {
    try {
      final payload = {
        'email': email,
        'password': password,
        'user_role': userRole,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'country': country, // This should be country ID (ObjectId)
        'city': city,
        'gender': gender,
        'address': address,
        'emirates_id': emiratesId,
        'age': age.toString(), // API expects string
        if (profileImage != null && profileImage.isNotEmpty) 'profile_image': profileImage,
        if (fitnessGoals != null && fitnessGoals.isNotEmpty) 'fitness_goals': fitnessGoals,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
      };
      
      final response = await ApiService.post(
        '$baseUrl/auth/register',
        payload,
        requireAuth: false, // Registration doesn't need auth
      );
      
      if (response['success'] == true) {
        // Save token if provided
        final data = response['data'];
        if (data != null) {
          // Check for different possible token field names
          final token = data['accessToken'] ?? 
                       data['access_token'] ?? 
                       data['token'] ?? 
                       data['data']?['accessToken'] ??
                       data['data']?['access_token'];
          
          if (token != null) {
            await ApiService.saveToken(token);
          }
        }
        return data;
      } else {
        throw Exception(response['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Login user
  Future<Map<String, dynamic>?> signIn(
    String emailOrPhone,
    String password, {
    String? provider, // "google" or "apple"
    String? uid, // Firebase UID if using social auth
  }) async {
    try {
      final payload = {
        'emailOrPhone': emailOrPhone,
        'password': password,
        if (provider != null && provider.isNotEmpty) 'provider': provider,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
      };
      
      final response = await ApiService.post(
        '$baseUrl/auth/login/3', // 3 = customer role
        payload,
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          // Check for different possible token field names
          final token = data['accessToken'] ?? 
                       data['access_token'] ?? 
                       data['token'] ?? 
                       data['data']?['accessToken'] ??
                       data['data']?['access_token'];
          
          if (token != null) {
            await ApiService.saveToken(token);
          }
        }
        return data;
      } else {
        throw Exception(response['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // 1. Get Firebase UID from Google Sign-In
    // 2. Call signIn with provider: "google" and uid: firebaseUID
    // For now, throw error to indicate it needs implementation
    throw UnimplementedError('Please implement Google Sign-In first. You need to integrate Firebase Auth and get the UID, then call signIn with provider: "google"');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await ApiService.post(
        '$baseUrl/auth/logout',
        {},
        requireAuth: true,
      );
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout error: $e');
    } finally {
      await ApiService.removeToken();
    }
  }

  // Phone OTP verification
  Future<void> verifyPhoneNumber({
    required String phone,
    required Function(String) codeSent,
    required Function(Map<String, dynamic>?) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/generate-otp',
        {'phone': phone},
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        // Backend should return verification ID or OTP
        final data = response['data'];
        final verificationId = data?['verificationId'] ?? 
                              data?['verification_id'] ?? 
                              data?['otpId'] ??
                              '';
        if (verificationId.isNotEmpty) {
          codeSent(verificationId);
        } else {
          onError('Verification ID not received from server');
        }
      } else {
        onError(response['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // Sign in with OTP
  Future<Map<String, dynamic>?> signInWithOTP(String verificationId, String smsCode) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/verify-otp',
        {
          'verificationId': verificationId,
          'otp': smsCode,
        },
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          // Check for different possible token field names
          final token = data['accessToken'] ?? 
                       data['access_token'] ?? 
                       data['token'] ?? 
                       data['data']?['accessToken'] ??
                       data['data']?['access_token'];
          
          if (token != null) {
            await ApiService.saveToken(token);
          }
        }
        return data;
      } else {
        throw Exception(response['error'] ?? 'OTP verification failed');
      }
    } catch (e) {
      throw Exception('OTP verification error: ${e.toString()}');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/reset-password',
        {'email': email},
        requireAuth: false,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Reset password error: ${e.toString()}');
    }
  }
  
  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/auth/current-user',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get user');
      }
    } catch (e) {
      throw Exception('Get user error: ${e.toString()}');
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
