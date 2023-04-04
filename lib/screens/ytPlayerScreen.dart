import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ytPlayerScreen extends StatefulWidget {
  final String videoID;
  const ytPlayerScreen({Key? key, required this.videoID}) : super(key: key);

  @override
  State<ytPlayerScreen> createState() => _ytPlayerScreenState();
}

class _ytPlayerScreenState extends State<ytPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _muted = false;
  @override
  void initState() {
    // TODO: implement initState
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoID,
      flags: YoutubePlayerFlags(
        controlsVisibleAtStart: true,
        autoPlay: true,
      ),
    );
    _controller.toggleFullScreenMode();
    super.initState();
  }
  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: (){
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      onExitFullScreen: (){
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: ProgressBarColors(
            handleColor: Colors.red,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.white70,
            playedColor: Colors.red,
          ),
          topActions: [
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: (){
                // SystemChrome.setPreferredOrientations([
                //   DeviceOrientation.portraitUp,
                // ]);
                Navigator.of(context).pop();
              },
            ),
          ],
          bottomActions: [
            CurrentPosition(),
            ProgressBar(
              isExpanded: true,
              colors: ProgressBarColors(
                playedColor: Colors.red,
                bufferedColor: Colors.white70,
                handleColor: Colors.red,
                backgroundColor: Colors.grey,
              ),
            ),
            RemainingDuration(
            ),
            IconButton(
              icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 30,),
              onPressed: () {
                _muted
                    ? _controller.unMute()
                    : _controller.mute();
                setState(() {
                  _muted = !_muted;
                });
              }
            ),
          ],
        ),
        builder: (context, player){
          return Scaffold(
            // appBar: AppBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                player,
              ],
            ),
          );
        }
      );
  }
}
