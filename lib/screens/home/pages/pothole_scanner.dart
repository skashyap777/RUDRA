import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/screens/home/provider/home_provider.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart';
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
  int index = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      if (provider.coordinates.isNotEmpty) {
        final lastCoord = provider.coordinates.last;
        final lat = lastCoord['latitude'] as double;
        final lng = lastCoord['longitude'] as double;
        setState(() {
          _currentPosition = Position(
            longitude: lng,
            latitude: lat,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            floor: null,
            isMocked: false,
          );
          _isLoadingLocation = false;
          _markers = {
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(lat, lng),
              infoWindow: const InfoWindow(
                title: 'Pothole Location',
                snippet: 'Detected pothole at this location',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          };
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16.0),
          );
        }

        // --- NEW: Perform reverse geocoding to pre-fill the Area field ---
        try {
          // Use geocoding to get the placemark based on the coordinates
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            
            // Generate a readable address from the placemark components
            List<String> addressParts = [];
            
            // Build something like: "Beltola Tiniali, Bhagaduttapur, Guwahati, Assam 781028, India"
            if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
            if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
            if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
            
            // Fallbacks if some properties are null
            if (addressParts.isEmpty && place.subAdministrativeArea != null) addressParts.add(place.subAdministrativeArea!);
            
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
              String statePart = place.administrativeArea!;
              if (place.postalCode != null && place.postalCode!.isNotEmpty) {
                statePart += ' ${place.postalCode}';
              }
              addressParts.add(statePart);
            }
            if (place.country != null && place.country!.isNotEmpty) addressParts.add(place.country!);

            String fullAddress = addressParts.join(', ');
            
            // Update the area controller which drives the text field
            if (fullAddress.isNotEmpty && mounted) {
              setState(() {
                _areaController.text = fullAddress;
              });
            }
          }
        } catch (e) {
          debugPrint("Failed to fetch address via geocoding: $e");
          // If geocoding fails, it will safely ignore and leave the text field empty (or user can write manually)
        }
        // -----------------------------------------------------------------

      } else {
        // Fallback or retry: attempt gathering using provider
        await provider.addCurrentCordinate();
        if (provider.coordinates.isNotEmpty) {
           _getCurrentLocation();
        } else {
          setState(() {
            _isLoadingLocation = false;
          });
          _showLocationError('Location not available. Please retry.');
        }
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
                        if (provider.potholeImages.isNotEmpty)
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
                                provider.potholeImages[index < provider.potholeImages.length ? index : 0],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                        if (provider.potholeImages.length > 1)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
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
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.location_off,
                                                color: Colors.grey[600],
                                                size: 28,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Location not available',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              ElevatedButton(
                                                onPressed: _getCurrentLocation,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF4CAF50,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  minimumSize: Size(0, 32),
                                                ),
                                                child: const Text(
                                                  'Retry',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 20),

                        _buildInfoSection(
                          'Area of the Pothole*',
                          _areaController,
                          hintText: 'Auto-filled from GPS location',
                          readOnly: true,
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
                      onPressed:
                          _isSubmitting
                              ? null
                              : () {
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
                      child:
                          _isSubmitting
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black87,
                                  ),
                                ),
                              )
                              : Text(
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
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (readOnly) ...
                [
                  const SizedBox(width: 6),
                  Icon(Icons.lock_outline, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(
                    'Auto-filled',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic),
                  ),
                ],
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText ?? "Enter $label",
              filled: readOnly,
              fillColor: readOnly ? Colors.grey[100] : null,
              suffixIcon: readOnly
                  ? Icon(Icons.gps_fixed, size: 16, color: Colors.grey[400])
                  : null,
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
                borderSide: BorderSide(
                  color: readOnly ? Colors.grey[200]! : Colors.grey[300]!,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: readOnly ? Colors.grey[600] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSubmitting = false;

  void submitReport() async {
    if (_isSubmitting) return; // Prevent duplicate submissions

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<HomeProvider>(context, listen: false);

      // --- Client-side 5-meter radius check ---
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      double? lat;
      double? lng;
      
      if (provider.coordinates.isNotEmpty) {
        lat = provider.coordinates.last['latitude'] as double?;
        lng = provider.coordinates.last['longitude'] as double?;
      } else if (_currentPosition != null) {
        lat = _currentPosition!.latitude;
        lng = _currentPosition!.longitude;
      }

      if (lat != null && lng != null) {
        bool isDuplicate = false;
        for (var report in reportProvider.reports) {
          if (report.status?.toLowerCase() == 'rejected') continue; // Don't block if the previous one was rejected
          
          if (report.images != null) {
            for (var image in report.images!) {
              if (image.latitude != null && image.longitude != null) {
                double distance = Geolocator.distanceBetween(
                  lat,
                  lng,
                  image.latitude!,
                  image.longitude!,
                );
                if (distance <= 5.0) {
                  isDuplicate = true;
                  break;
                }
              }
            }
          }
          if (isDuplicate) break;
        }

        if (isDuplicate) {
          if (mounted) {
             setState(() {
               _isSubmitting = false;
             });
          }
          _showReportDialog(
            context,
            false,
            "A pothole has already been reported by you within 5 meters of this location.",
          );
          return; // Stop submission
        }
      }
      // ----------------------------------------

      List<MultipartFile> potholeImages = [];
      for (var i = 0; i < provider.potholeImages.length; i++) {
        // Compress image before uploading to reduce file size and upload time
        final compressedImage = await provider.compressImage(
          provider.potholeImages[i],
        );

        if (compressedImage != null) {
          potholeImages.add(
            await MultipartFile.fromFile(
              compressedImage.path,
              filename:
                  "pothole_$i.jpg", // Changed to .jpg since we're compressing to JPEG
              contentType: DioMediaType("image", "jpeg"),
            ),
          );
        } else {
          // Fallback to original image if compression fails
          potholeImages.add(
            await MultipartFile.fromFile(
              provider.potholeImages[i].path,
              filename: "pothole_$i.png",
              contentType: DioMediaType("image", "png"),
            ),
          );
        }
      }

      String coordinatesJson = jsonEncode(provider.coordinates);

      // Build form data — strip out accuracy from coordinates since it's a separate field
      final coordsForServer = [];
      for (var i = 0; i < provider.potholeImages.length; i++) {
        if (i < provider.coordinates.length) {
          coordsForServer.add({
            "latitude": provider.coordinates[i]["latitude"],
            "longitude": provider.coordinates[i]["longitude"],
          });
        } else if (provider.coordinates.isNotEmpty) {
          // Duplicate last coordinate for remaining images safely
          coordsForServer.add({
            "latitude": provider.coordinates.last["latitude"],
            "longitude": provider.coordinates.last["longitude"],
          });
        } else {
          // Fallback if no location data exists
          coordsForServer.add({
            "latitude": _currentPosition?.latitude ?? 0.0,
            "longitude": _currentPosition?.longitude ?? 0.0,
          });
        }
      }
      
      String coordinatesJsonClean = jsonEncode(coordsForServer);

      Map<String, dynamic> formMap = {
        "potholeImages": potholeImages,
        "coordinates": coordinatesJsonClean,
        "area_details": _areaController.text,
        "landmark": _landmarkController.text,
        "remarks": _remarkController.text,
        "severity": "Low",
      };

      // Include GPS accuracy if available
      if (provider.lastAccuracy != null) {
        formMap["accuracy"] = double.parse(provider.lastAccuracy!.toStringAsFixed(2));
      }

      FormData formData = FormData.fromMap(formMap);

      Map<String, dynamic> result = await provider.createPothole(formData);

      if (result['success']) {
        _showReportDialog(
          context,
          true,
          result['message'] ??
              "Your pothole report has been submitted successfully!",
        );
      } else {
        _showReportDialog(
          context,
          false,
          result['message'] ?? "Failed to submit report. Please try again.",
        );
      }
    } catch (e) {
      _showReportDialog(
        context,
        false,
        "An error occurred while submitting the report.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showReportDialog(BuildContext context, bool success, String message) {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(success ? '✅ Success' : '❌ Error'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Provider.of<HomeProvider>(context, listen: false).clearReportData();
                  context.go('/home');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
