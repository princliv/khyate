import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Helper class to convert Flutter assets to File objects
/// Note: On web, File operations are not supported. This returns null on web.
class AssetToFileHelper {
  /// Converts an asset to a File object
  /// Returns null if conversion fails or on web platform (web doesn't support File operations)
  /// On web, use the bytes directly or convert to base64 for upload
  static Future<File?> assetToFile(String assetPath, {String? fileName}) async {
    try {
      // On web, File operations are not supported - return null gracefully
      if (kIsWeb) {
        print('Warning: assetToFile is not supported on web platform. Use asset bytes directly or provide an image URL instead.');
        return null;
      }
      
      // Load asset bytes
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      
      // Try to get a temp directory
      Directory? tempDir;
      
      // Method 1: Try path_provider
      try {
        tempDir = await getTemporaryDirectory();
      } catch (e) {
        // Method 2: Try system temp
        try {
          tempDir = Directory.systemTemp;
        } catch (e2) {
          // Method 3: Try current directory
          try {
            tempDir = Directory.current;
          } catch (e3) {
            // Method 4: Try user home directory
            try {
              final home = Platform.environment['HOME'] ?? 
                          Platform.environment['USERPROFILE'] ?? 
                          Platform.environment['TEMP'] ?? 
                          Platform.environment['TMP'];
              if (home != null) {
                tempDir = Directory(home);
              }
            } catch (e4) {
              // Last resort: use a simple temp file in current directory
              final simpleFile = File(fileName ?? 'temp_${DateTime.now().millisecondsSinceEpoch}.webp');
              await simpleFile.writeAsBytes(bytes);
              return simpleFile;
            }
          }
        }
      }
      
      // Ensure directory exists
      if (tempDir != null) {
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }
        
        // Create file with unique name
        final uniqueFileName = fileName ?? 
            '${path.basenameWithoutExtension(assetPath)}_${DateTime.now().millisecondsSinceEpoch}${path.extension(assetPath)}';
        final file = File(path.join(tempDir.path, uniqueFileName));
        
        // Write bytes to file
        await file.writeAsBytes(bytes);
        
        return file;
      }
      
      // If we get here, all methods failed - try simple file
      final simpleFile = File(fileName ?? 'temp_${DateTime.now().millisecondsSinceEpoch}.webp');
      await simpleFile.writeAsBytes(bytes);
      return simpleFile;
      
    } catch (e) {
      print('Error converting asset to file: $e');
      return null;
    }
  }
  
  /// Gets asset bytes directly (works on all platforms including web)
  /// Use this on web instead of assetToFile when you need the bytes
  static Future<Uint8List?> assetToBytes(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error loading asset bytes: $e');
      return null;
    }
  }
}
