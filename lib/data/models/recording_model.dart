import '../../domain/entities/recording.dart';

class RecordingModel extends Recording {
  const RecordingModel({
    required super.id,
    required super.filePath,
    required super.recordedAt,
    required super.durationInSeconds,
    required super.fileName,
  });

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'],
      filePath: json['filePath'],
      recordedAt: DateTime.parse(json['recordedAt']),
      durationInSeconds: json['durationInSeconds'],
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'recordedAt': recordedAt.toIso8601String(),
      'durationInSeconds': durationInSeconds,
      'fileName': fileName,
    };
  }

  factory RecordingModel.fromEntity(Recording recording) {
    return RecordingModel(
      id: recording.id,
      filePath: recording.filePath,
      recordedAt: recording.recordedAt,
      durationInSeconds: recording.durationInSeconds,
      fileName: recording.fileName,
    );
  }
}
