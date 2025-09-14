import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:utils/utils.dart';

Future<LocationWithMediumAddressModel?> showLocationActionSheet({
  required BuildContext context,
  required String googleApi
}) async
{

  String? selectedPlace;
  String? selectedPinCode;
  LatLng? selectedLatLng;
  bool isLoading = false;
  String gpsLog = "Trying to fetch location from GPS";
  bool isAutoCalled = false;

  LocationWithMediumAddressModel? result = await showModalBottomSheet<LocationWithMediumAddressModel>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> getCurrentLocation(StateSetter setState) async {
            try {
              setState(() => isLoading = true);

              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                Fluttertoast.showToast(msg: 'Location services are disabled.');
                setState(() => isLoading = false);
                return;
              }

              LocationPermission permission =
              await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  Fluttertoast.showToast(
                    msg: 'Location permissions are denied',
                  );
                  setState(() => isLoading = false);
                  return;
                }
              }

              if (permission == LocationPermission.deniedForever) {
                Fluttertoast.showToast(
                  msg: 'Location permissions are permanently denied',
                );
                setState(() => isLoading = false);
                return;
              }

              Position position = await Geolocator.getCurrentPosition();
              List<Placemark> placemarks = await placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              );

              Placemark place = placemarks.first;

              selectedLatLng = LatLng(position.latitude, position.longitude);
              selectedPlace =
                  place.locality ?? place.name ?? 'Unknown Location';
              selectedPinCode = place.postalCode ?? '';

              Fluttertoast.showToast(msg: 'Location: $selectedPlace');
              setState(() => isLoading = false);
            } catch (e) {
              setState(() => isLoading = false);
              Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
            }
          }

          if (!isAutoCalled) {
            isAutoCalled = true;
            Future.delayed(
              Duration.zero,
                  () => getCurrentLocation(setModalState),
            );
          }

          Future<void> openMapPicker(StateSetter setModalState) async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapPickerPage()),
            );

            if (result != null && result is Map<String, dynamic>) {
              selectedLatLng = result['latLng'];
              selectedPlace = result['city'];
              selectedPinCode = result['pincode'];
              setModalState(() {});
            }
          }

          Future<void> openSearchPage(StateSetter setModalState) async {
            LatLng? searchResult = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) =>  PlaceSearchPage1(googleApi: googleApi,)),
            );
            if (searchResult != null) {
              try {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  searchResult.latitude,
                  searchResult.longitude,
                );
                Placemark place = placemarks.first;
                selectedLatLng = searchResult;
                selectedPlace = place.locality ?? place.name ?? 'Search Result';
                selectedPinCode = place.postalCode ?? '';
                setModalState(() {});
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Error getting location: ${e.toString()}',
                );
              }
            }
          }

          return SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedLatLng != null)
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GoogleMap(
                          mapToolbarEnabled: false,
                          zoomGesturesEnabled: false,
                          scrollGesturesEnabled: false,
                          compassEnabled: false,
                          myLocationButtonEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: selectedLatLng!,
                            zoom: 16,
                          ),
                          zoomControlsEnabled: false,
                          markers: {
                            Marker(
                              markerId: MarkerId("selected-location"),
                              position: selectedLatLng!,
                            ),
                          },
                        ),
                      ),
                    ),
                  if (selectedPlace != null)
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.black,
                      ),
                      trailing: InkWell(
                        onTap: () => getCurrentLocation(setModalState),
                        child: Icon(Icons.refresh),
                      ),
                      title: Text(
                        selectedPlace!,
                        style: const TextStyle(color: Colors.black, height: 0),
                      ),
                      subtitle: Text(
                        "Lat: ${selectedLatLng?.latitude}, Lng: ${selectedLatLng?.longitude}\nPin Code: $selectedPinCode",
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 0,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blueGrey.shade50,
                      ),
                      child: Row(
                        children: [
                          if (isLoading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.3,
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Text(gpsLog),
                            ),
                          ),
                          InkWell(
                            onTap: () => getCurrentLocation(setModalState),
                            child: Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                  const Text("Other Option's"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => openMapPicker(setModalState),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.blueGrey.shade50,
                              ),
                              child: Icon(Icons.map),
                            ),
                            Text(
                              " Pick from Map",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      InkWell(
                        onTap: () => openSearchPage(setModalState),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.blueGrey.shade50,
                              ),
                              child: Icon(Icons.search),
                            ),
                            Text(
                              "Search Place",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (selectedLatLng != null)
                        InkWell(
                          onTap: () async {
                            if (selectedLatLng != null) {
                              try {
                                // Get complete placemark details
                                List<Placemark> placemarks = await placemarkFromCoordinates(
                                  selectedLatLng!.latitude,
                                  selectedLatLng!.longitude,
                                );
                                Placemark place = placemarks.first;

                                Navigator.pop(
                                  context,
                                  LocationWithMediumAddressModel(
                                    coordinates: selectedLatLng!,
                                    city: place.locality ?? '',
                                    area: place.subLocality ?? '',
                                    country: place.country,
                                    district: place.subAdministrativeArea ?? '',
                                    state: place.administrativeArea ?? '',
                                    pinCode: place.postalCode ?? '',
                                  ),
                                );
                              } catch (e) {
                                Fluttertoast.showToast(
                                  msg: 'Error getting full address: ${e.toString()}',
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            margin: EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.blueGrey.shade50,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.done),
                                Text(" Done", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  return result;
}

class PlaceSearchPage1 extends StatefulWidget {
  String googleApi;
   PlaceSearchPage1({required this.googleApi});


  @override
  State<PlaceSearchPage1> createState() => _PlaceSearchPage1State();
}

class _PlaceSearchPage1State extends State<PlaceSearchPage1> {
  List<dynamic> suggestions = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) return;

    final String request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.googleApi}';

    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          suggestions = data['predictions'];
        });
      } else {
        print('Failed to load suggestions');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<LatLng?> fetchPlaceCoordinates(String placeId) async {
    final String request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${widget.googleApi}';

    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        print('Failed to load place details');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Place")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search Places',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => fetchPlaceSuggestions(_controller.text),
                ),
              ),
              onChanged: (value) => fetchPlaceSuggestions(value),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return ListTile(
                    title: Text(item['description']),
                    onTap: () async {
                      final LatLng? coords =
                      await fetchPlaceCoordinates(item['place_id']);
                      if (coords != null && context.mounted) {
                        Navigator.pop(context, coords);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selectedLatLng;
  Set<Marker> markers = {};
  GoogleMapController? mapController;

  void _onMapTap(LatLng pos) {
    setState(() {
      selectedLatLng = pos;
      markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: pos,
        ),
      };
    });
  }

  void _removeSelection() {
    setState(() {
      selectedLatLng = null;
      markers.clear();
    });
  }

  Future<void> _onDonePressed() async {
    if (selectedLatLng == null) {
      Navigator.pop(context, null);
      return;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(
      selectedLatLng!.latitude,
      selectedLatLng!.longitude,
    );

    Placemark place = placemarks.first;
    String city = place.locality ?? place.subAdministrativeArea ?? 'Unknown';
    String pincode = place.postalCode ?? '';

    Navigator.pop(context, {
      'latLng': selectedLatLng,
      'city': city,
      'pincode': pincode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location from Map")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(17.385044, 78.486671),
          zoom: 12,
        ),
        onMapCreated: (controller) => mapController = controller,
        onTap: _onMapTap,
        markers: markers,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.done),
            label: const Text("Done"),
            onPressed: _onDonePressed,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text("Remove Selection"),
            onPressed: _removeSelection,
          ),
        ],
      ),
    );
  }
}