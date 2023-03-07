import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jkuat_navigation/models/account.dart';
import 'package:jkuat_navigation/pages/base_map.dart';
import 'package:jkuat_navigation/pages/places.dart';
import 'package:jkuat_navigation/utilities/appconfig.dart';
import 'package:jkuat_navigation/widgets/mainDrawer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/authController.dart';
import '../indoor/indoor_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Account user;
  bool userFetched = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  // ignore: unnecessary_const
  static const CameraPosition kenya = const CameraPosition(
    target: LatLng(1.286389, 36.817223),
    zoom: 19,
  );

  late Position currentPosition;
  var geoLocator = Geolocator();
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  bool newNotification = false;
  //   location pin
  @override
  void initState() {
    fetchCurrentUser();
    super.initState();
  }

  fetchCurrentUser() async {
    user = await AuthController.getUserAccount(AppConfig.auth.currentUser!.uid);
    setState(() {
      userFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: userFetched ? mainDrawer(context, user) : const Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.green),
        title: GestureDetector(
          onTap: () {},
          child: const Text(
            "JKUAT NAVIGATION",
            style: TextStyle(color: Colors.black),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 1.5,
              color: Colors.green),
        ),
      ),
      body: Stack(
        children: [
          BaseMap(),
          GoogleMap(
            mapType: MapType.satellite,
            myLocationButtonEnabled: true,
            initialCameraPosition: kenya,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controler) {
              controllerGoogleMap.complete(controler);
              newGoogleMapController = controler;
              setState(() {});
              locatePosition();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_outdoor),
            label: 'Outdoor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_indoor),
            label: 'Indoor',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlacesPage(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IndoorHomePage(),
              ),
            );
          }
        },
      ),
    );
  }

  void locatePosition() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    if (kDebugMode) {
      print(statuses[Permission.location]);
    }
    if (statuses[Permission.location]!.isDenied) {
      requestPermission(Permission.location);
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;

      setState(() {
        markersSet.add(
          Marker(
              markerId: const MarkerId("user"),
              position: LatLng(position.latitude, position.longitude),
              anchor: const Offset(0.5, 0.5),
              draggable: false,
              flat: true,
              infoWindow: const InfoWindow(
                  title: "Home Address", snippet: "Current Location"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen)),
        );
      });

      LatLng latLngPosition = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 19);
      newGoogleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  Future<void> requestPermission(Permission permission) async {
    await permission.request();
  }
}
