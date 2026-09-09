import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  await Hive.openBox('history');
  await Hive.openBox('settings');
  runApp(MusafirPro());
}

class MusafirPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليل مسافر برو',
      theme: ThemeData(primarySwatch: Colors.teal, scaffoldBackgroundColor: Color(0xFFF5F7F8)),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget { @override _MainScreenState createState() => _MainScreenState(); }

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final screens = [HomePage(), FavoritesPage(), HistoryPage(), ProfilePage()];
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF00897B),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "المفضلة"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "السجل"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {"icon": Icons.flight, "color": Colors.orange, "title": "حجوزات طيران", "sub": "MIL - CAI"},
    {"icon": Icons.currency_exchange, "color": Colors.green, "title": "تحويل العملات", "sub": "EUR / EGP / USD"},
    {"icon": Icons.hotel, "color": Colors.purple, "title": "حجوزات فنادق", "sub": "Booking.com"},
    {"icon": Icons.location_on, "color": Colors.red, "title": "اماكن قريبة", "sub": "مطاعم - مساجد"},
    {"icon": Icons.translate, "color": Colors.blue, "title": "ترجمة فورية", "sub": "عربي - ايطالي"},
    {"icon": Icons.map, "color": Colors.teal, "title": "خرائط", "sub": "خرائط ميلانو"},
  ];
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("دليل مسافر برو", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00897B), centerTitle: true),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.95),
        itemCount: services.length,
        itemBuilder: (ctx, i) {
          var s = services[i];
          return InkWell(
            onTap: () { if (i == 0) Navigator.push(ctx, MaterialPageRoute(builder: (_) => FlightSearch())); else Navigator.push(ctx, MaterialPageRoute(builder: (_) => OtherServices(index: i, title: s["title"]))); },
            child: Card(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: s["color"].withOpacity(0.15), shape: BoxShape.circle), child: Icon(s["icon"], size: 48, color: s["color"])),
              SizedBox(height: 14),
              Text(s["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 5),
              Text(s["sub"], style: TextStyle(color: Colors.grey[600], fontSize: 11), textAlign: TextAlign.center),
            ])),
          );
        },
      ),
    );
  }
}

class FlightSearch extends StatefulWidget { @override _FlightSearchState createState() => _FlightSearchState(); }

class _FlightSearchState extends State<FlightSearch> {
  TextEditingController fromCtrl = TextEditingController(text: "MIL");
  TextEditingController toCtrl = TextEditingController(text: "CAI");
  List flights = [];
  bool loading = false;
  final String marker = "774985";
  var favBox = Hive.box('favorites');
  var historyBox = Hive.box('history');

  @override void initState() { super.initState(); searchFlights(); }

  void searchFlights() async {
    setState(() => loading = true);
    var searchKey = "${fromCtrl.text}-${toCtrl.text}-${DateTime.now().toString().substring(0,16)}";
    historyBox.put(searchKey, {"from": fromCtrl.text, "to": toCtrl.text, "date": DateTime.now().toString()});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lastSearches = prefs.getStringList('lastSearches')?? [];
    lastSearches.insert(0, "${fromCtrl.text} -> ${toCtrl.text}");
    if (lastSearches.length > 10) lastSearches = lastSearches.sublist(0,10);
    await prefs.setStringList('lastSearches', lastSearches);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      flights = [
        {"id": "${fromCtrl.text}${toCtrl.text}1", "price": 451, "airline": "Wizz Air", "departure": "16 Sep - 10:30", "duration": "مباشر", "link": "https://www.aviasales.com/search/${fromCtrl.text}1609${toCtrl.text}1?marker=$marker"},
        {"id": "${fromCtrl.text}${toCtrl.text}2", "price": 389, "airline": "Turkish Airlines", "departure": "17 Sep - 14:15", "duration": "ترانزيت", "link": "https://www.aviasales.com/search/${fromCtrl.text}1709${toCtrl.text}1?marker=$marker"},
        {"id": "${fromCtrl.text}${toCtrl.text}3", "price": 523, "airline": "ITA Airways", "departure": "18 Sep - 09:00", "duration": "مباشر", "link": "https://www.aviasales.com/search/${fromCtrl.text}1809${toCtrl.text}1?marker=$marker"},
        {"id": "${fromCtrl.text}${toCtrl.text}4", "price": 412, "airline": "EgyptAir", "departure": "19 Sep - 22:45", "duration": "مباشر", "link": "https://www.aviasales.com/search/${fromCtrl.text}1909${toCtrl.text}1?marker=$marker"},
      ];
      loading = false;
    });
  }

  void toggleFavorite(Map flight) {
    if (favBox.containsKey(flight['id'])) {
      favBox.delete(flight['id']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم الحذف من المفضلة")));
    } else {
      favBox.put(flight['id'], flight);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم الحفظ في المفضلة ❤️"), backgroundColor: Colors.green));
    }
    setState(() {});
  }

  Future<void> bookFlight(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("رحلات: ${fromCtrl.text} -> ${toCtrl.text}"), backgroundColor: Color(0xFF00897B)),
      body: Column(children: [
        Container(padding: EdgeInsets.all(16), color: Colors.white, child: Row(children: [
          Expanded(child: TextField(controller: fromCtrl, decoration: InputDecoration(labelText: "من", border: OutlineInputBorder(), isDense: true))),
          SizedBox(width: 8), Icon(Icons.arrow_forward), SizedBox(width: 8),
          Expanded(child: TextField(controller: toCtrl, decoration: InputDecoration(labelText: "الى", border: OutlineInputBorder(), isDense: true))),
          SizedBox(width: 8),
          ElevatedButton(onPressed: searchFlights, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Icon(Icons.search))
        ])),
        if (loading) Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()),
        if (!loading) Expanded(child: ListView.builder(padding: EdgeInsets.all(12), itemCount: flights.length, itemBuilder: (ctx, i) {
          var f = flights[i];
          bool isFav = favBox.containsKey(f['id']);
          return Card(margin: EdgeInsets.only(bottom: 12), elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: ListTile(
            leading: IconButton(icon: Icon(isFav?Icons.favorite:Icons.favorite_border, color: isFav?Colors.red:Colors.grey), onPressed: ()=>toggleFavorite(f)),
            title: Text("${f['airline']}", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${f['departure']} - ${f['duration']}"),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("€${f['price']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
              ElevatedButton(onPressed: () => bookFlight(f['link']), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: Size(70, 28)), child: Text("احجز", style: TextStyle(fontSize: 12)))
            ]),
          ));
        })),
      ]),
    );
  }
}

class FavoritesPage extends StatefulWidget { @override _FavoritesPageState createState() => _FavoritesPageState(); }
class _FavoritesPageState extends State<FavoritesPage> {
  var favBox = Hive.box('favorites');
  Future<void> bookFlight(String url) async { final uri = Uri.parse(url); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("المفضلة ❤️"), backgroundColor: Color(0xFF00897B)), body: ValueListenableBuilder(valueListenable: favBox.listenable(), builder: (ctx, Box box, _) {
      if (box.isEmpty) return Center(child: Text("لا يوجد رحلات محفوظة"));
      return ListView.builder(padding: EdgeInsets.all(12), itemCount: box.length, itemBuilder: (ctx, i) {
        var key = box.keyAt(i); var f = box.get(key);
        return Card(child: ListTile(title: Text(f['airline']), subtitle: Text("€${f['price']}"), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: ()=>box.delete(key))));
      });
    }));
  }
}

class HistoryPage extends StatefulWidget { @override _HistoryPageState createState() => _HistoryPageState(); }
class _HistoryPageState extends State<HistoryPage> {
  var historyBox = Hive.box('history');
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("سجل البحث"), backgroundColor: Color(0xFF00897B), actions: [IconButton(icon: Icon(Icons.delete_forever), onPressed: ()=>historyBox.clear())]), body: ValueListenableBuilder(valueListenable: historyBox.listenable(), builder: (ctx, Box box, _) {
      if (box.isEmpty) return Center(child: Text("لا يوجد سجل"));
      var keys = box.keys.toList().reversed.toList();
      return ListView.builder(itemCount: keys.length, itemBuilder: (ctx, i) {
        var data = box.get(keys[i]); return Card(child: ListTile(title: Text("${data['from']} -> ${data['to']}"), subtitle: Text(data['date'].toString().substring(0,16))));
      });
    }));
  }
}

class ProfilePage extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("حسابي"), backgroundColor: Color(0xFF00897B)), body: ListView(padding: EdgeInsets.all(16), children: [
      Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [CircleAvatar(radius: 40, backgroundColor: Color(0xFF00897B), child: Icon(Icons.person, size: 40, color: Colors.white)), SizedBox(height: 12), Text("عوض الله ربيع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text("مقيم في ميلانو")]))),
      Card(child: ListTile(leading: Icon(Icons.storage, color: Colors.teal), title: Text("قاعدة البيانات"), subtitle: Text("Hive + SharedPreferences - تحفظ Offline"))),
      Card(child: ListTile(leading: Icon(Icons.code, color: Colors.orange), title: Text("كود العمولة"), subtitle: Text("774985"))),
    ]));
  }
}

class OtherServices extends StatefulWidget { final int index; final String title; OtherServices({required this.index, required this.title}); @override _OtherServicesState createState() => _OtherServicesState(); }
class _OtherServicesState extends State<OtherServices> {
  String data = "جاري التحميل...";
  @override void initState() { super.initState(); load(); }
  Future<void> openUrl(String url) async { final uri = Uri.parse(url); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }
  load() async {
    if (widget.index == 1) {
      try { var r = await http.get(Uri.parse("https://api.exchangerate-api.com/v4/latest/EUR")); var j = json.decode(r.body); setState(() => data = "1€ = ${j['rates']['EGP'].toStringAsFixed(2)} EGP\n1€ = ${j['rates']['USD'].toStringAsFixed(2)} USD"); } catch (e) { setState(() => data = "1€ = 54.20 جنيه"); }
    } else if (widget.index == 2) { await openUrl("https://www.booking.com/city/it/milan.html"); if(mounted) Navigator.pop(context); }
    else if (widget.index == 3) { await openUrl("https://www.google.com/maps/search/milan+restaurants"); if(mounted) Navigator.pop(context); }
    else if (widget.index == 4) setState(() => data = "Ciao = مرحبا\nGrazie = شكرا");
    else if (widget.index == 5) { await openUrl("https://www.google.com/maps/@45.4642,9.1900,14z"); if(mounted) Navigator.pop(context); }
  }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text(widget.title), backgroundColor: Color(0xFF00897B)), body: Center(child: Text(data, style: TextStyle(fontSize: 20), textAlign: TextAlign.center))); }
}
