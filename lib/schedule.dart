class Schedule {
  String? id;
  String time;
  List<bool> days;
  String action;
  bool isOn;
  List<bool> relays;
  bool isOnAction;

  Schedule({
    this.id,
    required this.time,
    required this.days,
    required this.action,
    required this.isOn,
    required this.relays,
    required this.isOnAction,
  });

  // Hàm tạo từ Map nếu cần
  factory Schedule.fromMap(Map<String, dynamic> data, String id) {
    return Schedule(
      time: data['time'],
      days: List<bool>.from(data['days']),
      action: data['action'],
      isOn: data['isOn'],
      relays: List<bool>.from(data['relays']),
      isOnAction: data['isOnAction'],
    );
  }

  // Hàm sao chép đối tượng với giá trị thay đổi
  Schedule copyWith({
    String? id,
    String? time,
    List<bool>? days,
    String? action,
    bool? isOn,
    List<bool>? relays,
    bool? isOnAction,
  }) {
    return Schedule(
      id: id ?? this.id,
      time: time ?? this.time,
      days: days ?? this.days,
      action: action ?? this.action,
      isOn: isOn ?? this.isOn,
      relays: relays ?? this.relays,
      isOnAction: isOnAction ?? this.isOnAction,
    );
  }
}

class ScheduleG {
  final String id;
  final String time;
  final String code;
  
  ScheduleG({
    required this.id,
    required this.code,
    required this.time,
  });

  factory ScheduleG.fromJson(Map<String, dynamic> json) {
    return ScheduleG(
      id: json['id'],
      time: json['time'],
      code: json['code'],
    );
  }
}
