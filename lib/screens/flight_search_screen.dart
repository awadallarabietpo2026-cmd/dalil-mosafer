import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/airport_service.dart';
import '../widgets/city_autocomplete_field.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  AirportSuggestion? _origin;
  AirportSuggestion? _destination;
  DateTime _departDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _departDate = picked);
  }

  void _search() {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك اختر مدينة الانطلاق والوجهة')),
      );
      return;
    }

    final ddmm =
        '${_departDate.day.toString().padLeft(2, '0')}${_departDate.month.toString().padLeft(2, '0')}';
    final url =
        'https://www.aviasales.com/search/${_origin!.code}$ddmm${_destination!.code}1?marker=774985';

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FlightResultsScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بحث عن رحلات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CityAutocompleteField(
              label: 'من',
              onSelected: (item) => setState(() => _origin = item),
            ),
            const SizedBox(height: 16),
            CityAutocompleteField(
              label: 'إلى',
              onSelected: (item) => setState(() => _destination = item),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'تاريخ السفر: ${_departDate.year}-${_departDate.month.toString().padLeft(2, '0')}-${_departDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _search,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('ابحث الآن', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightResultsScreen extends StatefulWidget {
  final String url;
  const _FlightResultsScreen({required this.url});

  @override
  State<_FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<_FlightResultsScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نتائج البحث')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
