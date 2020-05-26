import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  bool isload = false;
  List<Placemark> placemark;
  Placemark place;
  Color light;

  Position _currentPosition;
  String _currentAddress;

  void _wipeValues() {
    setState(() {
      if (_currentAddress != null) _currentAddress = '';
      if (_currentPosition != null) _currentPosition = null;
    });
  }

  void _getLocation() {
    //CircularProgressIndicator State
    setState(() {
      isload = true;
    });

    Future<dynamic>.delayed(const Duration(seconds: 2), () async {
      await geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          isload = false;
          _currentPosition = position;
        });
      }).catchError((e) {
        print('error' + e);
      });

      try {
        placemark = await geolocator.placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude);
        place = placemark[0];
        setState(() {
          _currentAddress = place.country.toString();
        });
      } catch (e) {
        print('error' + e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    light = Theme.of(context).primaryColorLight;
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor.withAlpha(100),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Geolocation Test',
        ),
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                CustomRow(
                  title: 'Longitude',
                  subtitle:
                      '${_currentPosition != null ? _currentPosition.longitude : ''}',
                ),
                CustomRow(
                  title: 'Latitude',
                  subtitle:
                      '${_currentPosition != null ? _currentPosition.latitude : ''}',
                ),
                CustomRow(
                  title: 'País',
                  subtitle:
                      '${_currentPosition != null ? _currentAddress : ''}',
                ),
                if (isload == true)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white70,
                    ),
                  )
                else if (_currentPosition != null)
                  FlatButton(
                    color: light,
                    child: Text('Reset values'),
                    onPressed: _wipeValues,
                  )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.5,
        backgroundColor: light,
        onPressed: _getLocation,
        child: Icon(
          Icons.search,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }
}

class CustomRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomRow({Key key, @required this.title, @required this.subtitle})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
