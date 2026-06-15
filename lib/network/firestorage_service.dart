import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage wrapper. Kept under the original file/class name to
/// avoid touching every controller import.
class FireStorageService {
  FireStorageService._();
  static final instance = FireStorageService._();

  static const _bucket = 'avatars';

  SupabaseClient get _client => Supabase.instance.client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Storage called without an authenticated user.');
    }
    return id;
  }

  Future<bool> deleteFile(String fileName) async {
    try {
      await _client.storage.from(_bucket).remove(['$_uid/$fileName']);
      return true;
    } catch (e) {
      debugPrint('deleteFile failed: $e');
      return false;
    }
  }

  Future<String> uploadImage(File file) async {
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}-${p.basename(file.path)}';
    final path = '$_uid/$filename';
    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }
}
