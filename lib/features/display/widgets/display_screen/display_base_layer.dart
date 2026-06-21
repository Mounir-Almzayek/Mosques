import 'package:flutter/material.dart';

import '../../../../core/enums/display/display_layer_kind.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../bloc/display_bloc.dart';
import '../../controller/display_layer_controller.dart';
import '../background/background_widgets.dart';
import '../content/content_widgets.dart';
import '../header/header_widgets.dart';
import '../ticker/ticker_widgets.dart';

class DisplayBaseLayer extends StatelessWidget {
  const DisplayBaseLayer({
    super.key,
    required this.mosque,
    required this.state,
    required this.layerController,
  });

  final MosqueBootstrap mosque;
  final DisplayLoaded state;
  final DisplayLayerController layerController;

  @override
  Widget build(BuildContext context) {
    final design = mosque.displaySettings;
    final media = MediaQuery.sizeOf(context);
    final padH = (media.width * 0.028).clamp(14.0, 64.0);
    final padV = (media.height * 0.022).clamp(8.0, 36.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DisplayBackgroundImage(
            fallbackColor: design.primaryColorValue,
            settings: design,
            albumUrls: design.albumImageUrls,
          ),
        ),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: padH,
                          vertical: padV,
                        ),
                        child: TopHeaderWidget(
                          mosque: mosque,
                          designSettings: design,
                        ),
                      ),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: layerController,
                          builder: (context, _) => DisplayBeigeArea(
                            mosque: mosque,
                            designSettings: design,
                            showReligiousContent:
                                layerController.state.activeLayer ==
                                DisplayLayerKind.religious,
                            slideIndex: layerController.religiousSlideIndex,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                minimum: EdgeInsets.zero,
                child: DisplayTickerBar(
                  mosque: mosque,
                  platformAnnouncements: state.platformAnnouncements,
                  appSettings: state.appSettings,
                  currentVersion: state.currentVersion,
                  primaryColor: design.secondaryColorValue,
                  fontSize: design.announcementsFontSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
