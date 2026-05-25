import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/agenda_item.dart';

/// "Agenda for the Day" card — always the first widget on the Settings screen.
///
/// All items are rendered in a flat column. Scrolling is handled by the
/// outer ListView on the Settings page — no nested scroller needed.
class AgendaCard extends StatelessWidget {
  final List<AgendaItem> items;

  const AgendaCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
                    size: 18,
                    color: AppColors.brandOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Agenda for Today',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  // Item count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrangeContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${items.length} item${items.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.brandOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Item list ──────────────────────────────────────────────────
            if (items.isEmpty)
              _EmptyAgenda(theme: theme)
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildRows(context, theme),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context, ThemeData theme) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      rows.add(_AgendaRow(item: items[i], theme: theme));
      if (i < items.length - 1) {
        rows.add(const Divider(height: 1, indent: 56));
      }
    }
    return rows;
  }
}

// ── Single agenda row ─────────────────────────────────────────────────────────
class _AgendaRow extends StatelessWidget {
  final AgendaItem item;
  final ThemeData theme;

  const _AgendaRow({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(item.type);
    final typeIcon = _typeIcon(item.type);

    return Opacity(
      opacity: item.isDone ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Type icon badge ───────────────────────────────────────────
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(typeIcon, size: 17, color: typeColor),
            ),
            const SizedBox(width: 12),

            // ── Title + project ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.project != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.project!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Time ──────────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: item.isDone
                        ? AppColors.textSecondary
                        : AppColors.brandOrange,
                  ),
                ),
                if (item.endTime.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    item.endTime,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),

            // ── Done tick ─────────────────────────────────────────────────
            if (item.isDone) ...[
              const SizedBox(width: 8),
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                size: 16,
                color: AppColors.successGreen,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _typeColor(AgendaItemType type) {
    return switch (type) {
      AgendaItemType.meeting    => AppColors.brandOrange,
      AgendaItemType.siteVisit  => const Color(0xFF6B45C6),
      AgendaItemType.deadline   => AppColors.errorRed,
      AgendaItemType.inspection => const Color(0xFF0077CC),
      AgendaItemType.delivery   => AppColors.successGreen,
    };
  }

  IconData _typeIcon(AgendaItemType type) {
    return switch (type) {
      AgendaItemType.meeting    => PhosphorIcons.users(PhosphorIconsStyle.fill),
      AgendaItemType.siteVisit  => PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
      AgendaItemType.deadline   => PhosphorIcons.warning(PhosphorIconsStyle.fill),
      AgendaItemType.inspection => PhosphorIcons.clipboardText(PhosphorIconsStyle.fill),
      AgendaItemType.delivery   => PhosphorIcons.truck(PhosphorIconsStyle.fill),
    };
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyAgenda extends StatelessWidget {
  final ThemeData theme;
  const _EmptyAgenda({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.sunHorizon(PhosphorIconsStyle.regular),
            size: 22,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            'No agenda items — clear day ahead!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
