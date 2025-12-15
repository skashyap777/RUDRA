import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/screens/home/provider/home_provider.dart';
import 'package:provider/provider.dart';

// class PotholeScanner extends StatefulWidget {
//   const PotholeScanner({super.key});

//   @override
//   State<PotholeScanner> createState() => _PotholeScannerState();
// }

// class _PotholeScannerState extends State<PotholeScanner> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Column(children: [

//         ],
//       ));
//   }
// }

class AddPothole extends StatefulWidget {
  const AddPothole({super.key});

  @override
  State<AddPothole> createState() => _AddPotholeState();
}

class _AddPotholeState extends State<AddPothole> {
  GoogleMapController? _mapController;
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _remarkController = TextEditingController();
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  Set<Marker> _markers = {};
  String? severity;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showLocationError('Location services are disabled.');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showLocationError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _markers = {
          Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(
              title: 'Pothole Location',
              snippet: 'Detected pothole at this location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            16.0,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      _showLocationError('Failed to get location: $e');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppPallet.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Report Pothole',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              provider.potholeImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (provider.potholeImages.length > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...provider.potholeImages.map((image) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      index = provider.potholeImages.indexOf(
                                        image,
                                      );
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: _buildThumbnail(image),
                                  ),
                                );
                              }),
                            ],
                          ),
                        SizedBox(height: 30),

                        // _buildInfoSection(
                        //   'Location',
                        //   _currentPosition != null
                        //       ? '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        //       : 'Getting location...',
                        // ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                _isLoadingLocation
                                    ? Center(child: CircularProgressIndicator())
                                    : _currentPosition != null
                                    ? GoogleMap(
                                      onMapCreated: (
                                        GoogleMapController controller,
                                      ) {
                                        _mapController = controller;
                                      },
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          _currentPosition!.latitude,
                                          _currentPosition!.longitude,
                                        ),
                                        zoom: 16.0,
                                      ),
                                      markers: _markers,
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      mapToolbarEnabled: false,
                                    )
                                    : Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              color: Colors.grey[600],
                                              size: 32,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Location not available',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: _getCurrentLocation,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(
                                                  0xFF4CAF50,
                                                ),
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Severity*",
                            border: OutlineInputBorder(),
                          ),
                          value: severity,
                          items:
                              ["High", "Medium", "Low"]
                                  .map(
                                    (level) => DropdownMenuItem(
                                      value: level,
                                      child: Text(level),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              severity = val;
                            });
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? "Please select severity"
                                      : null,
                        ),

                        _buildInfoSection(
                          'Area of the Pothole*',
                          _areaController,
                          hintText: 'Enter Area',
                        ),
                        _buildInfoSection(
                          'Landmark*',
                          _landmarkController,
                          hintText: 'E.g., Near DNHC Hospital, Six Mile',
                        ),
                        _buildInfoSection(
                          'Remark if any (Optional)',
                          _remarkController,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        submitReport();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFC107),
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(File image) {
    return Container(
      width: 60,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 35,
              height: 25,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String label,
    TextEditingController controller, {
    String? hintText,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText ?? "Enter $label",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void submitReport() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    List<MultipartFile> potholeImages = [];
    for (var i = 0; i < provider.potholeImages.length; i++) {
      potholeImages.add(
        await MultipartFile.fromFile(
          provider.potholeImages[i].path,
          filename: "pothole_$i.png",
          contentType: DioMediaType("image", "png"),
        ),
      );
    }

    String coordinatesJson = provider.coordinates.toString();
    FormData formData = FormData.fromMap({
      "potholeImages": potholeImages,
      "coordinates": coordinatesJson,
      "severity": severity,
      "area_details": _areaController.text,
      "landmark": _landmarkController.text,
      "remarks": _remarkController.text,
    });

    provider.createPothole(formData);
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Submitted'),
          content: Text('Your pothole report has been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
