enum ManagedFileType { image, document, unknown }

class ManagedFile {
  final int id;
  final String name;
  final ManagedFileType fileType;
  final String mimeType;
  final int sizeBytes;
  final String sizeFormatted;
  final String? previewUrl;
  final DateTime createdAt;

  const ManagedFile({
    required this.id,
    required this.name,
    required this.fileType,
    required this.mimeType,
    required this.sizeBytes,
    required this.sizeFormatted,
    this.previewUrl,
    required this.createdAt,
  });

  factory ManagedFile.fromJson(Map<String, dynamic> json) => ManagedFile(
        id:           json['id'] as int,
        name:         json['name'] as String,
        fileType:     _parseType(json['file_type'] as String?),
        mimeType:     json['mime_type'] as String,
        sizeBytes:    json['size_bytes'] as int,
        sizeFormatted: json['size_formatted'] as String,
        previewUrl:   json['preview_url'] as String?,
        createdAt:    DateTime.parse(json['created_at'] as String),
      );

  static ManagedFileType _parseType(String? raw) => switch (raw) {
        'image'    => ManagedFileType.image,
        'document' => ManagedFileType.document,
        _          => ManagedFileType.unknown,
      };
}

class StorageQuota {
  final int usedBytes;
  final int totalBytes;
  final String usedFormatted;
  final String totalFormatted;
  final int percentageUsed;

  const StorageQuota({
    required this.usedBytes,
    required this.totalBytes,
    required this.usedFormatted,
    required this.totalFormatted,
    required this.percentageUsed,
  });

  factory StorageQuota.fromJson(Map<String, dynamic> json) => StorageQuota(
        usedBytes:       json['used_bytes'] as int,
        totalBytes:      json['total_bytes'] as int,
        usedFormatted:   json['used_formatted'] as String,
        totalFormatted:  json['total_formatted'] as String,
        percentageUsed:  json['percentage_used'] as int,
      );

  double get fraction =>
      totalBytes > 0 ? (usedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

  bool get isNearLimit => percentageUsed >= 80;
  bool get isAtLimit   => percentageUsed >= 100;
}

class FileManagerPage {
  final List<ManagedFile> files;
  final StorageQuota quota;
  final int currentPage;
  final int lastPage;
  final int total;

  const FileManagerPage({
    required this.files,
    required this.quota,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory FileManagerPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    return FileManagerPage(
      files: (data['files'] as List<dynamic>)
          .map((e) => ManagedFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      quota:       StorageQuota.fromJson(data['quota'] as Map<String, dynamic>),
      currentPage: meta['current_page'] as int,
      lastPage:    meta['last_page'] as int,
      total:       meta['total'] as int,
    );
  }
}
