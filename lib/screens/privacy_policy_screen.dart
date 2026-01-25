import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacyPolicyTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.privacyPolicyDate,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              l10n.privacyPolicySection1Title,
              l10n.privacyPolicySection1Content,
            ),
            _buildSection(
              l10n.privacyPolicySection2Title,
              l10n.privacyPolicySection2Content,
            ),
            _buildSection(
              l10n.privacyPolicySection3Title,
              l10n.privacyPolicySection3Content,
            ),
            _buildSection(
              l10n.privacyPolicySection4Title,
              l10n.privacyPolicySection4Content,
            ),
            _buildSection(
              l10n.privacyPolicySection5Title,
              l10n.privacyPolicySection5Content,
            ),
            _buildSection(
              l10n.privacyPolicySection6Title,
              l10n.privacyPolicySection6Content,
            ),
            _buildSection(
              l10n.privacyPolicySection7Title,
              l10n.privacyPolicySection7Content,
            ),
            _buildSection(
              l10n.privacyPolicySection8Title,
              l10n.privacyPolicySection8Content,
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
