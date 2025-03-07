import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:students_attendace_with_mlkit/ui/attend/camera_screen.dart';
import 'package:students_attendace_with_mlkit/ui/components/custom_snackbar.dart';
import 'package:students_attendace_with_mlkit/ui/home_screen.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;

  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState();
}

class _AttendScreenState extends State<AttendScreen> {
  XFile? image;
  String? strAdress, strDate, strTime, strDateTime, strStatus = 'Attend';
  bool isLoading = false;
  double dLat = 0.0, dLong = 0.0;
  int dateHours = 0, dateMinutes = 0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('atendance');

  @override
  void initState() {
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();

    if (image != null) {
      isLoading = true;
      getLocationPosition();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Attendance Menu",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.orangeAccent,
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Icon(Icons.face_retouching_natural_outlined,
                          color: Colors.white),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Please make a selfie photo!",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Text(
                    "Capture Photo",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraScreen()));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    width: size.width,
                    height: 150,
                    child: DottedBorder(
                      radius: const Radius.circular(10),
                      borderType: BorderType.RRect,
                      color: Colors.orangeAccent,
                      strokeWidth: 1,
                      dashPattern: const [5, 5],
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: image != null
                              ? Image.file(File(image!.path), fit: BoxFit.cover)
                              : const Icon(
                                  Icons.camera_enhance_outlined,
                                  color: Colors.orangeAccent,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    controller: controllerName,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      labelText: "Your Name",
                      hintText: "Please enter your name",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      labelStyle:
                          const TextStyle(fontSize: 14, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orangeAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    "Your Location",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Colors.orangeAccent))
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          height: 5 * 24,
                          child: TextField(
                            enabled: false,
                            maxLines: 5,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.orangeAccent),
                              ),
                              hintText: strAdress != null
                                  ? strAdress
                                  : strAdress = 'Your Location',
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(30),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.orangeAccent,
                          child: InkWell(
                            splashColor: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (image == null ||
                                  controllerName.text.isEmpty) {
                                customSnackbar(context, Icons.info_outline, 'Please complete the form!');
                              } else {
                                submitAbsen(strAdress!,
                                    controllerName.text.toString(), strStatus!);
                              }
                            },
                            child: const Center(
                              child: Text(
                                "Report Now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            )),
      ),
    );
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      customSnackbar(context, Icons.location_off,
          "Location services is disabled, please enable");
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        customSnackbar(
            context, Icons.location_off, "Location permission disabled");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      customSnackbar(context, Icons.location_off,
          "Location Permission denied forever, we can't request permission");
      return false;
    }
    return true;
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text("Checking the data..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void setDateTime() {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('hh:mm:ss');
    var dateHour = DateFormat('hh');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = '$strDate | $strTime';

      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });
  }

  void setStatusAbsen() {
    if (dateHours < 8 || (dateHours == 8 && dateMinutes <= 30)) {
      strStatus = 'Attend';
    } else if (dateHours > 8 && dateHours < 18 ||
        (dateHours == 8 && dateMinutes >= 30)) {
      strStatus = 'Late';
    } else {
      strStatus = 'Absent';
    }
  }

  Future<void> getLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      dLat = position.latitude;
      dLong = position.longitude;
    });
  }

  //get realtime location
  Future<void> getGeoLocationPosition() async {
    // ignore: deprecated_member_use
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    setState(() {
      isLoading = false;
      getAddressFromLongLat(position);
    });
  }

  //get address by lat long
  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    setState(() {
      dLat = double.parse('${position.latitude}');
      dLat = double.parse('${position.longitude}');
      strAdress =
      "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    });
  }

  Future<void> submitAbsen(String alamat, String nama, String status) async {
    showLoaderDialog(context);
    dataCollection.add({
      'address': alamat,
      'name': nama,
      'description': status,
      'datetime': strDateTime
    }).then((result) {
      setState(() {
        Navigator.of(context).pop();
        try {
          customSnackbar(context, Icons.check_circle_outline, "Yeay! Attendance Report Succeeded!");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } catch (e) {
          customSnackbar(context, Icons.info_outline, "Ups, $e");
        }
      });
    }).catchError((error) {
      customSnackbar(context, Icons.error_outline, "Error: $error");
      Navigator.of(context).pop();
    });
  }
}
