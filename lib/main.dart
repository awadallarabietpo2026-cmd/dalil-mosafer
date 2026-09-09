import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MusafirPro());

class MusafirPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليل مسافر برو',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomePage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("دليل مسافر برو", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00897B), centerTitle: true),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.95),
        itemCount: services.length,
        itemBuilder: (ctx, i) {
          var s = services[i];
          return InkWell(
            onTap: () {
              if (i == 0) Navigator.push(ctx, MaterialPageRoute(builder: (_) => FlightSearch()));
              else Navigator.push(ctx, MaterialPageRoute(builder: (_) => OtherServices(index: i, title: s["title"])));
            },
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

  void searchFlights() {
    setState(() {
      loading = true;
      flights = [
        {"price": 451, "airline": "Wizz Air", "departure": "16 Sep - 10:30", "duration": "مباشر", "link": "https://www.aviasales.com/search/${fromCtrl.text}1609${toCtrl.text}1?marker=$marker"},
        {"price": 389, "airline": "Turkish Airlines", "departure": "17 Sep - 14:15", "duration": "ترانزيت", "link": "https://www.aviasales.com/search/${fromCtrl.text}1709${toCtrl.text}1?marker=$marker"},
        {"price": 523, "airline": "ITA Airways", "departure": "18 Sep - 09:00", "duration": "مباشر", "link": "https://www.aviasales.com/search/${fromCtrl.text}1809${toCtrl.text}1?marker=$marker"},
        {"price": 412, "airline": "EgyptAir", "departure": "19 Sep - 22:45", "duration": "مباشر", "link": "https://www.aviasales.com/search/${fromCtrl.text}1909${toCtrl.text}1?marker=$marker"},
      ];
      loading = false;
    });
  }

  Future<void> bookFlight(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() { super.initState(); searchFlights(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("رحلات: ${fromCtrl.text} -> ${toCtrl.text}"), backgroundColor: Color(0xFF00897B)),
      body: Column(children: [
        Container(padding: EdgeInsets.all(16), color: Colors.grey[50], child: Row(children: [
          Expanded(child: TextField(controller: fromCtrl, decoration: InputDecoration(labelText: "من", border: OutlineInputBorder(), isDense: true))),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward),
          SizedBox(width: 8),
          Expanded(child: TextField(controller: toCtrl, decoration: InputDecoration(labelText: "الى", border: OutlineInputBorder(), isDense: true))),
          SizedBox(width: 8),
          ElevatedButton(onPressed: searchFlights, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Icon(Icons.search))
        ])),
        if (loading) Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()),
        if (!loading) Expanded(child: ListView.builder(padding: EdgeInsets.all(12), itemCount: flights.length, itemBuilder: (ctx, i) {
          var f = flights[i];
          return Card(margin: EdgeInsets.only(bottom: 12), elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: ListTile(
            leading: Icon(Icons.flight, color: Colors.orange),
            title: Text("${f['airline']}", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${f['departure']} - ${f['duration']}"),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("EUR ${f['price']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
              ElevatedButton(onPressed: () => bookFlight(f['link']), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: Size(70, 28)), child: Text("احجز", style: TextStyle(fontSize: 12)))
            ]),
          ));
        })),
      ]),
    );
  }
}

class OtherServices extends StatefulWidget {
  final int index;
  final String title;
  OtherServices({required this.index, required this.title});
  @override _OtherServicesState createState() => _OtherServicesState();
}

class _OtherServicesState extends State<OtherServices> {
  String data = "جاري التحميل...";
  @override
  void initState() { super.initState(); load(); }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  load() async {
    if (widget.index == 1) {
      try {
        var r = await http.get(Uri.parse("https://api.exchangerate-api.com/v4/latest/EUR"));
        var j = json.decode(r.body);
        setState(() => data = "اسعار اليوم:\n\n1 يورو = ${j['rates']['EGP'].toStringAsFixed(2)} جنيه\n1 يورو = ${j['rates']['USD'].toStringAsFixed(2)} دولار");
      }
      catch (e) { setState(() => data = "1 يورو = 54.20 جنيه مصري"); }
    }
    else if (widget.index == 2) {
      await openUrl("https://www.booking.com/city/it/milan.html");
      if(mounted) Navigator.pop(context);
    }
    else if (widget.index == 3) {
      try {
        LocationPermission p = await Geolocator.checkPermission();
        if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
        var pos = await Geolocator.getCurrentPosition();
        await openUrl("https://www.google.com/maps/search/restaurants+mosques/@${pos.latitude},${pos.longitude},15z");
      } catch (e) {
        await openUrl("https://www.google.com/maps/search/milan+restaurants");
      }
      if(mounted) Navigator.pop(context);
    }
    else if (widget.index == 4) setState(() => data = "ترجمة:\n\nمرحبا = Ciao\nشكرا = Grazie\nكم السعر؟ = Quanto costa?");
    else if (widget.index == 5) {
      await openUrl("https://www.google.com/maps/@45.4642,9.1900,14z");
      if(mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Color(0xFF00897B)),
      body: Center(child: Padding(padding: EdgeInsets.all(24), child: Text(data, style: TextStyle(fontSize: 20, height: 1.6), textAlign: TextAlign.center)))
    );
  }
}
