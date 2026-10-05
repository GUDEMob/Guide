import 'package:flutter/material.dart';

class AccommodationColors {
  static const primary = Color(0xFFE30613);
  static const orange = Color(0xFFF97316);
  static const green = Color(0xFF16875D);
  static const blue = Color(0xFF3567D6);
  static const amber = Color(0xFFF2A900);
  static const ink = Color(0xFF231B18);
  static const muted = Color(0xFF756660);
  static const canvas = Color(0xFFF7F8FA);
  static const line = Color(0xFFE8E3E0);
}

class PortalPageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? action;

  const PortalPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: AccommodationColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: AccommodationColors.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AccommodationColors.muted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 12),
          action!,
        ],
      ],
    );
  }
}

class PortalSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const PortalSectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AccommodationColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AccommodationColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class PortalMetricTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const PortalMetricTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AccommodationColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AccommodationColors.ink,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AccommodationColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration portalInputDecoration(String label, {IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon, size: 20),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AccommodationColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AccommodationColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AccommodationColors.primary),
    ),
  );
}
