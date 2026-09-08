class TrackingEvent {
  final String id;
  final String containerNumber;
  final String status;
  final String location;
  final DateTime timestamp;
  final String description;

  const TrackingEvent({
    required this.id,
    required this.containerNumber,
    required this.status,
    required this.location,
    required this.timestamp,
    required this.description,
  });

  factory TrackingEvent.fromMap(Map<String, dynamic> map, String docId) {
    return TrackingEvent(
      id: docId,
      containerNumber: map['containerNumber'] as String? ?? '',
      status: map['status'] as String? ?? '',
      location: map['location'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'].toString())
          : DateTime.now(),
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'containerNumber': containerNumber,
      'status': status,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }
}
