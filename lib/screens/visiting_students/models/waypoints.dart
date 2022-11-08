import 'package:flutter/services.dart';
import '../../../crcrme_enhanced_containers/lib/item_serializable.dart';

import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:geocoding/geocoding.dart';

enum Priority {
  low,
  mid,
  high,
}

class Waypoint extends ItemSerializable {
  Waypoint(this.title, this.latitude, this.longitude,
      {required this.address,
      this.isActivated = true,
      this.priority = Priority.low});

  static Future<Waypoint> fromCoordinates(title, latitude, longitude,
      {isActivated, priority}) async {
    late Placemark placemark;
    try {
      placemark = (await placemarkFromCoordinates(latitude, longitude)).first;
    } catch (e) {
      placemark = Placemark();
    }

    return Waypoint(title, latitude, longitude,
        address: placemark, isActivated: isActivated, priority: priority);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'title': title,
      'isActivate': isActivated,
      'latitude': latitude,
      'longitude': longitude,
      'street': address.street,
      'locality': address.locality,
      'postalCode': address.postalCode,
      'priority': priority,
    };
  }

  static Waypoint deserialize(Map<String, dynamic> data) {
    final address = Placemark(
        street: data['street'],
        locality: data['locality'],
        postalCode: data['postalCode']);
    return Waypoint(data['title'], data['latitude'], data['longitude'],
        address: address, priority: data['priority'] as Priority);
  }

  static Waypoint copy(Waypoint other) {
    return Waypoint(other.title, other.latitude, other.longitude,
        address: other.address,
        isActivated: other.isActivated,
        priority: other.priority);
  }

  Waypoint copyWith(
      {title, latitude, longitude, address, isActivated, priority}) {
    title = title ?? this.title;
    isActivated = isActivated ?? this.isActivated;
    latitude = latitude ?? this.latitude;
    longitude = longitude ?? this.longitude;
    address = address ?? this.address;
    priority = priority ?? this.priority;
    return Waypoint(title, latitude, longitude,
        address: address, isActivated: isActivated, priority: priority);
  }

  static Future<Waypoint> fromAddress(title, String address,
      {isActivated = true, priority}) async {
    late List<Location> locations;
    try {
      locations = await locationFromAddress(address);
    } on PlatformException {
      return Waypoint('', 0.0, 0.0, address: Placemark());
    }

    var first = locations.first;
    return Waypoint.fromCoordinates(title, first.latitude, first.longitude,
        isActivated: isActivated, priority: priority);
  }

  static Future<Waypoint> fromLatLng(title, LatLng point,
      {isActivated = true, priority}) async {
    return Waypoint.fromCoordinates(title, point.latitude, point.longitude,
        isActivated: isActivated, priority: priority);
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  static Future<Waypoint> fromLngLat(title, LngLat point,
      {isActivated = true, priority}) {
    return Waypoint.fromCoordinates(title, point.lat, point.lng,
        isActivated: isActivated, priority: priority);
  }

  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  final String title;
  final bool isActivated;
  final double latitude;
  final double longitude;
  final Placemark address;
  final Priority priority;

  @override
  String toString() =>
      '${address.street}\n${address.locality} ${address.postalCode}';
}
