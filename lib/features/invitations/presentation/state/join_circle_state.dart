import '../../../circles/domain/entities/join_preview.dart';
import 'join_circle_status.dart';

class JoinCircleState {
  const JoinCircleState({required this.status, this.preview, this.message});

  final JoinCircleStatus status;
  final JoinPreview? preview;
  final String? message;
}
