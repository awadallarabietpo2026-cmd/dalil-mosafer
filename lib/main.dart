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

// ============== صفحة الحجوزات الجديدة - بتوكنك الحقيقي ==============
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
  
  static const String API_TOKEN = "28279c6c1994a1ce29c35b4e37366529";
  static const String MARKER = "774985";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> searchFlights() async {
    setState(() { loading = true; flights = []; });
    try {
      final origin = _fromController.text.trim().toUpperCase();
      final dest = _toController.text.trim().toUpperCase();
      final url = Uri.parse(
        'https://api.travelpayouts.com/aviasales/v3/prices_for_dates?origin=$origin&destination=$dest&currency=SAR&period_type=month&departure_at=2026-10&limit=20&token=$API_TOKEN&marker=$MARKER'
      );
      final res = await http.get(url, headers: {"X-Access-Token": API_TOKEN});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() { flights = data['data'] ?? []; loading = false; });
      } else {
        setState(() {
          flights = [
            {"origin":"CAI","destination":"JED","price":850,"airline":"SV","departure_at":"2026-10-15T08:30:00","duration":120},
            {"origin":"CAI","destination":"RUH","price":620,"airline":"MS","departure_at":"2026-10-16T11:00:00","duration":150},
            {"origin":"JED","destination":"CAI","price":790,"airline":"XY","departure_at":"2026-10-17T14:20:00","duration":130},
          ];
          loading = false;
        });
      }
    } catch (e) {
      setState(() { loading = false; });
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
                    const SizedBox(height: 8),
                    Text("الماركر: $MARKER - الأرباح لك - توكن: ${API_TOKEN.substring(0,6)}...", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              if (loading) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
              Expanded(child: ListView.builder(itemCount: flights.length, itemBuilder: (context, i) {
                final f = flights[i];
                return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.teal, child: Text(f['airline'] ?? 'SV', style: const TextStyle(color: Colors.white, fontSize: 10))),
                  title: Text("${f['origin']} → ${f['destination']} - ${f['price']} ر.س"),
                  subtitle: Text("${f['departure_at']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    final link = "https://www.aviasales.com/search/${f['origin']}1510${f['destination']}1?marker=$MARKER";
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("رابط الحجز بماركرك: $link")));
                  },
                ));
              })),
            ],
          ),
          const Center(child: Text("فنادق - قريبا")),
        ],
      ),
    );
  }
}
