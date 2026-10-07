import 'package:flutter/foundation.dart';

enum PshaAlertType { memberUpdate, attention }

enum PshaFundingType { selfFunded, bursary, nsfas, other }

extension PshaFundingTypeLabel on PshaFundingType {
  String get label => switch (this) {
        PshaFundingType.selfFunded => 'Private',
        PshaFundingType.bursary => 'Bursaries',
        PshaFundingType.nsfas => 'NSFAS',
        PshaFundingType.other => 'Other',
      };
}

enum PshaComplaintStatus { open, inProgress, resolved }

extension PshaComplaintStatusLabel on PshaComplaintStatus {
  String get label => switch (this) {
        PshaComplaintStatus.open => 'Open',
        PshaComplaintStatus.inProgress => 'In progress',
        PshaComplaintStatus.resolved => 'Resolved',
      };
}

enum PshaComplaintPriority { low, medium, high }

class PshaStudent {
  final String id;
  final String name;
  final String studentNumber;
  final String institution;
  final PshaFundingType fundingType;

  const PshaStudent({
    required this.id,
    required this.name,
    required this.studentNumber,
    required this.institution,
    required this.fundingType,
  });
}

class PshaBedRecord {
  final String id;
  final String bedNumber;
  final String providerId;
  final String providerName;
  final String buildingName;
  final String city;
  final PshaStudent? student;

  const PshaBedRecord({
    required this.id,
    required this.bedNumber,
    required this.providerId,
    required this.providerName,
    required this.buildingName,
    required this.city,
    this.student,
  });

  bool get occupied => student != null;

  PshaBedRecord withStudent(PshaStudent? value) => PshaBedRecord(
        id: id,
        bedNumber: bedNumber,
        providerId: providerId,
        providerName: providerName,
        buildingName: buildingName,
        city: city,
        student: value,
      );
}

class PshaComplaint {
  final String id;
  final String studentId;
  final String studentName;
  final String title;
  final String detail;
  final String providerName;
  final String buildingName;
  final String age;
  final PshaComplaintPriority priority;
  final PshaComplaintStatus status;

  const PshaComplaint({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.detail,
    required this.providerName,
    required this.buildingName,
    required this.age,
    required this.priority,
    this.status = PshaComplaintStatus.open,
  });

  PshaComplaint copyWith({PshaComplaintStatus? status}) => PshaComplaint(
        id: id,
        studentId: studentId,
        studentName: studentName,
        title: title,
        detail: detail,
        providerName: providerName,
        buildingName: buildingName,
        age: age,
        priority: priority,
        status: status ?? this.status,
      );
}

class PshaAnnouncement {
  final String id;
  final String title;
  final String message;
  final String audience;
  final String published;
  final bool pinned;

  const PshaAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.published,
    this.pinned = false,
  });

  PshaAnnouncement copyWith({bool? pinned}) => PshaAnnouncement(
        id: id,
        title: title,
        message: message,
        audience: audience,
        published: published,
        pinned: pinned ?? this.pinned,
      );
}

class PshaNetworkAlert {
  final String id;
  final String title;
  final String detail;
  final String providerId;
  final String age;
  final PshaAlertType type;
  final bool reviewed;

  const PshaNetworkAlert({
    required this.id,
    required this.title,
    required this.detail,
    required this.providerId,
    required this.age,
    required this.type,
    this.reviewed = false,
  });

  PshaNetworkAlert copyWith({bool? reviewed}) {
    return PshaNetworkAlert(
      id: id,
      title: title,
      detail: detail,
      providerId: providerId,
      age: age,
      type: type,
      reviewed: reviewed ?? this.reviewed,
    );
  }
}

class PshaBuilding {
  final String name;
  final String city;
  final int students;
  final int capacity;

  const PshaBuilding({
    required this.name,
    required this.city,
    required this.students,
    required this.capacity,
  });

  int get occupancy =>
      capacity == 0 ? 0 : ((students / capacity) * 100).round();
}

class PshaMemberProvider {
  final String id;
  final String name;
  final String contact;
  final List<PshaBuilding> buildings;
  final int engagement;
  final int opportunities;
  final bool active;

  const PshaMemberProvider({
    required this.id,
    required this.name,
    required this.contact,
    required this.buildings,
    required this.engagement,
    required this.opportunities,
    this.active = true,
  });

  int get studentCount =>
      buildings.fold(0, (total, building) => total + building.students);

  PshaMemberProvider copyWith({
    bool? active,
    List<PshaBuilding>? buildings,
  }) {
    return PshaMemberProvider(
      id: id,
      name: name,
      contact: contact,
      buildings: buildings ?? this.buildings,
      engagement: engagement,
      opportunities: opportunities,
      active: active ?? this.active,
    );
  }
}

class PshaPortalStore extends ChangeNotifier {
  PshaPortalStore._() {
    _seedBedRecords();
    _seedComplaints();
  }

  static final PshaPortalStore instance = PshaPortalStore._();

  String associationName = 'Private Student Housing Association';
  String adminEmail = 'admin@psha.org.za';

  final List<PshaBedRecord> bedRecords = [];
  final List<PshaComplaint> complaints = [];
  final List<PshaAnnouncement> announcements = [
    const PshaAnnouncement(
      id: 'announcement-reporting-window',
      title: 'October occupancy reporting window',
      message:
          'Member providers must confirm bed occupancy and funding records by 31 October.',
      audience: 'All member providers',
      published: 'Today, 08:30',
      pinned: true,
    ),
    const PshaAnnouncement(
      id: 'announcement-nsfas-verification',
      title: 'NSFAS verification guidance updated',
      message:
          'The latest verification checklist is available for residence administrators.',
      audience: 'Residence administrators',
      published: 'Yesterday',
    ),
    const PshaAnnouncement(
      id: 'announcement-student-wellbeing',
      title: 'Student wellbeing pulse survey',
      message:
          'Encourage accommodated students to complete the national wellbeing survey.',
      audience: 'All residences',
      published: '3 days ago',
    ),
  ];

  final List<PshaNetworkAlert> alerts = [
    const PshaNetworkAlert(
      id: 'alert-campus-key-report',
      title: 'New member report submitted',
      detail: 'CampusKey submitted its latest occupancy and student data.',
      providerId: 'campus-key',
      age: '18 min ago',
      type: PshaAlertType.memberUpdate,
    ),
    const PshaNetworkAlert(
      id: 'alert-digsconnect-capacity',
      title: 'Capacity update needs review',
      detail: 'DigsConnect Living changed capacity for one residence.',
      providerId: 'digsconnect-living',
      age: '2 hours ago',
      type: PshaAlertType.attention,
    ),
  ];

  final List<PshaMemberProvider> providers = [
    const PshaMemberProvider(
      id: 'urban-student',
      name: 'Urban Student Living',
      contact: 'operations@urbanstudent.co.za',
      engagement: 74,
      opportunities: 42,
      buildings: [
        PshaBuilding(
          name: 'Braam House',
          city: 'Johannesburg',
          students: 486,
          capacity: 520,
        ),
        PshaBuilding(
          name: 'Auckland Park Studios',
          city: 'Johannesburg',
          students: 356,
          capacity: 400,
        ),
        PshaBuilding(
          name: 'Newtown Junction',
          city: 'Johannesburg',
          students: 628,
          capacity: 670,
        ),
      ],
    ),
    const PshaMemberProvider(
      id: 'campus-key',
      name: 'CampusKey',
      contact: 'studentlife@campuskey.co.za',
      engagement: 78,
      opportunities: 68,
      buildings: [
        PshaBuilding(
          name: 'CampusKey Cape Town',
          city: 'Cape Town',
          students: 1175,
          capacity: 1250,
        ),
        PshaBuilding(
          name: 'CampusKey Pretoria',
          city: 'Pretoria',
          students: 1320,
          capacity: 1400,
        ),
        PshaBuilding(
          name: 'CampusKey Stellenbosch',
          city: 'Stellenbosch',
          students: 892,
          capacity: 940,
        ),
        PshaBuilding(
          name: 'CampusKey Gqeberha',
          city: 'Gqeberha',
          students: 760,
          capacity: 810,
        ),
      ],
    ),
    const PshaMemberProvider(
      id: 'south-point',
      name: 'South Point',
      contact: 'community@southpoint.co.za',
      engagement: 66,
      opportunities: 91,
      buildings: [
        PshaBuilding(
          name: 'Norvic',
          city: 'Johannesburg',
          students: 980,
          capacity: 1050,
        ),
        PshaBuilding(
          name: 'Siemert Court',
          city: 'Johannesburg',
          students: 840,
          capacity: 900,
        ),
        PshaBuilding(
          name: 'Relyant',
          city: 'Pretoria',
          students: 720,
          capacity: 780,
        ),
        PshaBuilding(
          name: 'Mowbray House',
          city: 'Cape Town',
          students: 650,
          capacity: 700,
        ),
        PshaBuilding(
          name: 'Newgate',
          city: 'Durban',
          students: 710,
          capacity: 760,
        ),
      ],
    ),
    const PshaMemberProvider(
      id: 'respublica',
      name: 'Respublica',
      contact: 'experience@respublica.co.za',
      engagement: 72,
      opportunities: 57,
      buildings: [
        PshaBuilding(
          name: 'Eastwood Village',
          city: 'Pretoria',
          students: 1120,
          capacity: 1200,
        ),
        PshaBuilding(
          name: 'Hatfield Square',
          city: 'Pretoria',
          students: 940,
          capacity: 1000,
        ),
        PshaBuilding(
          name: 'West City',
          city: 'Johannesburg',
          students: 860,
          capacity: 920,
        ),
      ],
    ),
    const PshaMemberProvider(
      id: 'digsconnect-living',
      name: 'DigsConnect Living',
      contact: 'partners@digsconnect.com',
      engagement: 64,
      opportunities: 36,
      buildings: [
        PshaBuilding(
          name: 'Observatory Exchange',
          city: 'Cape Town',
          students: 520,
          capacity: 580,
        ),
        PshaBuilding(
          name: 'Claremont Student Village',
          city: 'Cape Town',
          students: 430,
          capacity: 480,
        ),
      ],
    ),
  ];

  int get providerCount => providers.length;
  int get openAlertCount => alerts.where((alert) => !alert.reviewed).length;
  int get activeProviderCount => providers.where((item) => item.active).length;
  int get totalBedCount => bedRecords.length;
  int get occupiedBedCount =>
      bedRecords.where((record) => record.occupied).length;
  int get availableBedCount => totalBedCount - occupiedBedCount;
  int get openComplaintCount => complaints
      .where((item) => item.status != PshaComplaintStatus.resolved)
      .length;
  List<PshaBedRecord> get occupiedBeds =>
      bedRecords.where((record) => record.occupied).toList(growable: false);
  List<PshaBedRecord> get availableBeds =>
      bedRecords.where((record) => !record.occupied).toList(growable: false);
  Map<PshaFundingType, int> get fundingBreakdown {
    final totals = {
      for (final type in PshaFundingType.values) type: 0,
    };
    for (final record in occupiedBeds) {
      final funding = record.student!.fundingType;
      totals[funding] = totals[funding]! + 1;
    }
    return totals;
  }

  Map<String, int> get availableBedsByLocation {
    final totals = <String, int>{};
    for (final record in availableBeds) {
      final location = '${record.buildingName}, ${record.city}';
      totals[location] = (totals[location] ?? 0) + 1;
    }
    return totals;
  }

  int get buildingCount => providers.fold(
        0,
        (total, provider) => total + provider.buildings.length,
      );
  int get studentCount => occupiedBedCount;
  int get opportunityCount => providers.fold(
        0,
        (total, provider) => total + provider.opportunities,
      );
  int get averageEngagement => providers.isEmpty
      ? 0
      : (providers.fold(0, (total, item) => total + item.engagement) /
              providers.length)
          .round();
  int get averageOccupancy {
    if (totalBedCount == 0) return 0;
    return ((occupiedBedCount / totalBedCount) * 100).round();
  }

  void setProviderActive(String id, bool active) {
    final index = providers.indexWhere((provider) => provider.id == id);
    if (index < 0) return;
    providers[index] = providers[index].copyWith(active: active);
    notifyListeners();
  }

  void markAlertReviewed(String id) {
    final index = alerts.indexWhere((alert) => alert.id == id);
    if (index < 0) return;
    alerts[index] = alerts[index].copyWith(reviewed: true);
    notifyListeners();
  }

  void addProvider({
    required String name,
    required String contact,
    required String buildingName,
    required String city,
    required int students,
  }) {
    final building = PshaBuilding(
      name: buildingName,
      city: city,
      students: students,
      capacity: students,
    );
    final provider = PshaMemberProvider(
      id: 'provider-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      contact: contact,
      engagement: 0,
      opportunities: 0,
      buildings: [building],
    );
    providers.insert(0, provider);
    _appendBedRecords(provider, building);
    notifyListeners();
  }

  void addBuilding({
    required String providerId,
    required String name,
    required String city,
    required int students,
    required int capacity,
  }) {
    final index = providers.indexWhere((provider) => provider.id == providerId);
    if (index < 0) return;
    final provider = providers[index];
    final building = PshaBuilding(
      name: name,
      city: city,
      students: students,
      capacity: capacity,
    );
    providers[index] = provider.copyWith(
      buildings: [
        ...provider.buildings,
        building,
      ],
    );
    _appendBedRecords(provider, building);
    notifyListeners();
  }

  void assignStudentToBed({
    required String bedId,
    required String name,
    required String studentNumber,
    required String institution,
    required PshaFundingType fundingType,
  }) {
    final index = bedRecords.indexWhere((record) => record.id == bedId);
    if (index < 0) return;
    bedRecords[index] = bedRecords[index].withStudent(
      PshaStudent(
        id: 'student-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        studentNumber: studentNumber,
        institution: institution,
        fundingType: fundingType,
      ),
    );
    notifyListeners();
  }

  void vacateBed(String bedId) {
    final index = bedRecords.indexWhere((record) => record.id == bedId);
    if (index < 0) return;
    bedRecords[index] = bedRecords[index].withStudent(null);
    notifyListeners();
  }

  void updateComplaintStatus(
    String complaintId,
    PshaComplaintStatus status,
  ) {
    final index = complaints.indexWhere((item) => item.id == complaintId);
    if (index < 0) return;
    complaints[index] = complaints[index].copyWith(status: status);
    notifyListeners();
  }

  void publishAnnouncement({
    required String title,
    required String message,
    required String audience,
  }) {
    announcements.insert(
      0,
      PshaAnnouncement(
        id: 'announcement-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        message: message,
        audience: audience,
        published: 'Just now',
      ),
    );
    notifyListeners();
  }

  void toggleAnnouncementPinned(String announcementId) {
    final index = announcements.indexWhere((item) => item.id == announcementId);
    if (index < 0) return;
    final announcement = announcements[index];
    announcements[index] = announcement.copyWith(pinned: !announcement.pinned);
    notifyListeners();
  }

  void _seedBedRecords() {
    for (final provider in providers) {
      for (final building in provider.buildings) {
        _appendBedRecords(provider, building);
      }
    }
  }

  void _appendBedRecords(
    PshaMemberProvider provider,
    PshaBuilding building,
  ) {
    const firstNames = [
      'Amina',
      'Lerato',
      'Naledi',
      'Thando',
      'Keanu',
      'Ayanda',
      'Zanele',
      'Mpho',
      'Siyabonga',
      'Imani',
      'Karabo',
      'Lwazi',
    ];
    const lastNames = [
      'Khumalo',
      'Mokoena',
      'Naidoo',
      'Dlamini',
      'Jacobs',
      'Mahlangu',
      'Ndlovu',
      'Petersen',
      'Nkosi',
      'Mthembu',
      'Williams',
      'Mabena',
    ];
    final institutions = _institutionsForCity(building.city);
    final existingCount = bedRecords.length;

    for (var index = 0; index < building.capacity; index++) {
      final sequence = existingCount + index + 1;
      final isOccupied = index < building.students;
      final fundingSlot = sequence % 20;
      final funding = fundingSlot < 10
          ? PshaFundingType.nsfas
          : fundingSlot < 14
              ? PshaFundingType.selfFunded
              : fundingSlot < 18
                  ? PshaFundingType.bursary
                  : PshaFundingType.other;
      final student = isOccupied
          ? PshaStudent(
              id: 'student-$sequence',
              name:
                  '${firstNames[sequence % firstNames.length]} ${lastNames[(sequence * 3) % lastNames.length]}',
              studentNumber: 'ST${sequence.toString().padLeft(7, '0')}',
              institution: institutions[sequence % institutions.length],
              fundingType: funding,
            )
          : null;
      bedRecords.add(
        PshaBedRecord(
          id: '${provider.id}-${building.name}-$index',
          bedNumber: 'B-${(index + 1).toString().padLeft(4, '0')}',
          providerId: provider.id,
          providerName: provider.name,
          buildingName: building.name,
          city: building.city,
          student: student,
        ),
      );
    }
  }

  List<String> _institutionsForCity(String city) => switch (city) {
        'Johannesburg' => const [
            'University of Johannesburg',
            'University of the Witwatersrand',
          ],
        'Pretoria' => const [
            'University of Pretoria',
            'Tshwane University of Technology',
          ],
        'Cape Town' => const [
            'University of Cape Town',
            'University of the Western Cape',
            'Cape Peninsula University of Technology',
          ],
        'Stellenbosch' => const ['Stellenbosch University'],
        'Gqeberha' => const ['Nelson Mandela University'],
        'Durban' => const [
            'University of KwaZulu-Natal',
            'Durban University of Technology',
          ],
        _ => const ['University of South Africa'],
      };

  void _seedComplaints() {
    if (occupiedBeds.length < 5) return;
    final samples = [
      occupiedBeds[12],
      occupiedBeds[427],
      occupiedBeds[1380],
      occupiedBeds[4210],
    ];
    const titles = [
      'Hot water unavailable',
      'Wi-Fi outage on residence floor',
      'Room maintenance follow-up',
      'Noise complaint after quiet hours',
    ];
    const details = [
      'The hot water has been unavailable since yesterday evening.',
      'Students cannot connect to the residence network on the third floor.',
      'The reported window repair has not yet been completed.',
      'Repeated noise after the residence quiet-time policy begins.',
    ];
    for (var index = 0; index < samples.length; index++) {
      final record = samples[index];
      complaints.add(
        PshaComplaint(
          id: 'complaint-${index + 1}',
          studentId: record.student!.id,
          studentName: record.student!.name,
          title: titles[index],
          detail: details[index],
          providerName: record.providerName,
          buildingName: record.buildingName,
          age: index == 0 ? '24 min ago' : '${index + 1} hours ago',
          priority: index == 0
              ? PshaComplaintPriority.high
              : index == 3
                  ? PshaComplaintPriority.low
                  : PshaComplaintPriority.medium,
          status: index == 2
              ? PshaComplaintStatus.inProgress
              : PshaComplaintStatus.open,
        ),
      );
    }
  }
}
