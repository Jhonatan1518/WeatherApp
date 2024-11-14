import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  double? _temperature;

  Future<void> _getWeather() async {
    // Validar si hay conexión
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _temperature = 17.0; // Valor por defecto
      });
      return;
    }

    // Obtener latitud y longitud ingresadas
    double latitude = double.parse(_latitudeController.text);
    double longitude = double.parse(_longitudeController.text);

    final apiUrl = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
    
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = data['current_weather']['temperature'];
        });
      } else {
        setState(() {
          _temperature = 17.0; // Valorporddefecto en caso dealgun error
        });
      }
    } catch (e) {
      setState(() {
        _temperature = 17.0; // Valor por defecto en caso de excepción
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la latitud';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la longitud';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _getWeather();
                  }
                },
                child: Text('Obtener Temperatura'),
              ),
              SizedBox(height: 20),
              Text(
                _temperature != null
                    ? 'Temperatura actual: $_temperature°C'
                    : 'Ingrese coordenadas para obtener la temperatura',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 40),
              Text(
                'Desarrolladores: Jhonatan Zapata y Jhon Pico',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
