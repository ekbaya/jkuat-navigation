import 'package:flutter/material.dart';
import 'package:jkuat_navigation/utilities/appconfig.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';

class SPA extends StatefulWidget {
  const SPA({Key? key}) : super(key: key);

  @override
  State<SPA> createState() => _SPAState();
}

class _SPAState extends State<SPA> {
  late SitumFlutterSDK situmSdk;

  int _selectedIndex = 0;
  String currentOutput = "---";

  Widget _createHomeTab() {
    // Home:
    return Card(
      child: Column(
        children: [
          const Text(
            'SPA',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    _requestUpdates();
                  },
                  child: const Text('Start')),
              TextButton(
                  onPressed: () {
                    _removeUpdates();
                  },
                  child: const Text('Stop')),
              TextButton(
                  onPressed: () {
                    _echo("SDK> RESPONSE: CLEAR CACHE...");
                    _clearCache();
                  },
                  child: const Text('Clear cache')),
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    _echo("SDK> POIS...");
                    _fetchPois();
                  },
                  child: const Text('Pois')),
              TextButton(
                  onPressed: () {
                    _echo("SDK> CATEGORIES...");
                    _fetchCategories();
                  },
                  child: const Text('Categories')),
              TextButton(
                  onPressed: () {
                    _echo("SDK> PREFETCH...");
                    _prefetch();
                  },
                  child: const Text('Prefetch')),
            ],
          ),
          Text(currentOutput)
        ],
      ),
    );
  }

  Widget _createSitumMapTab() {
    // The Situm map:
    return SitumMapView(
      key: const Key("situm_map"),
      // Your Situm credentials and building, see config.dart.
      // Copy config.dart.example if you haven't already.
      searchViewPlaceholder: "Search SPA",
      situmUser: situmUser,
      situmApiKey: situmApiKey,
      buildingIdentifier: buildingIdentifierSPA,
      googleMapsApiKey: googleMapsApiKey,
      useHybridComponents: true,
      showPoiNames: true,
      hasSearchView: true,
      lockCameraToBuilding: true,
      useRemoteConfig: true,
      initialZoom: 16,
      showNavigationIndications: true,
      showFloorSelector: true,
      navigationSettings: const NavigationSettings(
        outsideRouteThreshold: 40,
        distanceToGoalThreshold: 8,
      ),
      loadCallback: _onSitumMapLoaded,
    );
  }

  void _onSitumMapLoaded(SitumFlutterWayfinding controller) {
    // The Situm map was successfully loaded, use the given controller to
    // call the WYF API methods.
    print("WYF> Situm Map loaded!");
    controller.onPoiSelected((poiSelectedResult) {
      print("WYF> Poi ${poiSelectedResult.poiName} selected!");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      print("WYF> Poi deselected!");
    });
    controller.onNavigationStarted((navigation) {
      print("WYF> Nav started, distance = ${navigation.route?.distance}");
    });
    //controller.startPositioning();
    //controller.selectPoi(MY_POI_ID, buildingIdentifier);
  }

  @override
  void initState() {
    // SitumSdk for flutter:
    situmSdk = SitumFlutterSDK();
    situmSdk.init(situmUser, situmApiKey);
    situmSdk.setConfiguration(ConfigurationOptions(
      useRemoteConfig: true,
    ));
    situmSdk.onEnterGeofences((geofencesResult) {
      _echo("SDK> Enter geofences: ${geofencesResult.geofences}.");
    });
    situmSdk.onExitGeofences((geofencesResult) {
      _echo("SDK> Exit geofences: ${geofencesResult.geofences}.");
    });

    situmSdk.removeUpdates();
    super.initState();
  }

  void _echo(String output) {
    setState(() {
      currentOutput = output;
      print(currentOutput);
    });
  }

  void _requestUpdates() async {
    situmSdk.requestLocationUpdates(_MyLocationListener(), {});
  }

  void _removeUpdates() async {
    situmSdk.removeUpdates();
  }

  void _clearCache() async {
    await situmSdk.clearCache();
    _echo("SDK> RESPONSE: CLEAR CACHE = DONE");
  }

  void _prefetch() async {
    var prefetch = await situmSdk.prefetchPositioningInfo(
      [buildingIdentifierSPA],
      options: PrefetchOptions(
        preloadImages: true,
      ),
    );
    _echo("SDK> RESPONSE: PREFETCH = $prefetch");
  }

  void _fetchPois() async {
    var pois = await situmSdk.fetchPoisFromBuilding(buildingIdentifierSPA);
    _echo("SDK> RESPONSE: POIS = $pois");
  }

  void _fetchCategories() async {
    var categories = await situmSdk.fetchPoiCategories();
    _echo("SDK> RESPONSE: CATEGORIES = $categories");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPA'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _createHomeTab(),
          _createSitumMapTab(),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'SPA',
          ),

        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.green,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _MyLocationListener implements LocationListener {
  @override
  void onError(Error error) {
    print("SDK> ERROR: ${error.message}");
  }

  @override
  void onLocationChanged(OnLocationChangedResult locationChangedResult) {
    print(
        "SDK> Location changed, building ID is: ${locationChangedResult.buildingId}");
  }

  @override
  void onStatusChanged(String status) {
    print("SDK> STATUS: $status");
  }
}
