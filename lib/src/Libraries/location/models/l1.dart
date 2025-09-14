import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationWithMediumAddressModel {
  final LatLng coordinates;
  final String city;
  final String area;
  final String? country;
  final String district;
  final String state;
  final String pinCode;

  LocationWithMediumAddressModel({
    required this.coordinates,
    required this.city,
    required this.area,
    this.country,
    required this.district,
    required this.state,
    required this.pinCode,
  });

  factory LocationWithMediumAddressModel.fromJson(Map<String, dynamic> json) {
    return LocationWithMediumAddressModel(
      coordinates: LatLng(
        (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
        (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
      ),
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      country: json['country'], // nullable
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pin_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'city': city,
      'area': area,
      'country': country,
      'district': district,
      'state': state,
      'pin_code': pinCode,
    };
  }
}

class LocationWithSmallAddressModel {
  final LatLng coordinates;
  final String city;
  final String area;
  final String state;
  final String pinCode;

  LocationWithSmallAddressModel({
    required this.coordinates,
    required this.city,
    required this.area,
    required this.state,
    required this.pinCode,
  });

  factory LocationWithSmallAddressModel.fromJson(Map<String, dynamic> json) {
    return LocationWithSmallAddressModel(
      coordinates: LatLng(
        (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
        (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
      ),
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pin_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'city': city,
      'area': area,
      'state': state,
      'pin_code': pinCode,
    };
  }
}

class LocationModel {
  final LatLng coordinates;
  final String pinCode;

  LocationModel({
    required this.coordinates,
    required this.pinCode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      coordinates: LatLng(
        (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
        (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
      ),
      pinCode: json['pin_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'pin_code': pinCode,
    };
  }
}


class LocationWithFullAddressModel {
  final LatLng coordinates; // latitude & longitude
  final String name;        // Person/Place name
  final String street1;     // House No / Flat / Apartment
  final String street2;     // Street / Locality
  final String landmark;    // Nearby landmark
  final String area;        // Area / Locality / Town
  final String city;        // City
  final String district;    // District
  final String state;       // State
  final String country;     // Country
  final String pinCode;     // Postal / Zip code
  final String phoneNumber; // Contact number
  final String email;       // Optional email
  final String addressType; // Home, Work, Other
  final String instructions; // Delivery instructions (optional)

  LocationWithFullAddressModel({
    required this.coordinates,
    required this.name,
    required this.street1,
    required this.street2,
    required this.landmark,
    required this.area,
    required this.city,
    required this.district,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.phoneNumber,
    required this.email,
    required this.addressType,
    required this.instructions,
  });

  factory LocationWithFullAddressModel.fromJson(Map<String, dynamic> json) =>
      LocationWithFullAddressModel(
        coordinates: LatLng(
          (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
          (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
        ),
        name: json['name'] ?? '',
        street1: json['street1'] ?? '',
        street2: json['street2'] ?? '',
        landmark: json['landmark'] ?? '',
        area: json['area'] ?? '',
        city: json['city'] ?? '',
        district: json['district'] ?? '',
        state: json['state'] ?? '',
        country: json['country'] ?? '',
        pinCode: json['pin_code'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        email: json['email'] ?? '',
        addressType: json['address_type'] ?? '',
        instructions: json['instructions'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'latitude': coordinates.latitude,
    'longitude': coordinates.longitude,
    'name': name,
    'street1': street1,
    'street2': street2,
    'landmark': landmark,
    'area': area,
    'city': city,
    'district': district,
    'state': state,
    'country': country,
    'pin_code': pinCode,
    'phone_number': phoneNumber,
    'email': email,
    'address_type': addressType,
    'instructions': instructions,
  };
}