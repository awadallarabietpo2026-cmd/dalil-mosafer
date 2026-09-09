// ================= صفحة الحجوزات الحقيقية 100% - تفهم عربي =================
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _fromController = TextEditingController(text: "ميلانو");
  final _toController = TextEditingController(text: "القاهرة");
  late WebViewController _webController;
  bool _showWebView = false;
  bool _isLoading = true;

  static const String MARKER = '774985';

  // خريطة المدن العربي والانجليزي -> كود المطار
  final Map<String, String> cityToCode = {
    // مصر
    "القاهرة": "CAI", "القاهره": "CAI", "cairo": "CAI", "CAI": "CAI",
    // السعودية
    "جدة": "JED", "جده": "JED", "jeddah": "JED", "JED": "JED",
    "الرياض": "RUH", "الرياض": "RUH", "riyadh": "RUH", "RUH": "RUH",
    "الدمام": "DMM", "DMM": "DMM",
    "المدينة": "MED", "المدينه": "MED", "MED": "MED",
    // ايطاليا
    "ميلانو": "MIL", "ميلان": "MIL", "milano": "MIL", "milan": "MIL", "MIL": "MIL",
    "ميلانو مالبينسا": "MXP", "MXP": "MXP",
    "روما": "ROM", "roma": "ROM", "rome": "ROM", "ROM": "ROM", "FCO": "FCO",
    "نابولي": "NAP", "NAP": "NAP",
    "البندقية": "VCE", "فينيسيا": "VCE",
    // الامارات
    "دبي": "DXB", "dubai": "DXB", "DXB": "DXB",
    "ابوظبي": "AUH", "ابو ظبي": "AUH",
    // تركيا
    "اسطنبول": "IST", "إسطنبول": "IST", "istanbul": "IST", "IST": "IST",
  };

  String _resolveCode(String input) {
    String clean = input.trim().toLowerCase();
    // دور مباشر
    for (var entry in cityToCode.entries) {
      if (entry.key.toLowerCase() == clean) return entry.value;
    }
    // لو كتب 3 حروف اعتبره كود مطار
    if (clean.length == 3) return clean.toUpperCase();
    // لو مش لاقي رجع نفس اللي كتبه (Aviasales بيفهم احيانا اسم المدينة)
    return input.trim();
  }

  void _searchRealFlights() {
    final fromRaw = _fromController.text.trim();
    final toRaw = _toController.text.trim();
    if (fromRaw.isEmpty || toRaw.isEmpty) return;

    String fromCode = _resolveCode(fromRaw);
    String toCode = _resolveCode(toRaw);

    final nextWeek = DateTime.now().add(const Duration(days: 7));
    final day = nextWeek.day.toString().padLeft(2, '0');
    final month = nextWeek.month.toString().padLeft(2, '0');

    final url = 'https://www.aviasales.com/search/$fromCode$day$month$toCode${1}?marker=$MARKER&with_request=true';

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
        title: Text(_showWebView ? 'نتائج حقيقية' : 'حجوزات طيران حقيقية'),
        backgroundColor: Colors.teal, centerTitle: true,
        leading: _showWebView ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showWebView = false)) : null,
      ),
      body: _showWebView
          ? Stack(children: [WebViewWidget(controller: _webController), if (_isLoading) const LinearProgressIndicator(color: Colors.orange, minHeight: 4)])
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("من أين؟", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: _fromController, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), decoration: InputDecoration(hintText: "مثال: ميلانو، القاهرة، MIL، CAI", prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.teal), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 20),
                const Text("إلى أين؟", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: _toController, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), decoration: InputDecoration(hintText: "مثال: القاهرة، جدة، دبي، روما", prefixIcon: const Icon(Icons.flight_land, color: Colors.teal), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 30),
                SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _searchRealFlights, icon: const Icon(Icons.search, color: Colors.white), label: const Text("ابحث الآن - يفهم عربي", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 15),
                const Text("تقدر تكتب بالعربي: القاهرة، ميلانو، جدة، الرياض، دبي، روما، اسطنبول", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
              ]),
            ),
    );
  }
}
