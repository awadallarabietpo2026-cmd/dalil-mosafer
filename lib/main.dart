import 'package:flutter/material.dart';

void main() {
  runApp(const DalilMosaferApp());
}

class DalilMosaferApp extends StatelessWidget {
  const DalilMosaferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل مسافر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل مسافر برو'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _ServiceCard(
            icon: Icons.currency_exchange,
            title: 'تحويل عملات',
            subtitle: 'أسعار لحظية',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrencyPage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.confirmation_number,
            title: 'حجوزات',
            subtitle: 'طيران، فنادق، قطارات',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingPage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.location_on,
            title: 'أماكن قريبة',
            subtitle: 'مستشفى، صيدلية، شرطة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyPage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.translate,
            title: 'ترجمة فورية',
            subtitle: 'جمل جاهزة أوفلاين',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TranslatePage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.map,
            title: 'خرائط أوفلاين',
            subtitle: 'دليل التحميل قبل السفر',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OfflineMapsPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.teal),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------ الشاشات الفرعية (لسه فاضية، هنملاها في المراحل الجاية) ------

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحويل عملات'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي في المرحلة الجاية 🚧')),
    );
  }
}

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزات'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أماكن قريبة'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}

class TranslatePage extends StatelessWidget {
  const TranslatePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ترجمة فورية'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}

class OfflineMapsPage extends StatelessWidget {
  const OfflineMapsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خرائط أوفلاين'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}
