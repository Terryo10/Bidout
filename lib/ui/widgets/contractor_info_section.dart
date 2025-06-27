import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/contractor_model.dart';

class ContractorInfoSection extends StatelessWidget {
  final ContractorModel contractor;

  const ContractorInfoSection({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: context.colors.surface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contractor.bio != null) ...[
            Text(
              'About',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contractor.bio!,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (contractor.workPhilosophy != null) ...[
            Text(
              'Work Philosophy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contractor.workPhilosophy!,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (contractor.skills?.isNotEmpty ?? false) ...[
            Text(
              'Skills',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contractor.skills!.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.info,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (contractor.certifications?.isNotEmpty ?? false) ...[
            Text(
              'Certifications',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contractor.certifications!.map((cert) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    cert,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.success,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (contractor.serviceAreas?.isNotEmpty ?? false) ...[
            Text(
              'Service Areas',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contractor.serviceAreas!.map((area) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    area,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
