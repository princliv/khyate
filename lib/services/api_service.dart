import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Get stored JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Save JWT token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Remove token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers with authentication
  static Future<Map<String, String>> getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      
      final responseBody = response.body;
      Map<String, dynamic> data;
      
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        // If response is not JSON, return raw response
        return {
          'success': false,
          'error': responseBody.isNotEmpty ? responseBody : 'Invalid response format',
          'statusCode': response.statusCode,
        };
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? data['msg'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      Uri uri = Uri.parse(endpoint);
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await http.get(uri, headers: headers);
      
      final responseBody = response.body;
      Map<String, dynamic> data;
      
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        return {
          'success': false,
          'error': responseBody.isNotEmpty ? responseBody : 'Invalid response format',
          'statusCode': response.statusCode,
        };
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? data['msg'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      
      final responseBody = response.body;
      Map<String, dynamic> data;
      
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        return {
          'success': false,
          'error': responseBody.isNotEmpty ? responseBody : 'Invalid response format',
          'statusCode': response.statusCode,
        };
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? data['msg'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      );
      
      final responseBody = response.body;
      Map<String, dynamic> data;
      
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        return {
          'success': false,
          'error': responseBody.isNotEmpty ? responseBody : 'Invalid response format',
          'statusCode': response.statusCode,
        };
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? data['msg'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

