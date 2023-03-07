// ignore: file_names
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jkuat_navigation/models/DirectionDetail.dart';
import 'package:jkuat_navigation/utilities/appconfig.dart';

import 'GoogleMapsRepository.dart';
import 'package:alan_voice/alan_voice.dart';

//djkistra algorithm implementation to get shortest path to destination
class Graph {
  final Map<String, Map<String, double>> _graph;

  Graph(this._graph);

  List<String> shortestPath(String start, String finish) {
    final distances = <String, double>{};
    final previous = <String, String>{};
    final nodes = <String>[];

    _graph.forEach((node, _) {
      if (node == start) {
        distances[node] = 0;
      } else {
        distances[node] = double.infinity;
      }
      nodes.add(node);
    });

    while (nodes.isNotEmpty) {
      nodes.sort((a, b) => distances[a]!.compareTo(distances[b]!));
      final smallest = nodes.removeAt(0);

      if (smallest == finish) {
        final path = <String>[];
        var current = finish;
        while (current != start) {
          path.insert(0, current);
          current = previous[current]!;
        }
        path.insert(0, start);
        return path;
      }

      if (distances[smallest] == double.infinity) {
        break;
      }

      _graph[smallest]!.forEach((neighbor, weight) {
        final alt = distances[smallest]! + weight;
        if (alt < distances[neighbor]!) {
          distances[neighbor] = alt;
          previous[neighbor] = smallest;
        }
      });
    }

    return <String>[];
  }
}

class MainAppAPI {
  static Future<String> searchCoordinatesAddress(
      Position position, context) async {
    String placeAddress = "";
    String lat = position.latitude.toString();
    String lng = position.longitude.toString();
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapKey";

    var response = await GoogleMapsRepository.getRequest(url);

    if (response != "failed") {
      placeAddress = response["results"][0]["formatted_address"];
    }

    return placeAddress;
  }

  static Future<DirectionDetail> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng destinationPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var resp = await GoogleMapsRepository.getRequest(directionUrl);
    if (resp == "failed") {
      return DirectionDetail(
        distanceValue: 0,
        durationValue: 0,
        distanceText: "",
        durationText: "",
        encodedPoints: "",
      );
    }

    DirectionDetail directionDetail = DirectionDetail(
      distanceValue: resp["routes"][0]["legs"][0]["distance"]["value"],
      durationValue: resp["routes"][0]["legs"][0]["duration"]["value"],
      distanceText: resp["routes"][0]["legs"][0]["distance"]["text"],
      durationText: resp["routes"][0]["legs"][0]["duration"]["text"],
      encodedPoints: resp["routes"][0]["overview_polyline"]["points"],
    );
    AlanVoice.playText('Distance remaining to destination is ${directionDetail.distanceText}Arriving  in Destination in${directionDetail.durationText}');


    if (directionDetail.distanceValue < 0.1) {
      AlanVoice.playText('You have reached your destination');
    }
    return directionDetail;
  }
}
