// lib/services/user_role_service.dart
class UserRoleService {
  static final UserRoleService _instance = UserRoleService._internal();
  factory UserRoleService() => _instance;
  UserRoleService._internal();

  String _role = 'student';
  String _institutionId = '';
  String _institutionName = '';
  String _userType = 'student'; // student, institution, buyer
  String _userName = ''; // stores full name from registration

  // Onboarding questionnaire answers
  String _fundingType =
      ''; // 'NSFAS', 'Bursary', 'Hustle / Side Income', 'Family Support'
  double _monthlyIncome = 0; // e.g. 3500.0
  String _livingType = ''; // 'Residence / Digs', 'Living at Home', 'Renting'
  List<String> _painPoints = []; // e.g. ['Food', 'Transport']

  // Existing getters/setters
  String get role => _role;
  set role(String value) => _role = value;

  String get institutionId => _institutionId;
  set institutionId(String value) => _institutionId = value;

  String get institutionName => _institutionName;
  set institutionName(String value) => _institutionName = value;

  String get userType => _userType;
  set userType(String value) => _userType = value;

  String get userName => _userName;
  set userName(String value) => _userName = value;

  // Onboarding getters/setters
  String get fundingType => _fundingType;
  set fundingType(String value) => _fundingType = value;

  double get monthlyIncome => _monthlyIncome;
  set monthlyIncome(double value) => _monthlyIncome = value;

  String get livingType => _livingType;
  set livingType(String value) => _livingType = value;

  List<String> get painPoints => _painPoints;
  set painPoints(List<String> value) => _painPoints = value;

  // Convenience booleans
  bool get isInstitution => _userType == 'institution';
  bool get isStudent => _userType == 'student';
  bool get isBuyer => _userType == 'buyer';

  // Whether the user has completed onboarding
  bool get hasCompletedOnboarding =>
      _fundingType.isNotEmpty && _livingType.isNotEmpty;

  void clear() {
    _role = 'student';
    _institutionId = '';
    _institutionName = '';
    _userType = 'student';
    _userName = '';
    _fundingType = '';
    _monthlyIncome = 0;
    _livingType = '';
    _painPoints = [];
  }
}
