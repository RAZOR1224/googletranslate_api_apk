import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Translate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TranslatePage(),
    );
  }
}

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isLoading = false;
  String _selectedSourceLang = 'auto';
  String _selectedTargetLang = 'en';
  final Dio _dio = Dio();

  final List<Map<String, String>> _languages = [
    {'code': 'auto', 'name': 'Auto Detect'},
    {'code': 'en', 'name': 'English'},
    {'code': 'id', 'name': 'Indonesian'},
    {'code': 'vi', 'name': 'Vietnamese'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
  ];

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _translatedText = '';
    });

    try {
      // Print request details for debugging
      print(
          'Request URL: https://google-translate113.p.rapidapi.com/api/v1/translator/text');
      print('Request body: ${jsonEncode({
            "from": _selectedSourceLang,
            "to": _selectedTargetLang,
            "text": _textController.text
          })}');

      final response = await _dio.post(
        'https://google-translate113.p.rapidapi.com/api/v1/translator/text',
        options: Options(
          headers: {
            'X-RapidAPI-Key':
                '57e561d97fmsh05a936c334ce14ep14b8dajsn9d03a56c9145',
            'X-RapidAPI-Host': 'google-translate113.p.rapidapi.com',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) =>
              true, // Accept all status codes for debugging
        ),
        data: jsonEncode({
          "from": _selectedSourceLang,
          "to": _selectedTargetLang,
          "text": _textController.text
        }),
      );

      // Print response for debugging
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          _translatedText =
              response.data['trans'] ?? 'No translation available';
        });
      } else {
        setState(() {
          _translatedText =
              'Error: ${response.statusCode} - ${response.statusMessage}\n${response.data.toString()}';
        });
      }
    } catch (e) {
      print('Error details: $e');
      setState(() {
        _translatedText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Translate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Source Language Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSourceLang,
                    isExpanded: true,
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSourceLang = value!;
                      });
                    },
                  ),
                ),
                // Swap Button
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _selectedSourceLang == 'auto'
                      ? null
                      : () {
                          setState(() {
                            final temp = _selectedSourceLang;
                            _selectedSourceLang = _selectedTargetLang;
                            _selectedTargetLang = temp;
                            if (_translatedText.isNotEmpty) {
                              _textController.text = _translatedText;
                              _translatedText = '';
                            }
                          });
                        },
                ),
                // Target Language Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedTargetLang,
                    isExpanded: true,
                    items: _languages
                        .where((lang) => lang['code'] != 'auto')
                        .map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTargetLang = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Input Text Field
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter text to translate',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _translatedText = '';
                    });
                  },
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            // Translate Button
            ElevatedButton(
              onPressed: _isLoading ? null : _translateText,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Translate'),
            ),
            const SizedBox(height: 20),
            // Translated Text
            if (_translatedText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(_translatedText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
