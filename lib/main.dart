import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';

const String MARKER = '774985';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  runApp(const DalilApp());
}

class DalilApp extends StatelessWidget {
  const DalilApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليل مسافر برو',
      home: const MainTabs(),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int idx = 0;
  final pages = [const FlightsTab(), const HotelsTab(), const NearbyTab(), const AccountTab()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i)=> setState(()=> idx=i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00897B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff), label: 'طيران'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel_outlined), label: 'فنادق'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'قريب مني'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }
}

class FlightsTab extends StatefulWidget {
  const FlightsTab({super.key});
  @override
  State<FlightsTab> createState() => _FlightsTabState();
}

class _FlightsTabState extends State<FlightsTab> {
  final fromC = TextEditingController(text: 'MIL');
  final toC = TextEditingController(text: 'CAI');
  Future<void> book(String from, String to) async {
    final uri = Uri.parse('https://www.aviasales.com/search/$from${to}1?marker=774985&with_request=true');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF00897B), title: Text('رحلات: ${fromC.text} -> ${toC.text}')),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: TextField(controller: fromC, decoration: InputDecoration(labelText: 'من', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward)),
          Expanded(child: TextField(controller: toC, decoration: InputDecoration(labelText: 'إلى', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 8),
          CircleAvatar(backgroundColor: const Color(0xFFFF8F00), radius: 24, child: IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: ()=> setState((){}))),
        ])),
        Expanded(child: ListView(children: [
          _card('Wizz Air','€451','16 Sep - 10:30 - مباشر',Colors.pink),
          _card('Turkish Airlines','€389','17 Sep - 14:15 - ترانزيت',Colors.red),
          _card('ITA Airways','€523','18 Sep - 09:00 - مباشر',Colors.blue),
          _card('EgyptAir','€412','19 Sep - 22:45 - مباشر',Colors.indigo),
        ])),
      ]),
    );
  }
  Widget _card(String a,String p,String t,Color c){
    return Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      const Icon(Icons.favorite_border, color: Colors.grey),
      const SizedBox(width:12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a, style: const TextStyle(fontWeight: FontWeight.bold)), Text(t, style: const TextStyle(color: Colors.grey, fontSize:12))])),
      Column(children: [Text(p, style: const TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold, fontSize:18)), ElevatedButton(onPressed: ()=> book(fromC.text, toC.text), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8F00)), child: const Text('احجز', style: TextStyle(color: Colors.white)))]),
    ])));
  }
}

class HotelsTab extends StatefulWidget {
  const HotelsTab({super.key});
  @override
  State<HotelsTab> createState() => _HotelsTabState();
}
class _HotelsTabState extends State<HotelsTab> {
  final cityC = TextEditingController(text: 'Cairo');
  Future<void> bookH(String city) async {
    final uri = Uri.parse('https://www.hotellook.com/?marker=774985&city=$city&currency=eur&locale=ar');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: const Color(0xFF00897B), title: Text('فنادق: ${cityC.text}')), body: Column(children: [
      Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: TextField(controller: cityC, decoration: InputDecoration(labelText: 'المدينة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width:8), CircleAvatar(backgroundColor: const Color(0xFFFF8F00), radius:24, child: IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: ()=> setState((){})))])),
      Expanded(child: ListView(children: [
        Card(child: ListTile(title: const Text('Hilton Cairo'), subtitle: const Text('⭐ 4.5 - وسط البلد'), trailing: ElevatedButton(onPressed: ()=> bookH(cityC.text), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('احجز')))),
        Card(child: ListTile(title: const Text('Marriott Mena House'), subtitle: const Text('⭐ 4.8 - الأهرامات'), trailing: ElevatedButton(onPressed: ()=> bookH(cityC.text), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('احجز')))),
      ])),
    ]));
  }
}

class NearbyTab extends StatefulWidget {
  const NearbyTab({super.key});
  @override
  State<NearbyTab> createState() => _NearbyTabState();
}
class _NearbyTabState extends State<NearbyTab> {
  String loc = 'اضغط لتحديد موقعك';
  Future<void> openMap(String q) async {
    try{
      LocationPermission p = await Geolocator.checkPermission();
      if(p==LocationPermission.denied) p = await Geolocator.requestPermission();
      final pos = await Geolocator.getCurrentPosition();
      setState(()=> loc = "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}");
      final uri = Uri.parse('https://www.google.com/maps/search/$q/@${pos.latitude},${pos.longitude},14z');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }catch(e){
      final uri = Uri.parse('https://www.google.com/maps/search/$q/');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: const Color(0xFF00897B), title: const Text('خرائط و قريب مني')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Card(child: ListTile(leading: const Icon(Icons.my_location, color: Color(0xFF00897B)), title: Text(loc), subtitle: const Text('GPS حقيقي'), onTap: ()=> openMap(''))),
      Expanded(child: GridView.count(crossAxisCount:2, children: [
        Card(child: InkWell(onTap: ()=> openMap('hotels near me'), child: const Center(child: Text('🏨 فنادق قريبة')))),
        Card(child: InkWell(onTap: ()=> openMap('restaurants near me'), child: const Center(child: Text('🍽️ مطاعم قريبة')))),
        Card(child: InkWell(onTap: ()=> openMap('gas station near me'), child: const Center(child: Text('⛽ بنزين')))),
        Card(child: InkWell(onTap: ()=> openMap('hospital near me'), child: const Center(child: Text('🏥 مستشفى')))),
      ])),
    ])));
  }
}

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: const Color(0xFF00897B), title: const Text('الإعدادات')), body: ListView(children: [
      const Padding(padding: EdgeInsets.all(16), child: Text('المنطقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize:18))),
      const ListTile(title: Text('العملة'), subtitle: Text('يورو'), trailing: Icon(Icons.chevron_left)),
      const Divider(),
      const ListTile(title: Text('اختر البلد أو المنطقة'), subtitle: Text('إيطاليا'), trailing: Icon(Icons.chevron_left)),
      const Divider(),
      ListTile(title: const Text('اللغة'), trailing: const Icon(Icons.open_in_new), onTap: () async { await launchUrl(Uri.parse('https://awadallarabieto2026-cmd.github.io/dalil-mosafer/privacy.html'), mode: LaunchMode.externalApplication); }),
      const Padding(padding: EdgeInsets.all(16), child: Text('أخرى', style: TextStyle(fontWeight: FontWeight.bold, fontSize:18))),
      const ListTile(title: Text('خيارات التسويق'), trailing: Icon(Icons.chevron_left)),
      const Divider(),
      const ListTile(title: Text('إعدادات البيانات'), trailing: Icon(Icons.chevron_left)),
      const Padding(padding: EdgeInsets.all(16), child: Text('الدعم', style: TextStyle(fontWeight: FontWeight.bold, fontSize:18))),
      ListTile(title: const Text('الحصول على المساعدة'), trailing: const Icon(Icons.open_in_new), onTap: () async { await launchUrl(Uri.parse('https://www.travelpayouts.com/support'), mode: LaunchMode.externalApplication); }),
      const Divider(),
      ListTile(title: const Text('تقييم التطبيق'), trailing: const Icon(Icons.open_in_new), onTap: () async { await launchUrl(Uri.parse('https://play.google.com/store'), mode: LaunchMode.externalApplication); }),
      const Padding(padding: EdgeInsets.all(16), child: Text('الشروط والسياسات', style: TextStyle(fontWeight: FontWeight.bold, fontSize:18))),
      ListTile(title: const Text('سياسة الخصوصية'), trailing: const Icon(Icons.open_in_new), onTap: () async { await launchUrl(Uri.parse('https://awadallarabieto2026-cmd.github.io/dalil-mosafer/privacy.html'), mode: LaunchMode.externalApplication); }),
      const Divider(),
      const ListTile(title: Text('شروط الخدمة'), trailing: Icon(Icons.open_in_new)),
      const Divider(),
      const ListTile(title: Text('تراخيص الطرف الثالث'), trailing: Icon(Icons.chevron_left)),
      const Divider(),
      const ListTile(title: Text('بيان سهولة الوصول'), trailing: Icon(Icons.open_in_new)),
      const Padding(padding: EdgeInsets.all(16), child: Text('بياناتك', style: TextStyle(fontWeight: FontWeight.bold, fontSize:18))),
      const ListTile(title: Text('معلومات تسجيل الدخول'), trailing: Icon(Icons.chevron_left)),
      const Divider(),
      const ListTile(title: Text('إدارة الحساب'), trailing: Icon(Icons.chevron_left)),
      const Divider(),
      const ListTile(title: Text('تسجيل الخروج', style: TextStyle(color: Colors.blue))),
      const SizedBox(height:30),
      const Center(child: Text('دليل مسافر برو - عوض الله ربيع - 774985', style: TextStyle(color: Colors.grey, fontSize:12))),
    ]));
  }
}
