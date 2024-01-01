class UserData {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String identifyID;
  final DateTime birthday;
  final bool isActive;
  final String? city;
  final String? job;

  UserData({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.identifyID,
    required this.birthday,
    required this.isActive,
    this.city,
    this.job,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number']?? '',
      identifyID: json['identify_ID']?? '',
      birthday: DateTime.parse(json['birthday']),
      isActive: json['active'],
      city: json['city']?? '',
      job: json['job']?? '',
    );
  }
}