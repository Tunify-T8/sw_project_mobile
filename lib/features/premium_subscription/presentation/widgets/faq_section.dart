import 'package:flutter/material.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  bool _q1expanded = false;
  bool _q2expanded = false;
  static const TextStyle _titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequently asked questions",
          key: const Key('subscription_faq_title'),
          style: _titleTextStyle,
        ),
        const SizedBox(height: 14),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: [
              ExpansionTile(
                key: const Key('subscription_faq_fan_artist_tile'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                onExpansionChanged: (bool expanded) =>
                    setState(() => _q1expanded = expanded),
                title: const Text(
                  "What's the difference between fan and artist plans?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  _q1expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 30,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Our Fan-oriented plans are designed for those who primarily visit the site to listen to SoundCloud's 250+ million tracks. Artist plans offer unique features designed to help artists create and distribute their music and content.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),

              ExpansionTile(
                key: const Key('subscription_faq_annual_family_tile'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                onExpansionChanged: (bool expanded) =>
                    setState(() => _q2expanded = expanded),
                title: const Text(
                  "Can I purchase an annual plan and/or family plan?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  _q2expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 30,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Unfortunately we do not currently offer an annual or family plan option for purchase in the app.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
