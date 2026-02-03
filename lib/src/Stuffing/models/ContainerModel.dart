import 'dart:async';

class StuffingContainerModel {
  final int id;
  final int? destuffId;
  final String? containerNumber;
  final String? sealNumber;
  final String? customerStatus;
  final String? origin;

  // 🕒 UI-only fields for stopwatch
  bool isRunning;
  bool isPaused;
  Duration elapsed;
  Timer? timer;

  StuffingContainerModel({
    required this.id,
    this.destuffId,
    this.containerNumber,
    this.sealNumber,
    this.customerStatus,
    this.origin,

    // defaults for stopwatch
    this.isRunning = false,
    this.isPaused = false,
    this.elapsed = Duration.zero,
    this.timer,
  });

  factory StuffingContainerModel.fromJson(Map<String, dynamic> json) {
    return StuffingContainerModel(
      id: json['id'],
      destuffId: json['destuff_id'] != null ? json['destuff_id'] : null,
      containerNumber:
          json['container_number'] != false ? json['container_number'] : null,
      sealNumber: json['seal_number'] != false ? json['seal_number'] : null,
      customerStatus:
          json['responsible_user_id'] != false
              ? json['responsible_user_id'][1]
              : null,
      origin: json['origin_id'] != false ? json['origin_id'][1] : null,

      // 🕒 UI fields initialized here automatically
      isRunning: false,
      isPaused: false,
      elapsed: Duration.zero,
      timer: null,
    );
  }
}
