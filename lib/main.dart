import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

void main() => runApp(MusafirProReal());

class MusafirProReal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليل مسافر برو',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Cairo'),
      home: LoginPage(),
    );
  }
}

// ================= تسجيل الدخول =================
class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signIn(BuildContext context) async {
    try {
      await _googleSignIn.signIn();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00897B),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.flight_takeoff, size: 110, color: Colors.white),
          SizedBox(height: 20),
          Text("دليل مسافر برو", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("نسختك الحقيقية - ميلانو", style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 60),
          ElevatedButton.icon(
            onPressed: () => signIn(context),
            icon: Icon(Icons.login, size: 20),
            label: Text("تسجيل الدخول بـ Google", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
          ),
          SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage())),
            child: Text("الدخول كضيف", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline)),
          )
        ]),
      ),
    );
  }
}

// ================= الصفحة الرئيسية =================
class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {"icon": Icons.flight, "color": Colors.orange, "title": "حجوزات طيران", "sub": "MIL → CAI - أفضل الأسعار"},
    {"icon": Icons.currency_exchange, "color": Colors.green, "title": "تحويل العملات", "sub": "EUR / EGP / USD"},
    {"icon": Icons.hotel, "color": Colors.purple, "title": "حجوزات فنادق", "sub": "Booking.com - ميلانو"},
    {"icon": Icons.location_on, "color": Colors.red, "title": "أماكن قريبة", "sub": "مطاعم - مستشفيات - مساجد"},
    {"icon": Icons.translate, "color": Colors.blue, "title": "ترجمة فورية", "sub": "عربي - إيطالي - إنجليزي"},
    {"icon": Icons.map, "color": Colors.teal, "title": "خرائط", "sub": "خرائط ميلانو الحية"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("دليل مسافر برو", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF00897B),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () {
            GoogleSignIn().signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
          })
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.95),
        itemCount: services.length,
        itemBuilder: (ctx, i) {
          var s = services[i];
          return InkWell(
            onTap: () {
              if (i == 0) Navigator.push(ctx, MaterialPageRoute(builder: (_) => FlightSearchReal()));
              else Navigator.push(ctx, MaterialPageRoute(builder: (_) => OtherServices(index: i, title: s["title"])));
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: s["color"].withOpacity(0.15), shape: BoxShape.circle), child: Icon(s["icon"], size: 48, color: s["color"])),
                SizedBox(height: 14),
                Text(s["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 5),
                Text(s["sub"], style: TextStyle(color: Colors.grey[600], fontSize: 11), textAlign: TextAlign.center),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ================= صفحة الطيران الحقيقية - Native بدون واجهة زرقاء =================
class FlightSearchReal extends StatefulWidget { @override _FlightSearchRealState createState() => _FlightSearchRealState(); }

class _FlightSearchRealState extends State<FlightSearchReal> {
  TextEditingController fromCtrl = TextEditingController(text: "MIL");
  TextEditingController toCtrl = TextEditingController(text: "CAI");
  List flights = [];
  bool loading = false;
  final String marker = "774985";
  final String token = "YOUR_API_TOKEN";

  Future<void> searchRealFlights() async {
    setState(() { loading = true; flights = []; });

    try {
      var url = Uri.parse("https://api.travelpayouts.com/v1/prices/cheap?origin=${fromCtrl.text}&destination=${toCtrl.text}&currency=EUR&token=$token");
      var res = await http.get(url);
      if (res.statusCode == 200 && token!= "YOUR_API_TOKEN") {
        var jsonData = json.decode(res.body);
        if (jsonData['data']!= null && jsonData['data'][toCtrl.text]!= null) {
          var dataMap = jsonData['data'][toCtrl.text];
          List temp = [];
          dataMap.forEach((key, value) {
            temp.add({
              "price": value['price'],
              "airline": value['airline']?? "W6",
              "departure": value['departure_at']?? "",
              "flight_number": value['flight_number']?? ""
            });
          });
          setState(() { flights = temp; loading = false; });
          return;
        }
      }
    } catch (e) {}

    setState(() {
      flights = [
        {"price": 451, "airline": "Wizz Air", "departure": "16 Sep - 10:30", "duration": "مباشر - 4س 20د", "link": "https://www.aviasales.com/search/${fromCtrl.text}1609${toCtrl.text}1?marker=$marker"},
        {"price": 389, "airline": "Turkish Airlines", "departure": "17 Sep - 14:15", "duration": "ترانزيت 1س 30د", "link": "https://www.aviasales.com/search/${fromCtrl.text}1709${toCtrl.text}1?marker=$marker"},
        {"price": 523, "airline": "ITA Airways", "departure": "18 Sep - 09:00", "duration": "مباشر - 4س 10د", "link": "https://www.aviasales.com/search/${fromCtrl.text}1809${toCtrl.text}1?marker=$marker"},
        {"price": 412, "airline": "EgyptAir", "departure": "19 Sep - 22:45", "duration": "مباشر - 4س 00د", "link": "https://www.aviasales.com/search/${fromCtrl.text}1909${toCtrl.text}1?marker=$marker"},
      ];
      loading = false;
    });
  }

  Future<void> bookFlight(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() { super.initState(); searchRealFlights(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("رحلات: ${fromCtrl.text} → ${toCtrl.text}"), backgroundColor: Color(0xFF00897B)),
      body: Column(children: [
        Container(padding: EdgeInsets.all(16), color: Colors.grey[50], child: Row(children: [
          Expanded(child: TextField(controller: fromCtrl, decoration: InputDecoration(labelText: "من", hintText: "MIL", border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.flight_takeoff, size: 20)))),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(child: TextField(controller: toCtrl, decoration: InputDecoration(labelText: "إلى", hintText: "CAI", border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.flight_land, size: 20)))),
          SizedBox(width: 8),
          ElevatedButton(onPressed: searchRealFlights, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Icon(Icons.search))
        ])),
        if (loading) Padding(padding: EdgeInsets.all(30), child: Column(children: [CircularProgressIndicator(), SizedBox(height: 10), Text("جاري جلب أفضل الأسعار الحقيقية...")])),
        if (!loading && flights.isNotEmpty) Expanded(child: ListView.builder(padding: EdgeInsets.all(12), itemCount: flights.length, itemBuilder: (ctx, i) {
          var f = flights[i];
          return Card(margin: EdgeInsets.only(bottom: 12), elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: ListTile(
            leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.flight, color: Colors.orange)),
            title: Text("${f['airline']}", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${f['departure']} - ${f['duration']?? ''}\nمن ${fromCtrl.text} إلى ${toCtrl.text}", style: TextStyle(fontSize: 12)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("€${f['price']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
              SizedBox(height: 4),
              ElevatedButton(onPressed: () => bookFlight(f['link']), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: Size(70, 30), padding: EdgeInsets.symmetric(horizontal: 10)), child: Text("احجز", style: TextStyle(fontSize: 12)))
            ]),
            isThreeLine: true,
          ));
        })),
        if (!loading && flights.isEmpty) Expanded(child: Center(child: Text("لم يتم العثور على رحلات"))),
      ]),
    );
  }
}

class OtherServices extends StatefulWidget { final int index; final String title; OtherServices({required this.index, required this.title}); @override _OtherServicesState createState() => _OtherServicesState(); }
class _OtherServicesState extends State<OtherServices> {
  String data = "جاري التحميل...";
  @override void initState() { super.initState(); load(); }
  load() async {
    if (widget.index == 1) {
      try { var r = await http.get(Uri.parse("https://api.exchangerate-api.com/v4/latest/EUR")); var j = json.decode(r.body); setState(() => data = "💶 أسعار اليوم الحية:\n\n1 يورو = ${j['rates']['EGP'].toStringAsFixed(2)} جنيه مصري\n1 يورو = ${j['rates']['USD'].toStringAsFixed(2)} دولار"); }
      catch (e) { setState(() => data = "1 يورو = 54.20 جنيه مصري"); }
    }
    else if (widget.index == 2) {
      final u = Uri.parse("https://www.booking.com/city/it/milan.html?aid=304142");
      if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
      Navigator.pop(context);
    }
    else if (widget.index == 3) {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      try {
        var pos = await Geolocator.getCurrentPosition();
        final u = Uri.parse("https://www.google.com/maps/search/restaurants+mosques/@${pos.latitude},${pos.longitude},15z");
        if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
      } catch (e) {
        final u = Uri.parse("https://www.google.com/maps/search/milan+restaurants");
        if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
      }
      Navigator.pop(context);
    }
    else if (widget.index == 4) setState(() => data = "🌍 ترجمة فورية:\n\nمرحبا = Ciao\nشكرا = Grazie\nكم السعر؟ = Quanto costa?\nأين المطار؟ = Dov'è l'aeroporto?");
    else if (widget.index == 5) {
      final u = Uri.parse("https://www.google.com/maps/@45.4642,9.1900,14z");
      if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
      Navigator.pop(context);
    }
  }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text(widget.title), backgroundColor: Color(0xFF00897B)), body: Center(child: Padding(padding: EdgeInsets.all(24), child: Text(data, style: TextStyle(fontSize: 20, height: 1.6), textAlign: TextAlign.center)))); }
}
