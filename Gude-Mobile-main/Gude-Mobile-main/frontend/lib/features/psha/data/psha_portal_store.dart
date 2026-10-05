import 'package:flutter/foundation.dart';

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
  PshaPortalStore._();

  static final PshaPortalStore instance = PshaPortalStore._();

  String associationName = 'Private Student Housing Association';
  String adminEmail = 'admin@psha.org.za';

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
  int get activeProviderCount => providers.where((item) => item.active).length;
  int get buildingCount => providers.fold(
        0,
        (total, provider) => total + provider.buildings.length,
      );
  int get studentCount => providers.fold(
        0,
        (total, provider) => total + provider.studentCount,
      );
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
    final buildings =
        providers.expand((provider) => provider.buildings).toList();
    if (buildings.isEmpty) return 0;
    return (buildings.fold(0, (total, item) => total + item.occupancy) /
            buildings.length)
        .round();
  }

  void setProviderActive(String id, bool active) {
    final index = providers.indexWhere((provider) => provider.id == id);
    if (index < 0) return;
    providers[index] = providers[index].copyWith(active: active);
    notifyListeners();
  }

  void addProvider({
    required String name,
    required String contact,
    required String buildingName,
    required String city,
    required int students,
  }) {
    providers.insert(
      0,
      PshaMemberProvider(
        id: 'provider-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        contact: contact,
        engagement: 0,
        opportunities: 0,
        buildings: [
          PshaBuilding(
            name: buildingName,
            city: city,
            students: students,
            capacity: students,
          ),
        ],
      ),
    );
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
    providers[index] = provider.copyWith(
      buildings: [
        ...provider.buildings,
        PshaBuilding(
          name: name,
          city: city,
          students: students,
          capacity: capacity,
        ),
      ],
    );
    notifyListeners();
  }
}
