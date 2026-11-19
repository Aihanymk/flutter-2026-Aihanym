import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorView(
    icon: Icons.wifi_off,
    title: 'No connection',
    message: 'The server could not be reached. Check your network.',
    onRetry: onRetry,
  );
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorView(
    icon: Icons.cloud_off,
    title: 'Server error ($status)',
    message: 'Something is wrong on their side. Try again in a moment.',
    onRetry: onRetry,
  );
}

class RequestRejected extends StatelessWidget {
  const RequestRejected({super.key});

  @override
  Widget build(BuildContext context) => const ErrorView(
    icon: Icons.block,
    title: 'Request rejected',
    message: 'The server refused the request (not found / not authorised).',
  );
}

class GenericError extends StatelessWidget {
  const GenericError({super.key, this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) => ErrorView(
    icon: Icons.error_outline,
    title: 'Unexpected data',
    message:
        'The server sent something the app could not read.'
        '${kDebugMode && detail != null ? '\n\n$detail' : ''}',
  );
}
