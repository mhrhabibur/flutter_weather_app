import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String apiKey = '1f462dda351a1f36c3d8b29280ef0fdb';
  String city = 'berlin';
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  Future<void> fetchWeather(String cityName) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
        city = cityName;
        isLoading = false;
      });
    } else {
      setState(() {
        weatherData = null;
        isLoading = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("City not found")));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter city name',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final inputCity = _controller.text.trim();
                if (inputCity.isNotEmpty) {
                  fetchWeather(inputCity);
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              fetchWeather(value.trim());
            }
          },
        ),
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : weatherData != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${weatherData!['name']}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${weatherData!['main']['temp']}°C',
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${weatherData!['weather'][0]['description'][0].toUpperCase()}${weatherData!['weather'][0]['description'].substring(1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Feels Like: ${weatherData!['main']['feels_like']}',

                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                )
                : const Text('Failed to fetch weather'),
      ),
    );
  }
}
