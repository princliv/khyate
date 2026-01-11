import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    await prefs.remove('user_role_id');
    await prefs.remove('user_role_name');
  }
  
  // Save user role
  static Future<void> saveUserRole(int roleId, String roleName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_role_id', roleId);
    await prefs.setString('user_role_name', roleName);
  }
  
  // Get user role ID
  static Future<int?> getUserRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_role_id');
  }
  
  // Get user role name
  static Future<String?> getUserRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role_name');
  }
  
  // Check if user is admin (role_id 1 or 6)
  static Future<bool> isAdmin() async {
    final roleId = await getUserRoleId();
    return roleId == 1 || roleId == 6;
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
  
  // Helper function to ensure proper Dart Map conversion for Flutter web
  static Map<String, dynamic> _ensureDartMap(dynamic decoded) {
    if (decoded is Map) {
      // Recursively convert nested maps and lists
      return decoded.map<String, dynamic>((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _ensureDartMap(value));
        } else if (value is List) {
          return MapEntry(key.toString(), value.map((item) {
            if (item is Map) {
              return _ensureDartMap(item);
            }
            return item;
          }).toList());
        }
        return MapEntry(key.toString(), value);
      });
    }
    return <String, dynamic>{};
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
        final decoded = jsonDecode(responseBody);
        data = _ensureDartMap(decoded);
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
      
      print('API GET Request: $uri');
      
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout: Server did not respond within 30 seconds');
        },
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
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
    } on http.ClientException catch (e) {
      // Network/connection errors
      print('Network error: ${e.toString()}');
      return {
        'success': false,
        'error': 'Cannot connect to server. Please ensure the backend is running on http://localhost:5000. Error: ${e.message}',
      };
    } on Exception catch (e) {
      // Timeout and other exceptions
      print('Request exception: ${e.toString()}');
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') || 
          errorMsg.contains('Connection refused') ||
          errorMsg.contains('Network is unreachable')) {
        return {
          'success': false,
          'error': 'Cannot connect to server. Please ensure the backend server is running on http://localhost:5000',
        };
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    } catch (e) {
      // Catch any other errors
      print('Unexpected error: ${e.toString()}');
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
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

  // PATCH request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http.patch(
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
  
  // Multipart POST request for file uploads
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, File>? files,
    bool requireAuth = false,
  }) async {
    try {
      final token = requireAuth ? await getToken() : null;
      
      var request = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add text fields
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            final fileStream = http.ByteStream(file.openRead());
            final fileLength = await file.length();
            final contentType = _getContentType(file.path);
            final multipartFile = http.MultipartFile(
              entry.key,
              fileStream,
              fileLength,
              filename: file.path.split(Platform.pathSeparator).last,
              contentType: contentType,
            );
            request.files.add(multipartFile);
          }
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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
        // Extract actual data if backend wraps it in ApiResponse format
        // Backend returns: { statusCode, data: {...}, message, success }
        final actualData = (data is Map && data['data'] != null) 
            ? data['data'] 
            : data;
        
        return {
          'success': true,
          'data': actualData,
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
  
  // Multipart PUT request for file uploads
  static Future<Map<String, dynamic>> putMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, File>? files,
    bool requireAuth = false,
  }) async {
    try {
      final token = requireAuth ? await getToken() : null;
      
      var request = http.MultipartRequest('PUT', Uri.parse(endpoint));
      
      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add text fields
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            final fileStream = http.ByteStream(file.openRead());
            final fileLength = await file.length();
            final contentType = _getContentType(file.path);
            final multipartFile = http.MultipartFile(
              entry.key,
              fileStream,
              fileLength,
              filename: file.path.split(Platform.pathSeparator).last,
              contentType: contentType,
            );
            request.files.add(multipartFile);
          }
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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
        // Extract actual data if backend wraps it in ApiResponse format
        // Backend returns: { statusCode, data: {...}, message, success }
        final actualData = (data is Map && data['data'] != null) 
            ? data['data'] 
            : data;
        
        return {
          'success': true,
          'data': actualData,
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
  
  // Multipart PATCH request for file uploads
  static Future<Map<String, dynamic>> patchMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, File>? files,
    bool requireAuth = false,
  }) async {
    try {
      final token = requireAuth ? await getToken() : null;
      
      var request = http.MultipartRequest('PATCH', Uri.parse(endpoint));
      
      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add text fields
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            final fileStream = http.ByteStream(file.openRead());
            final fileLength = await file.length();
            final contentType = _getContentType(file.path);
            final multipartFile = http.MultipartFile(
              entry.key,
              fileStream,
              fileLength,
              filename: file.path.split(Platform.pathSeparator).last,
              contentType: contentType,
            );
            request.files.add(multipartFile);
          }
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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
        // Extract actual data if backend wraps it in ApiResponse format
        // Backend returns: { statusCode, data: {...}, message, success }
        final actualData = (data is Map && data['data'] != null) 
            ? data['data'] 
            : data;
        
        return {
          'success': true,
          'data': actualData,
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
  
  // Helper method to determine content type from file extension
  static MediaType _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}

