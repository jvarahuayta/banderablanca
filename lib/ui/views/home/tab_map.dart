import 'dart:async';

import 'package:banderablanca/core/core.dart';
import 'package:banderablanca/ui/helpers/show_confirm_dialog.dart';
import 'package:banderablanca/ui/shared/shared.dart';
import 'package:banderablanca/ui/views/widgets/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'camera_screen.dart';
import 'comments_list.dart';

class TabMap extends StatefulWidget {
  const TabMap({Key key, this.destination}) : super(key: key);
  final Destination destination;

  @override
  _TabMapState createState() => _TabMapState();
}

class _TabMapState extends State<TabMap> {
  Completer<GoogleMapController> _controller = Completer();
  Position _currentPosition;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-12.0962816, -77.0219015),
    zoom: 14.4746,
  );

  @override
  initState() {
    super.initState();
    _getLocation();
    print("hola=========================================");
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      );
    });

    GoogleMapController mapController = await _controller.future;

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      zoom: 17.0,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
              Selector<FlagModel, Set<Marker>>(
                selector: (_, FlagModel model) => model.markers(
                  onTap: (WhiteFlag selectedFlag) {
                    _showModalBottom(selectedFlag);
                  },
                ),
                builder: (_, Set<Marker> markers, Widget child) {
                  return GoogleMap(
                    mapType: MapType.normal,
                    markers: markers,
                    mapToolbarEnabled: false,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      controller.setMapStyle(Utils.mapStyles);
                      _controller.complete(controller);
                    },
                  );
                },
              ),
              Positioned(
                right: 0,
                top: 50,
                child: IconButton(
                    icon: Icon(Icons.gps_fixed), onPressed: _goToTheLake),
              ),
              // Positioned(
              //   bottom: 80,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //     height: 170,
              //     child: Selector<FlagModel, List<WhiteFlag>>(
              //       selector: (_, model) => model.flags,
              //       builder: (BuildContext context, List<WhiteFlag> flags,
              //           Widget child) {
              //         return PageView.builder(
              //           controller: ctrl,
              //           itemCount: flags.length,
              //           itemBuilder: (context, int currentIdx) {
              //             bool active = currentIdx == currentPage;
              //             return CardItem(
              //               onTap: () {
              //                 Navigator.of(context).pushNamed(
              //                     "${RoutePaths.FlagDetail}/${flags[currentIdx].id}");
              //               },
              //               flag: flags[currentIdx],
              //               active: active,
              //             );
              //           },
              //         );
              //       },
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 7,
        onPressed: () => _loadCameraScreen(context),
        label: Text(
          'Alzar una bandera',
          style: TextStyle(fontFamily: "Avenir Black", fontSize: 16),
        ),
        icon: Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            FontAwesomeIcons.fontAwesomeFlag,
            size: 20,
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigation(),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          // bearing: 192.8334901395799,
          target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
          // tilt: 59.440717697143555,
          zoom: 19.151926040649414,
        ),
      ),
    );
  }

  _showConfirmDialog(WhiteFlag flag) async {
    bool isConfirm = await showConfirmDialog(context,
        title: "Reportar bandera falsa",
        content:
            "Reporta si la bandera blanca es falsa, si obtiene muchos reportes será elimnado del mapa.",
        confirmText: "REPORTAR");
    if (isConfirm)
      Provider.of<FlagModel>(context, listen: false).reportFlag(flag);
  }

  _showModalBottom(WhiteFlag flag) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: FractionallySizedBox(
                heightFactor: 0.8,
                child: Container(
                  // color: Colors.grey[900],
                  // height: 250,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          "${flag.address}",
                          style: TextStyle(fontFamily: "Tajawal Bold"),
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.chevronDown,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ),
                      CommentsList(flag: flag),
                      InkWell(
                        onTap: () => _showConfirmDialog(flag),
                        child: Container(
                          width: double.infinity,
                          height: 30,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.report,
                                color: Colors.red,
                                size: 12,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Reportar bandera",
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SendMessageTextField(
                        flag: flag,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Future _loadCameraScreen(BuildContext context) async {
    // _onImageButtonPressed(ImageSource.gallery);
    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      debugPrint('Error: ${e.code}\nError Message: ${e.description}');
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          cameras: cameras,
        ),
      ),
    );
  }
}
