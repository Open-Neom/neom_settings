import 'package:flutter/material.dart';
import 'package:neom_commons/ui/theme/app_color.dart';

class SettingsWebSection extends StatelessWidget {

  final String title;
  final Widget content;

  const SettingsWebSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Divider(height: 1, color: AppColor.borderSubtle),
        const SizedBox(height: 16),
        content,
      ],
    );
  }
}
