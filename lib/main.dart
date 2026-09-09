import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Cairo'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دليل مسافر برو - كله حقيقي'), backgroundColor: Colors.teal, centerTitle: true),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(16), crossAxisSpacing: 16, mainAxisSpacing: 16,
        children: [
          _ServiceCard(icon: Icons.currency_exchange, title: 'تحويل العملات', subtitle: 'حقيقي - أسعار حية', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyPage()))),
          _ServiceCard(icon: Icons.flight, title: 'حجوزات طيران', subtitle: 'حقيقي € Aviasales', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingPage()))),
          _ServiceCard(icon: Icons.hotel, title: 'حجوزات فنادق', subtitle: 'حقيقي Booking', color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelsPage()))),
          _ServiceCard(icon: Icons.location_on, title: 'أماكن قريبة', subtitle: 'حقيقي - GPS', color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyPage()))),
          _ServiceCard(icon: Icons.translate, title: 'ترجمة فورية', subtitle: 'حقيقي - عربي/ايطالي', color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslatePage()))),
          _ServiceCard(icon: Icons.map, title: 'خرائط', subtitle: 'حقيقي - خريطة حية', color: Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapsPage()))),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap; final Color color;
  const _ServiceCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.color = Colors.teal});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ========== 1. تحويل عملات حقيقي ==========
class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});
  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}
class _CurrencyPageState extends State<CurrencyPage> {
  double eurToEgp = 0, eurToSar = 0, eurToUsd = 0;
  bool loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/EUR'));
      final data = jsonDecode(res.body);
      setState(() {
        eurToEgp = (data['rates']['EGP'] as num).toDouble();
        eurToSar = (data['rates']['SAR'] as num).toDouble();
        eurToUsd = (data['rates']['USD'] as num).toDouble();
        loading = false;
      });
    } catch (e) { setState(() => loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحويل عملات حقيقي'), backgroundColor: Colors.teal),
      body: loading? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(leading: const Icon(Icons.euro, color: Colors.green), title: const Text('1 يورو ='), subtitle: Text('$eurToEgp جنيه مصري', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
        Card(child: ListTile(leading: const Icon(Icons.euro, color: Colors.orange), title: const Text('1 يورو ='), subtitle: Text('$eurToSar ريال سعودي', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
        Card(child: ListTile(leading: const Icon(Icons.euro, color: Colors.blue), title: const Text('1 يورو ='), subtitle: Text('$eurToUsd دولار', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
      ]),
    );
  }
}

// ========== 2. طيران حقيقي ==========
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}
class _BookingPageState extends State<BookingPage> {
  final _fromController = TextEditingController(text: "ميلانو");
  final _toController = TextEditingController(text: "القاهرة");
  late WebViewController _webController;
  bool _showWebView = false;
  bool _isLoading = true;
  static const String MARKER = '774985';
  final Map<String, String> cityToCode = {
    "القاهرة": "CAI", "القاهره": "CAI", "cairo": "CAI", "CAI": "CAI",
    "جدة": "JED", "جده": "JED", "jeddah": "JED", "JED": "JED",
    "الرياض": "RUH", "riyadh": "RUH", "RUH": "RUH",
    "ميلانو": "MIL", "ميلان": "MIL", "milano": "MIL", "milan": "MIL", "MIL": "MIL",
    "روما": "ROM", "roma": "ROM", "ROM": "ROM",
    "دبي": "DXB", "dubai": "DXB", "DXB": "DXB",
    "اسطنبول": "IST", "istanbul": "IST", "IST": "IST",
  };
  String _resolveCode(String input) {
    String clean = input.trim().toLowerCase();
    for (var e in cityToCode.entries) { if (e.key.toLowerCase() == clean) return e.value; }
    if (clean.length == 3) return clean.toUpperCase();
    return input.trim();
  }
  void _search() {
    final from = _resolveCode(_fromController.text);
    final to = _resolveCode(_toController.text);
    final next = DateTime.now().add(const Duration(days: 7));
    final day = next.day.toString().padLeft(2, '0');
    final month = next.month.toString().padLeft(2, '0');
    final url = 'https://www.aviasales.com/search/$from$day$month$to${1}?marker=$MARKER&with_request=true';
    _webController = WebViewController()
     ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
     ..loadRequest(Uri.parse(url));
    setState(() => _showWebView = true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showWebView? 'نتائج حقيقية' : 'طيران حقيقي'),
        backgroundColor: Colors.teal,
        leading: _showWebView? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showWebView = false)) : null,
      ),
      body: _showWebView? Stack(children: [WebViewWidget(controller: _webController), if (_isLoading) const LinearProgressIndicator(color: Colors.orange)]) : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _fromController, decoration: InputDecoration(labelText: "من - ميلانو / القاهرة", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          TextField(controller: _toController, decoration: InputDecoration(labelText: "إلى - القاهرة / جدة", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _search, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('ابحث طيران حقيقي €', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }
}

// ========== 3. فنادق حقيقي ==========
class HotelsPage extends StatefulWidget { const HotelsPage({super.key}); @override State<HotelsPage> createState() => _HotelsPageState(); }
class _HotelsPageState extends State<HotelsPage> {
  late WebViewController ctrl;
  @override void initState() { super.initState(); ctrl = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)..loadRequest(Uri.parse('https://www.aviasales.com/hotels?marker=774985')); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('فنادق حقيقية'), backgroundColor: Colors.purple), body: WebViewWidget(controller: ctrl)); }
}

// ========== 4. أماكن قريبة GPS حقيقي ==========
class NearbyPage extends StatefulWidget { const NearbyPage({super.key}); @override State<NearbyPage> createState() => _NearbyPageState(); }
class _NearbyPageState extends State<NearbyPage> {
  String loc = 'جاري تحديد موقعك...'; List places = []; bool loading = true;
  @override void initState() { super.initState(); _getLocation(); }
  Future<void> _getLocation() async {
    try {
      bool service = await Geolocator.isLocationServiceEnabled();
      if (!service) { setState(() => loc = 'شغل الـ GPS'); return; }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition();
      setState(() => loc = 'موقعك: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=[out:json];node(around:1000,${pos.latitude},${pos.longitude})[amenity];out 10;');
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      setState(() { places = data['elements']; loading = false; });
    } catch (e) { setState(() { loc = 'خطأ: $e'; loading = false; }); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أماكن قريبة حقيقية'), backgroundColor: Colors.red),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(loc, style: const TextStyle(fontWeight: FontWeight.bold))),
        if (loading) const CircularProgressIndicator() else Expanded(child: ListView.builder(itemCount: places.length, itemBuilder: (c, i) { final p = places[i]; return ListTile(leading: const Icon(Icons.place, color: Colors.red), title: Text(p['tags']?['name']?? 'مكان قريب'), subtitle: Text(p['tags']?['amenity']?? '')); })),
      ]),
    );
  }
}

// ========== 5. ترجمة حقيقية ==========
class TranslatePage extends StatefulWidget { const TranslatePage({super.key}); @override State<TranslatePage> createState() => _TranslatePageState(); }
class _TranslatePageState extends State<TranslatePage> {
  final ctrl = TextEditingController(text: 'السلام عليكم');
  String result = ''; bool loading = false;
  Future<void> _translate() async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(ctrl.text)}&langpair=ar|it'));
      final data = jsonDecode(res.body);
      setState(() => result = data['responseData']['translatedText']);
    } catch (e) { setState(() => result = 'خطأ'); }
    setState(() => loading = false);
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ترجمة حقيقية عربي-ايطالي'), backgroundColor: Colors.blue),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(labelText: 'اكتب عربي', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: _translate, child: Text(loading? 'جاري الترجمة...' : 'ترجم لإيطالي حقيقي'))),
        const SizedBox(height: 20),
        if (result.isNotEmpty) Card(color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(16), child: Text(result, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
      ])),
    );
  }
}

// ========== 6. خرائط حقيقية ==========
class MapsPage extends StatefulWidget { const MapsPage({super.key}); @override State<MapsPage> createState() => _MapsPageState(); }
class _MapsPageState extends State<MapsPage> {
  late WebViewController ctrl;
  @override void initState() { super.initState(); ctrl = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)..loadRequest(Uri.parse('https://www.openstreetmap.org/#map=6/26.0/44.0')); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('خريطة حية حقيقية'), backgroundColor: Colors.teal), body: WebViewWidget(controller: ctrl)); }
}
