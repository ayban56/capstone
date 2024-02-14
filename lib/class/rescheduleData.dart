class RescheduleData {
  final int branchId;
  final DateTime rescheduleDate;
  final doctorId;
  final appointmentId;
  final doctorName;

  RescheduleData({
    required this.doctorName,
    required this.branchId,
    required this.rescheduleDate,
    required this.doctorId,
    required this.appointmentId,
  });
}
