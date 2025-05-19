import 'package:equatable/equatable.dart';

class Recording extends Equatable {
  final String id;
  final String filePath;
  final DateTime recordedAt;
  final int durationInSeconds;
  final String fileName;

  const Recording({
    required this.id,
    required this.filePath,
    required this.recordedAt,
    required this.durationInSeconds,
    required this.fileName,
  });

  @override
  List<Object?> get props => [
    id,
    filePath,
    recordedAt,
    durationInSeconds,
    fileName,
  ];
}
