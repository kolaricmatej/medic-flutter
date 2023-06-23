import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import './glookose_reading.dart';
import './screens/glookose_form.dart';
import './helpers/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediFlutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'MediFlutter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your Fun Medication Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediFlutter'),
      ),
      body: FutureBuilder<List<GlucoseReading>>(
        future: dbHelper.getGlucoseReadings(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final glucoseReadings = snapshot.data!;
            List<GlucoseReading> lastThreeReadings = glucoseReadings.length >= 3
                ? glucoseReadings.sublist(glucoseReadings.length - 3)
                : glucoseReadings;

            return Column(
              children: [
                SizedBox(height: 16),
                Text(
                  'Last ${lastThreeReadings.length} Glucose Readings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...lastThreeReadings.map((reading) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Glucose Value: ${reading.value}'),
                      subtitle: Text(
                          'Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(reading.dateTime)}'),
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                Expanded(
                  child: GlucoseLineChart(glucoseReadings: glucoseReadings),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return GlucoseForm();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class GlucoseLineChart extends StatelessWidget {
  final List<GlucoseReading> glucoseReadings;

  GlucoseLineChart({required this.glucoseReadings});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<GlucoseReading, DateTime>> series = [
      charts.Series(
        id: "Glucose",
        data: glucoseReadings,
        domainFn: (GlucoseReading reading, _) => reading.dateTime,
        measureFn: (GlucoseReading reading, _) => reading.value,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16),
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: 5,
          ),
        ),
        domainAxis: charts.DateTimeAxisSpec(
          tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
            day: charts.TimeFormatterSpec(
              format: 'dd.MM',
              transitionFormat: 'dd.MM',
            ),
          ),
          tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
        ),
      ),
    );
  }
}
