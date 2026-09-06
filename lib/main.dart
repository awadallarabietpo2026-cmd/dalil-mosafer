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

// ------ شاشة الأماكن القريبة (شغالة فعلياً) ------

class NearbyPlace {
  final String name;
  final String type;
  final double lat;
  final double lon;

  NearbyPlace({
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
  });
}

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  String selectedType = 'hospital';
  bool isLoading = false;
  String? errorMessage;
  List<NearbyPlace> places = [];

  final Map<String, String> typeLabels = {
    'hospital': 'مستشفى',
    'pharmacy': 'صيدلية',
    'police': 'شرطة',
  };

  final Map<String, IconData> typeIcons = {
    'hospital': Icons.local_hospital,
    'pharmacy': Icons.local_pharmacy,
    'police': Icons.local_police,
  };

  Future<void> searchNearby() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      places = [];
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'من فضلك فعّل خدمة الموقع (GPS)';
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'محتاجين إذن الوصول للموقع عشان الميزة دي تشتغل';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'إذن الموقع مرفوض بشكل دائم، فعّله من إعدادات الجهاز';
          isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final query = '''
        [out:json];
        (
          node["amenity"="$selectedType"](around:5000,${position.latitude},${position.longitude});
        );
        out body 20;
      ''';

      final url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;

        final results = elements.map((e) {
          final tags = e['tags'] ?? {};
          return NearbyPlace(
            name: tags['name'] ?? 'بدون اسم',
            type: selectedType,
            lat: e['lat'],
            lon: e['lon'],
          );
        }).toList();

        setState(() {
          places = results.cast<NearbyPlace>();
          isLoading = false;
          if (places.isEmpty) {
            errorMessage = 'مفيش نتائج قريبة منك';
          }
        });
      } else {
        setState(() {
          errorMessage = 'حصل خطأ في السيرفر، حاول تاني';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حصلت مشكلة، تأكد من الاتصال بالإنترنت والموقع';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أماكن قريبة'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: typeLabels.keys.map((type) {
                final isSelected = selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(typeLabels[type]!),
                      selected: isSelected,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) {
                        setState(() => selectedType = type);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: isLoading ? null : searchNearby,
                icon: const Icon(Icons.search, color: Colors.white),
                label: Text(
                  isLoading ? 'جاري البحث...' : 'ابحث عن أقرب مكان',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(color: Colors.teal),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(typeIcons[place.type], color: Colors.teal),
                      title: Text(place.name),
                      subtitle: Text(
                        'خط العرض: ${place.lat.toStringAsFixed(4)}, خط الطول: ${place.lon.toStringAsFixed(4)}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------ شاشة الترجمة الفورية (جمل جاهزة أوفلاين) ------

class PhraseEntry {
  final String arabic;
  final Map<String, String> translations;

  PhraseEntry({required this.arabic, required this.translations});
}

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String selectedLanguage = 'en';

  final Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'it': 'Italiano',
    'es': 'Español',
  };

  final List<PhraseEntry> phrases = [
    PhraseEntry(arabic: 'السلام عليكم', translations: {
      'en': 'Hello',
      'fr': 'Bonjour',
      'it': 'Ciao',
      'es': 'Hola',
    }),
    PhraseEntry(arabic: 'شكراً', translations: {
      'en': 'Thank you',
      'fr': 'Merci',
      'it': 'Grazie',
      'es': 'Gracias',
    }),
    PhraseEntry(arabic: 'من فضلك', translations: {
      'en': 'Please',
      'fr': 'S\'il vous plaît',
      'it': 'Per favore',
      'es': 'Por favor',
    }),
    PhraseEntry(arabic: 'فين الحمام؟', translations: {
      'en': 'Where is the bathroom?',
      'fr': 'Où sont les toilettes?',
      'it': 'Dov\'è il bagno?',
      'es': '¿Dónde está el baño?',
    }),
    PhraseEntry(arabic: 'محتاج طبيب', translations: {
      'en': 'I need a doctor',
      'fr': 'J\'ai besoin d\'un médecin',
      'it': 'Ho bisogno di un medico',
      'es': 'Necesito un médico',
    }),
    PhraseEntry(arabic: 'بكام ده؟', translations: {
      'en': 'How much is this?',
      'fr': 'Combien ça coûte?',
      'it': 'Quanto costa?',
      'es': '¿Cuánto cuesta esto?',
    }),
    PhraseEntry(arabic: 'أنا تايه', translations: {
      'en': 'I am lost',
      'fr': 'Je suis perdu',
      'it': 'Mi sono perso',
      'es': 'Estoy perdido',
    }),
    PhraseEntry(arabic: 'ممكن مساعدة؟', translations: {
      'en': 'Can you help me?',
      'fr': 'Pouvez-vous m\'aider?',
      'it': 'Puoi aiutarmi?',
      'es': '¿Puedes ayudarme?',
    }),
    PhraseEntry(arabic: 'فين أقرب فندق؟', translations: {
      'en': 'Where is the nearest hotel?',
      'fr': 'Où est l\'hôtel le plus proche?',
      'it': 'Dov\'è l\'hotel più vicino?',
      'es': '¿Dónde está el hotel más cercano?',
    }),
    PhraseEntry(arabic: 'اتصل بالبوليس', translations: {
      'en': 'Call the police',
      'fr': 'Appelez la police',
      'it': 'Chiama la polizia',
      'es': 'Llama a la policía',
    }),
    PhraseEntry(arabic: 'أنا مصري', translations: {
      'en': 'I am Egyptian',
      'fr': 'Je suis égyptien',
      'it': 'Sono egiziano',
      'es': 'Soy egipcio',
    }),
    PhraseEntry(arabic: 'مش فاهم', translations: {
      'en': 'I don\'t understand',
      'fr': 'Je ne comprends pas',
      'it': 'Non capisco',
      'es': 'No entiendo',
    }),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة فورية'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('اللغة:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: languageNames.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedLanguage = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phrase.arabic,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          phrase.translations[selectedLanguage] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------ باقي الشاشات (لسه فاضية، هنملاها لاحقاً) ------

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
