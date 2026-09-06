import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
            title: 'تحويل عملات',
            subtitle: 'أسعار لحظية',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrencyPage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.confirmation_number,
            title: 'حجوزات',
            subtitle: 'طيران، فنادق، قطارات',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingPage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.location_on,
            title: 'أماكن قريبة',
            subtitle: 'مستشفى، صيدلية، شرطة',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyPage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.translate,
            title: 'ترجمة فورية',
            subtitle: 'جمل جاهزة أوفلاين',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TranslatePage()),
            ),
          ),
          _ServiceCard(
            icon: Icons.map,
            title: 'خرائط أوفلاين',
            subtitle: 'دليل التحميل قبل السفر',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OfflineMapsPage()),
            ),
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

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.teal),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------ شاشة تحويل العملات (شغالة فعلياً) ------

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final List<String> currencies = [
    'USD', 'EUR', 'EGP', 'GBP', 'SAR', 'AED', 'KWD', 'JPY', 'TRY', 'CNY'
  ];

  String fromCurrency = 'USD';
  String toCurrency = 'EGP';
  final TextEditingController amountController =
      TextEditingController(text: '1');

  bool isLoading = false;
  String? result;
  String? errorMessage;

  Future<void> convertCurrency() async {
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'من فضلك أدخل رقم صحيح';
        result = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      final url = Uri.parse(
        'https://api.frankfurter.app/latest?amount=$amount&from=$fromCurrency&to=$toCurrency',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rateValue = data['rates'][toCurrency];
        setState(() {
          result =
              '$amount $fromCurrency = ${rateValue.toStringAsFixed(2)} $toCurrency';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'حصل خطأ، حاول تاني';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'مفيش اتصال بالإنترنت';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحويل عملات'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fromCurrency,
                    decoration: const InputDecoration(
                      labelText: 'من',
                      border: OutlineInputBorder(),
                    ),
                    items: currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => fromCurrency = value!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      final temp = fromCurrency;
                      fromCurrency = toCurrency;
                      toCurrency = temp;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'إلى',
                      border: OutlineInputBorder(),
                    ),
                    items: currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => toCurrency = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading ? null : convertCurrency,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'تحويل',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            if (result != null)
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    result!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// ------ باقي الشاشات (لسه فاضية، هنملاها في المراحل الجاية) ------

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزات'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أماكن قريبة'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}

class TranslatePage extends StatelessWidget {
  const TranslatePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ترجمة فورية'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}

class OfflineMapsPage extends StatelessWidget {
  const OfflineMapsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خرائط أوفلاين'), backgroundColor: Colors.teal),
      body: const Center(child: Text('هنبني الميزة دي لاحقاً 🚧')),
    );
  }
}
