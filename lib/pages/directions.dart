import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jkuat_navigation/helpers/MainAppAPI.dart';
import 'package:jkuat_navigation/models/DirectionDetail.dart';
import 'package:jkuat_navigation/pages/base_map.dart';
import 'package:jkuat_navigation/utilities/appconfig.dart';
import 'package:jkuat_navigation/utilities/utility.dart';
import 'package:jkuat_navigation/widgets/ProgressDialog.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/AppStyle.dart';
import 'package:alan_voice/alan_voice.dart';

class DirectionsPage extends StatefulWidget {
  const DirectionsPage(
      {super.key, required this.name, required this.lat, required this.long});
  final String name;
  final String lat;
  final String long;

  @override
  State<DirectionsPage> createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage> {
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

  List<LatLng> pLinesCoordinates = [];
  Set<Polyline> polyLineSet = {};

  late BitmapDescriptor userPin;

  _DirectionsPageState() {
    /// Init Alan Button with project key from Alan Studio
    AlanVoice.addButton(alanKey, buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);

    /// Handle commands from Alan Studio
    AlanVoice.onCommand.add((command) {
      debugPrint("got new command ${command.toString()}");
    });
  }

  DirectionDetail distanceDurationDetail = DirectionDetail(
    distanceValue: 0,
    durationValue: 0,
    distanceText: "",
    durationText: "",
    encodedPoints: "",
  );

  @override
  void initState() {
    setCustomMapPin();
    Geolocator.getPositionStream().listen(userCurrentLocationUpdate);
    super.initState();
  }

  setCustomMapPin() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/user-navigation.png', 300);

    userPin = BitmapDescriptor.fromBytes(markerIcon);
  }

  userCurrentLocationUpdate(Position updatedPosition) async {
    LatLng destinationLatLong =
        LatLng(double.parse(widget.lat), double.parse(widget.long));

    currentPosition = updatedPosition;

    LatLng origin = LatLng(currentPosition.latitude, currentPosition.longitude);

    distanceDurationDetail = await MainAppAPI.obtainPlaceDirectionDetails(
        origin, destinationLatLong);

    // setState(() {});
    addLocationMarker(origin, distanceDurationDetail.distanceText,
        distanceDurationDetail.distanceText);
  }

  addLocationMarker(LatLng position, String duration, String distance) {
    markersSet.removeWhere(
        (element) => element.markerId == const MarkerId("currentLocation"));
    markersSet.add(
      Marker(
          markerId: const MarkerId("currentLocation"),
          position: position,
          rotation: currentPosition.heading,
          flat: true,
          draggable: false,
          zIndex: 2,
          anchor: const Offset(0.5, 0.5),
          infoWindow:
              InfoWindow(title: "$distance to destination", snippet: duration),
          icon: userPin),
    );

    //add Circle
    circlesSet.removeWhere(
      (element) => element.circleId == const CircleId("currentLocation"),
    );
    Circle currentLocationCircle = Circle(
      circleId: const CircleId("currentLocation"),
      fillColor: Colors.blue.withAlpha(70),
      center: position,
      radius: 36,
      strokeWidth: 1,
      zIndex: 1,
      strokeColor: Colors.blueAccent,
    );

    circlesSet.add(currentLocationCircle);

    CameraPosition cameraPosition = CameraPosition(
        target: position, zoom: 18, tilt: 0, bearing: currentPosition.heading);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Direction to ${widget.name} Stage",
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          BaseMap(),
          GoogleMap(
            mapType: MapType.satellite,
            myLocationButtonEnabled: true,
            initialCameraPosition: kenya,
            myLocationEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            markers: markersSet,
            circles: circlesSet,
            polylines: polyLineSet,
            onMapCreated: (GoogleMapController controler) {
              controllerGoogleMap.complete(controler);
              newGoogleMapController = controler;
              locatePosition();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: const [
            Expanded(
                child: Text(
              "Displaying fastest route to destination",
              style: TextStyle(color: Colors.white, fontSize: 18),
            )),
          ],
        ),
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
              markerId: const MarkerId("currentLocation"),
              position: LatLng(position.latitude, position.longitude),
              anchor: const Offset(0.5, 0.5),
              draggable: false,
              flat: true,
              infoWindow: const InfoWindow(
                  title: "Home Address", snippet: "Current Location"),
              icon: userPin),
        );
      });

      LatLng latLngPosition = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 19);
      newGoogleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      getPlaceDirection();
    }
  }

  void getPlaceDirection() async {
    var originLatLng =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    var destinationLatLng =
        LatLng(double.parse(widget.lat), double.parse(widget.long));

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..."));

    var details = await MainAppAPI.obtainPlaceDirectionDetails(
        originLatLng, destinationLatLng);
    setState(() {
      distanceDurationDetail = details;
    });
    // ignore: use_build_context_synchronously
    Navigator.of(
      context,
    ).pop();
    pLinesCoordinates.clear();
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResults =
        polylinePoints.decodePolyline(details.encodedPoints);
    if (decodedPolylinePointsResults.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResults) {
        pLinesCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: AppStyle.primaryColor,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLinesCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast:
              LatLng(originLatLng.latitude, destinationLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocationMarker = Marker(
      markerId: const MarkerId("originId"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: originLatLng,
      infoWindow: const InfoWindow(
        title: "Current Position",
        snippet: "You",
      ),
    );

    Marker dropOffLocationMarker = Marker(
      markerId: const MarkerId("destinationId"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: destinationLatLng,
      infoWindow: InfoWindow(
        title: widget.name,
        snippet: "Delivery Address",
      ),
    );

    setState(() {
      markersSet.add(pickUpLocationMarker);
      markersSet.add(dropOffLocationMarker);
    });

    Circle currentLocationCircle = Circle(
      circleId: const CircleId("currentLocation"),
      fillColor: Colors.blueAccent,
      center: originLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
    );

    Circle dropOffCircle = Circle(
      circleId: const CircleId("destinationId"),
      fillColor: Colors.deepPurple,
      center: destinationLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
    );

    setState(() {
      circlesSet.add(currentLocationCircle);
      circlesSet.add(dropOffCircle);
    });

   // AlanVoice.playText('Distance remaining to destination is ${distanceDurationDetail.distanceText}Arriving  in Destination in${distanceDurationDetail.durationText}');
  }

  Future<void> requestPermission(Permission permission) async {
    await permission.request();
  }
}
