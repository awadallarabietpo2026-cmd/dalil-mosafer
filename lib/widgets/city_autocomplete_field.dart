import 'dart:async';
import 'package:flutter/material.dart';
import '../services/airport_service.dart';

class CityAutocompleteField extends StatefulWidget {
  final String label;
  final void Function(AirportSuggestion) onSelected;

  const CityAutocompleteField({
    super.key,
    required this.label,
    required this.onSelected,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  List<AirportSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      final results = await AirportService.search(value);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item.displayName, textAlign: TextAlign.right),
                  subtitle: Text(item.code, textAlign: TextAlign.right),
                  onTap: () {
                    _controller.text = item.displayName;
                    setState(() => _suggestions = []);
                    widget.onSelected(item);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
