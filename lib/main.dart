import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:weather_me/services/weather_services.dart';
import 'package:weather_me/widget/weather_data.dart'; // Import the WeatherData widget

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<StatefulWidget> createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final _searchController = TextEditingController();

  String bgImg = 'assets/images/clear.jpg';
  String iconImg = 'assets/icons/Clear.png';
  String cityName = '';
  String temperature = '';
  String tempMax = '';
  String tempMin = '';
  String sunRise = '';
  String sunSet = '';
  String humidity = '';
  String windSpeed = '';
  String pressure = '';
  String visibility = '';
  String main = '';

  Future<void> getData(String searchedCity) async {
    final weatherServices = WeatherServices();
    var weatherData;

    if (searchedCity.isEmpty) {
      // Get the current location if no city is searched
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Pass latitude and longitude to fetchWeather
      weatherData = await weatherServices.fetchWeather(
          position.latitude, position.longitude);
    } else {
      // Get weather by searched city name
      weatherData = await weatherServices.getWeather(searchedCity);
    }

    setState(() {
      cityName = weatherData['name']; // Update city name
      temperature = weatherData['main']['temp'].toStringAsFixed(1);
      tempMax = weatherData['main']['temp_max'].toStringAsFixed(1);
      tempMin = weatherData['main']['temp_min'].toStringAsFixed(1);
      sunRise = DateFormat('hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunrise'] * 1000));
      sunSet = DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
          weatherData['sys']['sunset'] * 1000));
      pressure = weatherData['main']['pressure'].toString();
      humidity = weatherData['main']['humidity'].toString();
      visibility = weatherData['visibility'].toString();
      windSpeed = weatherData['wind']['speed'].toString();
      main = weatherData['weather'][0]['main'];

      // Update background and icon based on weather condition
      switch (main) {
        case 'Clear':
          bgImg = 'assets/images/clear.jpg';
          iconImg = 'assets/icons/Clear.png';
          break;
        case 'Clouds':
          bgImg = 'assets/images/clouds.jpg';
          iconImg = 'assets/icons/Clouds.png';
          break;
        case 'Rain':
          bgImg = 'assets/images/rain.jpg';
          iconImg = 'assets/icons/Rain.png';
          break;
        case 'Fog':
          bgImg = 'assets/images/fog.jpg';
          iconImg = 'assets/icons/Foggy.png';
          break;
        case 'Thunderstorm':
          bgImg = 'assets/images/thunderstorm.jpg';
          iconImg = 'assets/icons/Thunderstorm.png';
          break;
        default:
          bgImg = 'assets/images/haze.jpg';
          iconImg = 'assets/icons/Haze.png';
      }
    });
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    // If permission is granted, fetch the weather data for the current location
    getData("");
    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Check location permission on app startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            bgImg, // Use the dynamic bgImg variable
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 70, left: 20, right: 20), // Adjusted padding
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      getData(value);
                    },
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      fillColor: Colors.black26,
                      hintText: 'Enter the location to search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        getData(
                            value); // Fetch weather data for the entered city
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      Text(
                        cityName, // Display updated city name
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "$temperature°C",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        main,
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        iconImg,
                        height: 80,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward),
                      Text(
                        "$tempMax°C",
                        style: const TextStyle(
                            fontSize: 22, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.arrow_downward),
                      Text(
                        "$tempMin°C",
                        style: const TextStyle(
                            fontSize: 22, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Card(
                    elevation: 5,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          WeatherData(
                            index1: "Sunrise",
                            index2: "Sunset",
                            value1: sunRise,
                            value2: sunSet,
                          ),
                          const SizedBox(height: 15),
                          WeatherData(
                            index1: "Humidity",
                            index2: "Visibility",
                            value1: humidity,
                            value2: visibility,
                          ),
                          const SizedBox(height: 15),
                          WeatherData(
                            index1: "Pressure",
                            index2: "Wind Speed",
                            value1: pressure,
                            value2: windSpeed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
