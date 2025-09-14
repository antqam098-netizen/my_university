import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) throw 'لا يمكن الفتح';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حول التطبيق')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تم إنشاء هذا المشروع بواسطة', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('ABDULLAH ALASAAD & ARX-Tech', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.facebook),
                label: const Text('تابعنا على فيسبوك'),
                onPressed: () => _launch('https://www.facebook.com/profile.php?id=61579097697055'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.telegram),
                label: const Text('تواصل مع الدعم'),
                onPressed: () => _launch('https://t.me/mar01abdullah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
