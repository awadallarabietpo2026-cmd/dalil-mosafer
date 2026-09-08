import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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
            title: 'تحويل العملات',
            subtitle: 'أسعار الصرف',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyPage())),
          ),
          _ServiceCard(
            icon: Icons.confirmation_number,
            title: 'حجوزات',
            subtitle: 'طيران، فنادق، قطارات',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingPage())),
          ),
          _ServiceCard(
            icon: Icons.location_on,
            title: 'أماكن قريبة',
            subtitle: 'مستكشف، قريبة منك',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyPage())),
          ),
          _ServiceCard(
            icon: Icons.translate,
            title: 'ترجمة فورية',
            subtitle: 'ترجمة سريعة',
            onTap: () {},
          ),
          _ServiceCard(
            icon: Icons.map,
            title: 'خرائط أوفلاين',
            subtitle: 'بدون إنترنت',
            onTap: () {},
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
  const _ServiceCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.teal),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ============== صفحة تحويل العملات (زي ما هي) ==============
class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("تحويل العملات"), backgroundColor: Colors.teal), body: const Center(child: Text("تحويل العملات")));
  }
}

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("أماكن قريبة"), backgroundColor: Colors.teal), body: const Center(child: Text("أماكن قريبة")));
  }
}

// ============== صفحة الحجوزات - نسخة مصلّحة وآمنة ==============
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fromController = TextEditingController(text: "CAI");
  final _toController = TextEditingController(text: "JED");
  List flights = [];
  bool loading = false;
  bool hasError = false;

  // التوكن والماركر بيجو وقت الـ build من GitHub Secrets، مش مكتوبين هون أبداً.
  // لازم تضيف TRAVELPAYOUTS_API_TOKEN كـ secret بالمستودع، وتمررو بـ build.yml
  // عبر: --dart-define=TRAVELPAYOUTS_API_TOKEN=${{ secrets.TRAVELPAYOUTS_API_TOKEN }}
  static const String API_TOKEN =
      String.fromEnvironment('TRAVELPAYOUTS_API_TOKEN', defaultValue: '');
  static const String MARKER =
      String.fromEnvironment('TRAVELPAYOUTS_MARKER', defaultValue: '774985');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> searchFlights() async {
    setState(() {
      loading = true;
      hasError = false;
      flights = [];
    });
    try {
      final origin = _fromController.text.trim().toUpperCase();
      final dest = _toController.text.trim().toUpperCase();
      final url = Uri.parse(
        'https://api.travelpayouts.com/aviasales/v3/prices_for_dates'
        '?origin=$origin&destination=$dest&currency=SAR&sorting=price&limit=20',
      );
      final res = await http.get(url, headers: {"X-Access-Token": API_TOKEN});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          flights = (data['data'] as List?) ?? [];
          loading = false;
        });
      } else {
        setState(() {
          hasError = true;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزات - دليل مسافر'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        bottom: TabBar(controller: _tabController, tabs: const [Tab(icon: Icon(Icons.flight), text: "طيران"), Tab(icon: Icon(Icons.hotel), text: "فنادق")]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(child: TextField(controller: _fromController, decoration: const InputDecoration(labelText: "من (CAI)", border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _toController, decoration: const InputDecoration(labelText: "إلى (JED)", border: OutlineInputBorder()))),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.all(14)), onPressed: searchFlights, icon: const Icon(Icons.search, color: Colors.white), label: const Text("ابحث الآن - جوه التطبيق", style: TextStyle(color: Colors.white, fontSize: 16)))),
                  ],
                ),
              ),
              if (loading) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
              if (hasError)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'حصل خطأ أثناء جلب النتائج، جرّب مرة تانية',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(child: ListView.builder(itemCount: flights.length, itemBuilder: (context, i) {
                final f = flights[i];
                return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.teal, child: Text(f['airline'] ?? 'SV', style: const TextStyle(color: Colors.white, fontSize: 10))),
                  title: Text("${f['origin']} → ${f['destination']} - ${f['price']} ر.س"),
                  subtitle: Text("${f['departure_at']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    final link = "https://www.aviasales.com/search/${f['origin']}1510${f['destination']}1?marker=$MARKER";
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("رابط الحجز: $link")));
                  },
                ));
              })),
            ],
          ),
          const Center(child: Text("فنادق - قريباً")),
        ],
      ),
    );
  }
}
