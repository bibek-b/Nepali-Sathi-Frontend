import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nepal_sathi_frontend/theme/app_theme.dart';

import '../controllers/accessibility_settings_controller.dart';

class AccessibilitySettingsSheet extends StatelessWidget {
  final AccessibilitySettingsController controller;

  const AccessibilitySettingsSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selectedTheme = controller.highContrastEnabled
            ? AppTheme.highContrast
            : AppTheme.light;

        return Theme(
          data: selectedTheme,
          child: Builder(
            builder: (sheetContext) {
              final colors = Theme.of(sheetContext).colorScheme;

              final screenHeight = MediaQuery.sizeOf(sheetContext).height;

              return SafeArea(
                top: false,
                child: Material(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.outline,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Responsive heading
                          Row(
                            children: [
                              Icon(
                                LucideIcons.accessibility,
                                color: colors.primary,
                                size: 26,
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  'सजिलो प्रयोगका सेटिङहरू',
                                  softWrap: true,
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Large text
                          _buildSettingRow(
                            context: sheetContext,
                            icon: LucideIcons.text,
                            title: 'ठूलो अक्षर',
                            subtitle: 'एपका अक्षरहरू ठूलो बनाउनुहोस्।',
                            value: controller.largeTextEnabled,
                            onChanged: controller.setLargeTextEnabled,
                          ),

                          const Divider(),

                          // High contrast
                          _buildSettingRow(
                            context: sheetContext,
                            icon: LucideIcons.contrast,
                            title: 'उच्च कन्ट्रास्ट',
                            subtitle: 'अक्षर र पृष्ठभूमिको भिन्नता बढाउनुहोस्।',
                            value: controller.highContrastEnabled,
                            onChanged: controller.setHighContrastEnabled,
                          ),

                          const Divider(),

                          // Voice feedback
                          _buildSettingRow(
                            context: sheetContext,
                            icon: LucideIcons.volume2,
                            title: 'आवाजमा सूचना',
                            subtitle:
                                'रेकर्डिङ र लेखाइको अवस्थाबारे एपले जानकारी सुनाउँछ।',
                            value: controller.voiceStatusEnabled,
                            onChanged: controller.setVoiceStatusEnabled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            child: Icon(icon, size: 24, color: colors.primary),
          ),

          const SizedBox(width: 12),

          // Text automatically wraps within available width.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  softWrap: true,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
