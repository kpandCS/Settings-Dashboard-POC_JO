// ── Agenda Item ───────────────────────────────────────────────────────────────
// Mock model — in production this comes from the calendar / work-order API.

enum AgendaItemType { meeting, siteVisit, deadline, inspection, delivery }

class AgendaItem {
  final String time;     // e.g. "09:00"
  final String endTime;  // e.g. "10:00" — empty string if not applicable
  final String title;
  final String? project; // related project name (nullable)
  final AgendaItemType type;
  final bool isDone;

  const AgendaItem({
    required this.time,
    required this.endTime,
    required this.title,
    this.project,
    required this.type,
    this.isDone = false,
  });

  // ── Mock data — 5 items so the scroller is exercised ─────────────────────
  static List<AgendaItem> mockToday() => const [
        AgendaItem(
          time: '08:00',
          endTime: '08:30',
          title: 'Toolbox Talk',
          project: 'Strand Bolig',
          type: AgendaItemType.meeting,
          isDone: true,
        ),
        AgendaItem(
          time: '09:30',
          endTime: '11:00',
          title: 'Site Inspection',
          project: 'Lofoten Hytte',
          type: AgendaItemType.inspection,
        ),
        AgendaItem(
          time: '12:00',
          endTime: '',
          title: 'Material Delivery',
          project: 'Bergkvist Bolig',
          type: AgendaItemType.delivery,
        ),
        AgendaItem(
          time: '13:30',
          endTime: '14:30',
          title: 'Client Walk-Through',
          project: 'Strand Bolig',
          type: AgendaItemType.siteVisit,
        ),
        AgendaItem(
          time: '15:00',
          endTime: '',
          title: 'Work Report Due',
          project: 'WR-2041',
          type: AgendaItemType.deadline,
        ),
      ];
}
