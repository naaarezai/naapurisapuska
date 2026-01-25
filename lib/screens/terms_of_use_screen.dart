import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsOfUseTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.termsOfUseTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.termsOfUseDate,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              l10n.termsOfUseSection1Title,
              l10n.termsOfUseSection1Content,
            ),
            _buildSection(
              l10n.termsOfUseSection2Title,
              l10n.termsOfUseSection2Content,
            ),
            _buildSection(
              l10n.termsOfUseSection3Title,
              l10n.termsOfUseSection3Content,
            ),
            _buildSection(
              l10n.termsOfUseSection4Title,
              l10n.termsOfUseSection4Content,
            ),
            _buildSection(
              l10n.termsOfUseSection5Title,
              l10n.termsOfUseSection5Content,
            ),
            _buildSection(
              l10n.termsOfUseSection6Title,
              l10n.termsOfUseSection6Content,
            ),
            _buildSection(
              l10n.termsOfUseSection7Title,
              l10n.termsOfUseSection7Content,
            ),
            _buildSection(
              l10n.termsOfUseSection8Title,
              l10n.termsOfUseSection8Content,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
