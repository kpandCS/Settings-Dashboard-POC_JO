class Activity {
  final int id;
  final String name;

  const Activity({required this.id, required this.name});

  static List<Activity> mockActivities() => [
        const Activity(id: 1, name: 'Concrete work'),
        const Activity(id: 2, name: 'Electrical work'),
        const Activity(id: 3, name: 'Plumbing'),
        const Activity(id: 4, name: 'Carpentry'),
        const Activity(id: 5, name: 'Painting'),
        const Activity(id: 6, name: 'Roofing'),
        const Activity(id: 7, name: 'Insulation'),
        const Activity(id: 8, name: 'Tiling'),
        const Activity(id: 9, name: 'Scaffolding'),
        const Activity(id: 10, name: 'General labour'),
      ];
}
