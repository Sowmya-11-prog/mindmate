import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

/// Always reachable from the home shell (not buried in settings).
/// This screen should never require sign-in or any prior steps to reach.
class CrisisSupportScreen extends StatelessWidget {
  const CrisisSupportScreen({super.key});

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^0-9+]'), ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'If you\'re in crisis or having thoughts of harming yourself, '
            'please reach out — you don\'t have to go through this alone.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          ...AppConstants.crisisResources.map((resource) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.phone_in_talk),
                title: Text(resource['name']!),
                subtitle: Text(resource['phone'] ?? ''),
                trailing: resource['phone'] != null
                    ? IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () => _call(resource['phone']!),
                      )
                    : null,
                onTap: resource['url'] != null ? () => _openUrl(resource['url']!) : null,
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            'MindMate is a wellbeing companion, not a substitute for '
            'professional mental health care. If symptoms persist, please '
            'consult a licensed therapist or doctor.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
