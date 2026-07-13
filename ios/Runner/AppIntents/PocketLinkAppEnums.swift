import AppIntents

// Mirrors lib/model/project.dart's mock project names. This is a POC without
// a shared backend, so the list is hardcoded here rather than fetched live;
// keep it in sync with the Dart mock data if that list changes.
@available(iOS 16.0, *)
enum PocketLinkProject: String, AppEnum {
    case strandBolig
    case bergkvistBolig
    case osloSentrumRehab
    case lofotenHytte
    case trondheimSkole
    case bergenKjopesenter
    case stavangerKontor
    case kristiansandPark

    var displayName: String {
        switch self {
        case .strandBolig: return "Strand Bolig"
        case .bergkvistBolig: return "Bergkvist Bolig"
        case .osloSentrumRehab: return "Oslo Sentrum Rehab"
        case .lofotenHytte: return "Lofoten Hytte"
        case .trondheimSkole: return "Trondheim Skole"
        case .bergenKjopesenter: return "Bergen Kjøpesenter"
        case .stavangerKontor: return "Stavanger Kontor"
        case .kristiansandPark: return "Kristiansand Park"
        }
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Project"
    static var caseDisplayRepresentations: [PocketLinkProject: DisplayRepresentation] = [
        .strandBolig: DisplayRepresentation(title: "Strand Bolig"),
        .bergkvistBolig: DisplayRepresentation(title: "Bergkvist Bolig"),
        .osloSentrumRehab: DisplayRepresentation(title: "Oslo Sentrum Rehab"),
        .lofotenHytte: DisplayRepresentation(title: "Lofoten Hytte"),
        .trondheimSkole: DisplayRepresentation(title: "Trondheim Skole"),
        .bergenKjopesenter: DisplayRepresentation(title: "Bergen Kjøpesenter"),
        .stavangerKontor: DisplayRepresentation(title: "Stavanger Kontor"),
        .kristiansandPark: DisplayRepresentation(title: "Kristiansand Park"),
    ]
}

// Mirrors lib/model/activity.dart's mock activity names.
@available(iOS 16.0, *)
enum PocketLinkActivity: String, AppEnum {
    case concreteWork
    case electricalWork
    case plumbing
    case carpentry
    case painting
    case roofing
    case insulation
    case tiling
    case scaffolding
    case generalLabour

    var displayName: String {
        switch self {
        case .concreteWork: return "Concrete work"
        case .electricalWork: return "Electrical work"
        case .plumbing: return "Plumbing"
        case .carpentry: return "Carpentry"
        case .painting: return "Painting"
        case .roofing: return "Roofing"
        case .insulation: return "Insulation"
        case .tiling: return "Tiling"
        case .scaffolding: return "Scaffolding"
        case .generalLabour: return "General labour"
        }
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Activity"
    static var caseDisplayRepresentations: [PocketLinkActivity: DisplayRepresentation] = [
        .concreteWork: DisplayRepresentation(title: "Concrete work"),
        .electricalWork: DisplayRepresentation(title: "Electrical work"),
        .plumbing: DisplayRepresentation(title: "Plumbing"),
        .carpentry: DisplayRepresentation(title: "Carpentry"),
        .painting: DisplayRepresentation(title: "Painting"),
        .roofing: DisplayRepresentation(title: "Roofing"),
        .insulation: DisplayRepresentation(title: "Insulation"),
        .tiling: DisplayRepresentation(title: "Tiling"),
        .scaffolding: DisplayRepresentation(title: "Scaffolding"),
        .generalLabour: DisplayRepresentation(title: "General labour"),
    ]
}
