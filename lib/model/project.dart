class Project {
  final int id;
  final String name;
  final String? statusLabel;

  const Project({
    required this.id,
    required this.name,
    this.statusLabel,
  });

  /// Mock data that simulates what the API would return
  static List<Project> mockProjects() => [
        const Project(id: 1, name: 'Strand Bolig', statusLabel: 'Under Arbeid'),
        const Project(id: 2, name: 'Bergkvist Bolig', statusLabel: 'Under Arbeid'),
        const Project(id: 3, name: 'Oslo Sentrum Rehab', statusLabel: 'Planlagt'),
        const Project(id: 4, name: 'Lofoten Hytte', statusLabel: 'Under Arbeid'),
        const Project(id: 5, name: 'Trondheim Skole', statusLabel: 'Planlagt'),
        const Project(id: 6, name: 'Bergen Kjøpesenter', statusLabel: 'Ferdig'),
        const Project(id: 7, name: 'Stavanger Kontor', statusLabel: 'Under Arbeid'),
        const Project(id: 8, name: 'Kristiansand Park', statusLabel: 'Planlagt'),
      ];
}
