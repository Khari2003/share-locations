// ignore_for_file: file_names, library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/domain/usecases/getCurrentLocation.dart';
import 'package:my_app/domain/usecases/store/getStores.dart';
import 'package:my_app/domain/usecases/getRoute.dart';
import 'package:my_app/presentation/screens/auth/authViewModel.dart';
import 'package:my_app/presentation/screens/map/mapViewModel.dart';
import 'package:my_app/presentation/widgets/mapWidgets/mapBottomWidget.dart';
import 'package:my_app/presentation/widgets/mapWidgets/mapButtonsWidget.dart';
import 'package:my_app/presentation/widgets/mapWidgets/mapStoreDetailWidget.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:my_app/presentation/widgets/mapWidgets/flutterMapWidget.dart';
import 'package:my_app/presentation/widgets/filterWidget.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool areButtonsVisible = true;
  Timer? _hideButtonsTimer;

  @override
  void initState() {
    super.initState();
    _startHideButtonsTimer();
  }

  @override
  void dispose() {
    _hideButtonsTimer?.cancel();
    super.dispose();
  }

  void _startHideButtonsTimer() {
    _hideButtonsTimer?.cancel();
    _hideButtonsTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          areButtonsVisible = false;
        });
      }
    });
  }

  void _toggleButtons() {
    setState(() {
      areButtonsVisible = !areButtonsVisible;
    });
    if (areButtonsVisible) {
      _startHideButtonsTimer();
    }
  }

  void _onButtonPressed() {
    _startHideButtonsTimer();
  }

  void _showFilterSheet(MapViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => FilterWidget(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (!authViewModel.isGuest && authViewModel.auth == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/welcome');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: appTheme(),
      child: ChangeNotifierProvider(
        create: (context) => MapViewModel(
          getCurrentLocation: Provider.of<GetCurrentLocation>(context, listen: false),
          getStores: Provider.of<GetStores>(context, listen: false),
          getRoute: Provider.of<GetRoute>(context, listen: false),
        )..fetchInitialData(),
        child: Consumer<MapViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              body: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    viewModel.selectStore(null);
                    _onButtonPressed();
                  },
                  child: viewModel.currentLocation == null
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Stack(
                          children: [
                            FlutterMapWidget(
                              mapController: viewModel.mapController,
                              currentLocation: viewModel.currentLocation!,
                              radius: viewModel.radius,
                              isNavigating: viewModel.isNavigating,
                              userHeading: viewModel.userHeading,
                              navigatingStore: viewModel.navigatingStore,
                              filteredStores: viewModel.filteredStores,
                              routeCoordinates: viewModel.routeCoordinates,
                              routeType: viewModel.routeType,
                              onStoreTap: (store) {
                                viewModel.selectStore(store);
                                _onButtonPressed();
                              },
                              searchedLocation: viewModel.searchedLocation,
                              regionLocation: viewModel.regionLocation,
                              regionRadius: viewModel.showRegionRadiusSlider ? viewModel.radius : null,
                            ),
                            MapButtonsWidget(
                              areButtonsVisible: areButtonsVisible,
                              authViewModel: authViewModel,
                              viewModel: viewModel,
                              onButtonPressed: _onButtonPressed,
                              onToggleButtons: _toggleButtons,
                              onShowFilterSheet: () => _showFilterSheet(viewModel),
                            ),
                            MapBottomWidget(
                              viewModel: viewModel,
                              onButtonPressed: _onButtonPressed,
                            ),
                            if (viewModel.selectedStore != null)
                              MapStoreDetailWidget(
                                viewModel: viewModel,
                                onButtonPressed: _onButtonPressed,
                              ),
                            // Positioned(
                            //   right: 0,
                            //   top: MediaQuery.of(context).size.height / 2 - 50,
                            //   child: Visibility(
                            //     visible: areButtonsVisible,
                            //     child: GestureDetector(
                            //       onTap: () {
                            //         Navigator.pushNamed(context, '/profile');
                            //         _onButtonPressed();
                            //       },
                            //       child: Container(
                            //         width: 50,
                            //         height: 100,
                            //         decoration: BoxDecoration(
                            //           color: appTheme().primaryColor,
                            //           borderRadius: const BorderRadius.only(
                            //             topLeft: Radius.circular(50),
                            //             bottomLeft: Radius.circular(50),
                            //           ),
                            //           boxShadow: const [
                            //             BoxShadow(color: Colors.black26, blurRadius: 4),
                            //           ],
                            //         ),
                            //         child: const Icon(
                            //           Icons.person,
                            //           color: Colors.white,
                            //           size: 30,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}