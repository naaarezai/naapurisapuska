import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Consistent loading state widget across the app
/// Replaces generic CircularProgressIndicator with branded version
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryGreen,
              ),
            ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
