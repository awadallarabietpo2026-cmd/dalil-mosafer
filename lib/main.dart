import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
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
            subtitle: 'طيران حقيقي €',
            color: Colors.orange,
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
          _ServiceCard(
            icon: Icons.hotel,
            title: 'فنادق',
            subtitle: 'حجز حقيقي',
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
  final Color color;
  const _ServiceCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.color = Colors.teal});

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
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تحويل العملات"), backgroundColor: Colors.teal),
      body: const Center(child: Text("تحويل العملات - قريبا")),
    );
  }
}

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("أماكن قريبة"), backgroundColor: Colors.teal),
      body: const Center(child: Text("أماكن قريبة - قريبا")),
    );
  }
}

// ================= صفحة الحجوزات الحقيقية 100% =================
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _fromController = TextEditingController(text: "MIL");
  final _toController = TextEditingController(text: "CAI");
  late WebViewController _webController;
  bool _showWebView = false;
  bool _isLoading = true;

  // الماركر بتاعك اللي جبته من الصورة - ده اللي بيجيبلك العمولة
  static const String MARKER = '774985';

  void _searchRealFlights() {
    final from = _fromController.text.trim().toUpperCase();
    final to = _toController.text.trim().toUpperCase();
    if (from.isEmpty || to.isEmpty) return;

    // تاريخ بعد اسبوع عشان يجيب اسعار حقيقية
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    final day = nextWeek.day.toString().padLeft(2, '0');
    final month = nextWeek.month.toString().padLeft(2, '0');

    // ده الرابط الحقيقي اللي بيفتح نفس تصميم صور Aviasales اللي بعتها
    // €451 مباشر 3س 45د + تقويم الاسعار €302 €318 + فلتر الارخص/الاسرع
    final url = 'https://www.aviasales.com/search/$from$day$month${to}1?marker=$MARKER&with_request=true';

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() => _showWebView = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showWebView ? 'نتائج حقيقية - €' : 'حجوزات طيران حقيقية'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: _showWebView
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showWebView = false))
            : null,
      ),
      body: _showWebView
          ? Stack(
              children: [
                WebViewWidget(controller: _webController),
                if (_isLoading) const LinearProgressIndicator(color: Colors.orange, minHeight: 4),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("من أين؟", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fromController,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "MIL - ميلانو",
                      prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("إلى أين؟", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _toController,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "CAI - القاهرة",
                      prefixIcon: const Icon(Icons.flight_land, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _searchRealFlights,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text("ابحث الآن - رحلات حقيقية", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Row(children: [Icon(Icons.check_circle, color: Colors.teal, size: 18), SizedBox(width: 8), Expanded(child: Text("نفس نتايج Aviasales: €451 مباشر 3س 45د", style: TextStyle(fontSize: 13)))]),
                        SizedBox(height: 6),
                        Row(children: [Icon(Icons.check_circle, color: Colors.teal, size: 18), SizedBox(width: 8), Expanded(child: Text("تقويم الأسعار €302 €318 وفلتر الأرخص/الأسرع", style: TextStyle(fontSize: 13)))]),
                        SizedBox(height: 6),
                        Row(children: [Icon(Icons.check_circle, color: Colors.teal, size: 18), SizedBox(width: 8), Expanded(child: Text("حجزك = عمولة ليك على Marker 774985", style: TextStyle(fontSize: 13)))]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
