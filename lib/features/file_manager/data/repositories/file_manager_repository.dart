import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/file_manager/data/models/managed_file_model.dart';

class FileManagerRepository {
  final Dio _dio;
  FileManagerRepository(this._dio);

  Future<FileManagerPage> getFiles({int page = 1, int perPage = 20}) async {
    final response = await _dio.get(
      '/api/mobile/file-manager/files',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return FileManagerPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ManagedFile> uploadFile({
    required File file,
    required String mimeType,
    required void Function(double progress) onProgress,
    required CancelToken cancelToken,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
        contentType: MediaType.parse(mimeType),
      ),
    });

    final response = await _dio.post(
      '/api/mobile/file-manager/upload',
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    );

    final data = (response.data as Map<String, dynamic>)['data'];
    return ManagedFile.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteFile(int id) async {
    await _dio.delete('/api/mobile/file-manager/files/$id');
  }
}

final fileManagerRepositoryProvider = Provider<FileManagerRepository>(
  (ref) => FileManagerRepository(ref.read(apiClientProvider).dio),
);
