import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edveo/features/file_manager/data/models/managed_file_model.dart';
import 'package:edveo/features/file_manager/data/repositories/file_manager_repository.dart';

// ─── File list state ───────────────────────────────────────────────────────────

class FileManagerState {
  final List<ManagedFile> files;
  final StorageQuota? quota;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const FileManagerState({
    this.files = const [],
    this.quota,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  FileManagerState copyWith({
    List<ManagedFile>? files,
    StorageQuota? quota,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) =>
      FileManagerState(
        files:         files         ?? this.files,
        quota:         quota         ?? this.quota,
        isLoading:     isLoading     ?? this.isLoading,
        isLoadingMore: isLoadingMore  ?? this.isLoadingMore,
        hasMore:       hasMore        ?? this.hasMore,
        currentPage:   currentPage   ?? this.currentPage,
        error:         error,
      );
}

class FileManagerNotifier extends StateNotifier<FileManagerState> {
  final FileManagerRepository _repo;

  FileManagerNotifier(this._repo) : super(const FileManagerState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _repo.getFiles(page: 1);
      state = state.copyWith(
        files:       page.files,
        quota:       page.quota,
        isLoading:   false,
        hasMore:     page.hasMore,
        currentPage: 1,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: (e.response?.data as Map?)?['error']?['message'] as String?
            ?? 'Failed to load files.',
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load files.');
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _repo.getFiles(page: state.currentPage + 1);
      state = state.copyWith(
        files:         [...state.files, ...page.files],
        quota:         page.quota,
        isLoadingMore: false,
        hasMore:       page.hasMore,
        currentPage:   page.currentPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => load();

  void removeFile(int id) {
    state = state.copyWith(
      files: state.files.where((f) => f.id != id).toList(),
    );
    _refreshQuota();
  }

  Future<void> _refreshQuota() async {
    try {
      final page = await _repo.getFiles(page: 1, perPage: 1);
      state = state.copyWith(quota: page.quota);
    } catch (_) {}
  }
}

final fileManagerProvider =
    StateNotifierProvider.autoDispose<FileManagerNotifier, FileManagerState>(
  (ref) => FileManagerNotifier(ref.read(fileManagerRepositoryProvider)),
);

// ─── Upload state ──────────────────────────────────────────────────────────────

sealed class UploadState { const UploadState(); }
class UploadIdle      extends UploadState { const UploadIdle(); }
class UploadActive    extends UploadState {
  final double progress;
  const UploadActive(this.progress);
}
class UploadSuccess   extends UploadState {
  final ManagedFile file;
  const UploadSuccess(this.file);
}
class UploadError     extends UploadState {
  final String message;
  final bool isQuotaExceeded;
  const UploadError({required this.message, this.isQuotaExceeded = false});
}
class UploadCancelled extends UploadState { const UploadCancelled(); }

class UploadNotifier extends StateNotifier<UploadState> {
  final FileManagerRepository _repo;
  CancelToken _cancelToken = CancelToken();

  UploadNotifier(this._repo) : super(const UploadIdle());

  Future<void> upload({required File file, required String mimeType}) async {
    _cancelToken = CancelToken();
    state = const UploadActive(0.0);
    try {
      final uploaded = await _repo.uploadFile(
        file:        file,
        mimeType:    mimeType,
        cancelToken: _cancelToken,
        onProgress:  (p) => state = UploadActive(p),
      );
      state = UploadSuccess(uploaded);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = const UploadCancelled();
        return;
      }
      final error = (e.response?.data as Map?)?['error'] as Map?;
      final code  = error?['code'] as String?;
      final msg   = error?['message'] as String? ?? 'Upload failed. Please try again.';
      state = UploadError(message: msg, isQuotaExceeded: code == 'QUOTA_EXCEEDED');
    } catch (_) {
      state = const UploadError(message: 'Upload failed. Please try again.');
    }
  }

  void cancel() => _cancelToken.cancel('User cancelled');

  void reset() => state = const UploadIdle();
}

final uploadProvider =
    StateNotifierProvider.autoDispose<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(ref.read(fileManagerRepositoryProvider)),
);

// ─── Delete state ──────────────────────────────────────────────────────────────

sealed class DeleteState { const DeleteState(); }
class DeleteIdle    extends DeleteState { const DeleteIdle(); }
class DeleteLoading extends DeleteState { const DeleteLoading(); }
class DeleteSuccess extends DeleteState { const DeleteSuccess(); }
class DeleteError   extends DeleteState {
  final String message;
  const DeleteError(this.message);
}

class DeleteNotifier extends StateNotifier<DeleteState> {
  final FileManagerRepository _repo;
  DeleteNotifier(this._repo) : super(const DeleteIdle());

  Future<void> delete(int id) async {
    state = const DeleteLoading();
    try {
      await _repo.deleteFile(id);
      state = const DeleteSuccess();
    } on DioException catch (e) {
      state = DeleteError(
        (e.response?.data as Map?)?['error']?['message'] as String?
            ?? 'Failed to delete file.',
      );
    } catch (_) {
      state = const DeleteError('Failed to delete file.');
    }
  }

  void reset() => state = const DeleteIdle();
}

final deleteProvider =
    StateNotifierProvider.autoDispose<DeleteNotifier, DeleteState>(
  (ref) => DeleteNotifier(ref.read(fileManagerRepositoryProvider)),
);
