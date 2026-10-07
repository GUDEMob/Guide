import 'package:flutter/foundation.dart';
import 'package:gude_app/services/user_role_service.dart';

enum CommunityPostType { announcement, event, survey }

enum RequestPriority { low, medium, high }

enum AccommodationFundingType { private, bursary, nsfas, other }

extension AccommodationFundingTypeLabel on AccommodationFundingType {
  String get label => switch (this) {
        AccommodationFundingType.private => 'Private',
        AccommodationFundingType.bursary => 'Bursaries',
        AccommodationFundingType.nsfas => 'NSFAS',
        AccommodationFundingType.other => 'Other',
      };
}

class AccommodationStudent {
  final String id;
  final String name;
  final String studentNumber;
  final String institution;
  final AccommodationFundingType fundingType;

  const AccommodationStudent({
    required this.id,
    required this.name,
    required this.studentNumber,
    required this.institution,
    required this.fundingType,
  });
}

class AccommodationBed {
  final String id;
  final String residence;
  final String room;
  final String bedNumber;
  final String city;
  final AccommodationStudent? student;

  const AccommodationBed({
    required this.id,
    required this.residence,
    required this.room,
    required this.bedNumber,
    required this.city,
    this.student,
  });

  bool get occupied => student != null;
  String get location => '$residence, $city';

  AccommodationBed copyWith({
    AccommodationStudent? student,
    bool clearStudent = false,
  }) {
    return AccommodationBed(
      id: id,
      residence: residence,
      room: room,
      bedNumber: bedNumber,
      city: city,
      student: clearStudent ? null : student ?? this.student,
    );
  }
}

class CommunityPost {
  final String id;
  final String title;
  final String detail;
  final String audience;
  final CommunityPostType type;
  final String published;
  final int engagement;
  final bool isPinned;

  const CommunityPost({
    required this.id,
    required this.title,
    required this.detail,
    required this.audience,
    required this.type,
    required this.published,
    this.engagement = 0,
    this.isPinned = false,
  });

  CommunityPost copyWith({bool? isPinned}) {
    return CommunityPost(
      id: id,
      title: title,
      detail: detail,
      audience: audience,
      type: type,
      published: published,
      engagement: engagement,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class ResidenceOpportunity {
  final String id;
  final String title;
  final String pay;
  final String schedule;
  final String residence;
  final int applicants;
  final int views;
  final bool isOpen;

  const ResidenceOpportunity({
    required this.id,
    required this.title,
    required this.pay,
    required this.schedule,
    required this.residence,
    this.applicants = 0,
    this.views = 0,
    this.isOpen = true,
  });

  ResidenceOpportunity copyWith({bool? isOpen}) {
    return ResidenceOpportunity(
      id: id,
      title: title,
      pay: pay,
      schedule: schedule,
      residence: residence,
      applicants: applicants,
      views: views,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class ResidentRequest {
  final String id;
  final String title;
  final String category;
  final String residence;
  final String student;
  final String age;
  final RequestPriority priority;
  final bool resolved;

  const ResidentRequest({
    required this.id,
    required this.title,
    required this.category,
    required this.residence,
    required this.student,
    required this.age,
    required this.priority,
    this.resolved = false,
  });

  ResidentRequest copyWith({bool? resolved}) {
    return ResidentRequest(
      id: id,
      title: title,
      category: category,
      residence: residence,
      student: student,
      age: age,
      priority: priority,
      resolved: resolved ?? this.resolved,
    );
  }
}

class AccommodationPortalStore extends ChangeNotifier {
  AccommodationPortalStore._() {
    _seedBeds();
  }

  static final AccommodationPortalStore instance = AccommodationPortalStore._();

  String providerName = 'Urban Student Living';
  String contactEmail = 'manager@urbanstudent.co.za';
  String contactPerson = 'Residence Operations';
  String city = 'Johannesburg';
  final List<String> residences = ['Braam House', 'Auckland Park Studios'];
  final List<AccommodationBed> beds = [];

  final List<CommunityPost> communityPosts = [
    const CommunityPost(
      id: 'community-1',
      title: 'September residence meeting',
      detail:
          'Join the residence team in the common room on Thursday at 18:00.',
      audience: 'All residents',
      type: CommunityPostType.event,
      published: 'Today, 09:15',
      engagement: 84,
    ),
    const CommunityPost(
      id: 'community-2',
      title: 'Exam transport survey',
      detail: 'Tell us which evening shuttle times would help during exams.',
      audience: 'Braam House',
      type: CommunityPostType.survey,
      published: 'Yesterday',
      engagement: 126,
    ),
    const CommunityPost(
      id: 'community-3',
      title: 'Water interruption notice',
      detail: 'Maintenance is scheduled from 10:00 to 13:00 on Saturday.',
      audience: 'Auckland Park Studios',
      type: CommunityPostType.announcement,
      published: '2 days ago',
      engagement: 211,
    ),
  ];

  final List<ResidenceOpportunity> opportunities = [
    const ResidenceOpportunity(
      id: 'opportunity-1',
      title: 'Residence Ambassador',
      pay: 'R1 500/month',
      schedule: '6 hours/week',
      residence: 'Braam House',
      applicants: 18,
      views: 246,
    ),
    const ResidenceOpportunity(
      id: 'opportunity-2',
      title: 'Weekend Event Assistant',
      pay: 'R350/event',
      schedule: 'Weekends',
      residence: 'All residences',
      applicants: 11,
      views: 174,
    ),
    const ResidenceOpportunity(
      id: 'opportunity-3',
      title: 'Peer Study Coordinator',
      pay: 'R90/hour',
      schedule: 'Flexible',
      residence: 'Auckland Park Studios',
      applicants: 7,
      views: 98,
    ),
  ];

  final List<ResidentRequest> requests = [
    const ResidentRequest(
      id: 'request-1',
      title: 'Laundry machine not starting',
      category: 'Maintenance',
      residence: 'Braam House',
      student: 'Resident BH-214',
      age: '24 min ago',
      priority: RequestPriority.high,
    ),
    const ResidentRequest(
      id: 'request-2',
      title: 'Need proof of residence letter',
      category: 'Administration',
      residence: 'Auckland Park Studios',
      student: 'Resident AP-088',
      age: '2 hours ago',
      priority: RequestPriority.medium,
    ),
    const ResidentRequest(
      id: 'request-3',
      title: 'Request for a quiet study room',
      category: 'Student support',
      residence: 'Braam House',
      student: 'Resident BH-031',
      age: 'Yesterday',
      priority: RequestPriority.low,
    ),
  ];

  int get totalBedCount => beds.length;
  int get occupiedBedCount => beds.where((bed) => bed.occupied).length;
  int get availableBedCount => totalBedCount - occupiedBedCount;
  int get residentCount => occupiedBedCount;
  int get occupancyRate => totalBedCount == 0
      ? 0
      : ((occupiedBedCount / totalBedCount) * 100).round();
  List<AccommodationBed> get occupiedBeds =>
      beds.where((bed) => bed.occupied).toList(growable: false);
  List<AccommodationBed> get availableBeds =>
      beds.where((bed) => !bed.occupied).toList(growable: false);
  Map<AccommodationFundingType, int> get fundingBreakdown {
    final values = {
      for (final type in AccommodationFundingType.values) type: 0,
    };
    for (final bed in occupiedBeds) {
      final funding = bed.student!.fundingType;
      values[funding] = values[funding]! + 1;
    }
    return values;
  }

  Map<String, int> get availableBedsByResidence {
    final values = <String, int>{};
    for (final bed in availableBeds) {
      values[bed.location] = (values[bed.location] ?? 0) + 1;
    }
    return values;
  }

  int get engagementRate => 68;
  int get openOpportunityCount =>
      opportunities.where((item) => item.isOpen).length;
  int get openRequestCount => requests.where((item) => !item.resolved).length;
  int get totalApplicants =>
      opportunities.fold(0, (total, item) => total + item.applicants);

  void hydrateProviderName() {
    final savedName = UserRoleService().institutionName.trim();
    if (savedName.isNotEmpty && savedName != providerName) {
      providerName = savedName;
    }
  }

  void publishCommunityPost({
    required String title,
    required String detail,
    required String audience,
    required CommunityPostType type,
  }) {
    communityPosts.insert(
      0,
      CommunityPost(
        id: 'community-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        detail: detail,
        audience: audience,
        type: type,
        published: 'Just now',
      ),
    );
    notifyListeners();
  }

  void createOpportunity({
    required String title,
    required String pay,
    required String schedule,
    required String residence,
  }) {
    opportunities.insert(
      0,
      ResidenceOpportunity(
        id: 'opportunity-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        pay: pay,
        schedule: schedule,
        residence: residence,
      ),
    );
    notifyListeners();
  }

  void setOpportunityOpen(String id, bool isOpen) {
    final index = opportunities.indexWhere((item) => item.id == id);
    if (index < 0) return;
    opportunities[index] = opportunities[index].copyWith(isOpen: isOpen);
    notifyListeners();
  }

  void resolveRequest(String id) {
    final index = requests.indexWhere((item) => item.id == id);
    if (index < 0) return;
    requests[index] = requests[index].copyWith(resolved: true);
    notifyListeners();
  }

  void reopenRequest(String id) {
    final index = requests.indexWhere((item) => item.id == id);
    if (index < 0) return;
    requests[index] = requests[index].copyWith(resolved: false);
    notifyListeners();
  }

  void toggleCommunityPostPinned(String id) {
    final index = communityPosts.indexWhere((item) => item.id == id);
    if (index < 0) return;
    communityPosts[index] = communityPosts[index].copyWith(
      isPinned: !communityPosts[index].isPinned,
    );
    notifyListeners();
  }

  void assignStudentToBed({
    required String bedId,
    required String name,
    required String studentNumber,
    required String institution,
    required AccommodationFundingType fundingType,
  }) {
    final index = beds.indexWhere((bed) => bed.id == bedId);
    if (index < 0 || beds[index].occupied) return;
    beds[index] = beds[index].copyWith(
      student: AccommodationStudent(
        id: 'resident-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        studentNumber: studentNumber.trim(),
        institution: institution.trim(),
        fundingType: fundingType,
      ),
    );
    notifyListeners();
  }

  void vacateBed(String bedId) {
    final index = beds.indexWhere((bed) => bed.id == bedId);
    if (index < 0 || !beds[index].occupied) return;
    beds[index] = beds[index].copyWith(clearStudent: true);
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String contact,
    required String location,
  }) {
    providerName = name;
    contactEmail = email;
    contactPerson = contact;
    city = location;
    UserRoleService().institutionName = name;
    notifyListeners();
  }

  void _seedBeds() {
    if (beds.isNotEmpty) return;
    const residenceData = [
      ('Braam House', 'Johannesburg', 500, 486, 'BH'),
      ('Auckland Park Studios', 'Johannesburg', 420, 356, 'AP'),
    ];
    const firstNames = [
      'Amahle',
      'Lethabo',
      'Thando',
      'Naledi',
      'Karabo',
      'Siyabonga',
      'Zinhle',
      'Lesedi',
    ];
    const surnames = [
      'Mokoena',
      'Dlamini',
      'Khumalo',
      'Nkosi',
      'Mthembu',
      'Mahlangu',
      'Mabena',
      'Ndlovu',
    ];
    const institutions = [
      'University of Johannesburg',
      'University of the Witwatersrand',
      'Rosebank College',
      'Boston City Campus',
    ];
    const fundingCycle = [
      AccommodationFundingType.nsfas,
      AccommodationFundingType.private,
      AccommodationFundingType.nsfas,
      AccommodationFundingType.bursary,
      AccommodationFundingType.private,
      AccommodationFundingType.other,
    ];

    var globalIndex = 0;
    for (final data in residenceData) {
      final (residence, bedCity, capacity, occupied, code) = data;
      for (var index = 0; index < capacity; index++) {
        final roomNumber = 100 + (index ~/ 2);
        final bedLetter = index.isEven ? 'A' : 'B';
        AccommodationStudent? student;
        if (index < occupied) {
          student = AccommodationStudent(
            id: 'resident-$globalIndex',
            name:
                '${firstNames[globalIndex % firstNames.length]} ${surnames[(globalIndex * 3) % surnames.length]}',
            studentNumber: 'STU${(20260000 + globalIndex)}',
            institution: institutions[globalIndex % institutions.length],
            fundingType: fundingCycle[globalIndex % fundingCycle.length],
          );
        }
        beds.add(
          AccommodationBed(
            id: '$code-${index + 1}',
            residence: residence,
            room: '$roomNumber',
            bedNumber: '$roomNumber$bedLetter',
            city: bedCity,
            student: student,
          ),
        );
        globalIndex++;
      }
    }
  }
}
