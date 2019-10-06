import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_app/models/song.model.dart';
import 'package:music_app/utils/custom_icons.util.dart';
import 'package:music_app/utils/custom_scroll_behavior.util.dart';
import 'package:music_app/utils/format_duration.util.dart';

class MusicApp extends StatefulWidget {
  static String title = 'Music App';
  static ThemeData themeData = ThemeData(
    primaryColor: Colors.white,
    fontFamily: 'Metropolis',
    sliderTheme: SliderThemeData(
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
    ),
  );

  @override
  _MusicAppState createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> with TickerProviderStateMixin {
  int _selected = 0;
  double _radius = 50;
  bool _showPlaylist = false;
  bool _shuffle = false;
  bool _repeat = false;
  Curve _swipeCurve = Curves.fastOutSlowIn;
  Duration _swipeDuration = Duration(milliseconds: 300);

  Timer _timer;
  TickerProvider _provider;
  DragStartDetails _dragStart;
  DragUpdateDetails _dragUpdate;
  AnimationController _controller;

  List<Song> _songs = <Song>[
    Song(
      name: 'Faded',
      author: 'Alan Walker',
      duration: Duration(seconds: 213),
      cover: 'assets/images/cover-1.jpg',
    ),
    Song(
      name: 'Sing me to Sleep',
      author: 'Alan Walker',
      duration: Duration(seconds: 192),
      cover: 'assets/images/cover-2.jpg',
    ),
    Song(
      name: 'All Falls Down',
      author: 'Alan Walker',
      duration: Duration(seconds: 221),
      cover: 'assets/images/cover-1.jpg',
    ),
    Song(
      name: 'Darkside',
      author: 'Alan Walker',
      duration: Duration(seconds: 240),
      cover: 'assets/images/cover-2.jpg',
    ),
    Song(
      name: 'On My Way',
      author: 'Alan Walker',
      duration: Duration(seconds: 217),
      cover: 'assets/images/cover-1.jpg',
    ),
    Song(
      name: 'Force',
      author: 'Alan Walker',
      duration: Duration(seconds: 240),
      cover: 'assets/images/cover-2.jpg',
    ),
    Song(
      name: 'Diamond Heart',
      author: 'Alan Walker',
      duration: Duration(seconds: 203),
      cover: 'assets/images/cover-1.jpg',
    ),
    Song(
      name: 'Alone',
      author: 'Alan Walker',
      duration: Duration(seconds: 164),
      cover: 'assets/images/cover-2.jpg',
    ),
    Song(
      name: 'The Spectre',
      author: 'Alan Walker',
      duration: Duration(seconds: 207),
      cover: 'assets/images/cover-1.jpg',
    )
  ];

  double get _screenHeight {
    return MediaQuery.of(context).size.height;
  }

  double get _screenWidth {
    return MediaQuery.of(context).size.width;
  }

  _startTimer() {
    if (_timer != null && _timer.isActive) {
      return;
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  _stopTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
  }

  _play() {
    print('play');
    setState(() {
      _radius = 50;
      _startTimer();
      _controller.forward();
    });
  }

  _pause() {
    print('pause');
    setState(() {
      _radius = 70;
      _stopTimer();
      _controller.stop();
    });
  }

  _next() {
    print('next');
    setState(() {
      if (_shuffle) {
        _selected = Random().nextInt(_songs.length);
      } else {
        _selected += 1;
      }
      _changeController();
      _play();
    });
  }

  _prev() {
    print('prev');
    setState(() {
      if (_shuffle) {
        _selected = Random().nextInt(_songs.length);
      } else {
        _selected -= 1;
      }

      _changeController();
      _play();
    });
  }

  _toggleShuffle() {
    print('toggle shuffle');
    setState(() {
      _shuffle = !_shuffle;
    });
  }

  _toggleRepeat() {
    print('toggle repeat');
    setState(() {
      _repeat = !_repeat;
    });
  }

  _select(int index) {
    if (index != _selected) {
      setState(() {
        _selected = index;
        _changeController();
        _play();
      });
    }
  }

  _slide(val) {
    print('slide');
    bool isAnimating = _controller.isAnimating;
    setState(() {
      _controller.value = val / _songs[_selected].duration.inSeconds;
      isAnimating ? _play() : _pause();
    });
  }

  _listenController() {
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (_repeat) {
          _changeController();
          _play();
        } else if (_selected < _songs.length - 1 || _shuffle) {
          _next();
        } else {
          _changeController();
          _pause();
        }
      }
    });
  }

  _changeController() {
    _controller.dispose();

    setState(() {
      _controller = AnimationController(
          duration: _songs[_selected].duration, vsync: _provider);
      _listenController();
    });
  }

  _setPlaylistStatus(bool show) {
    setState(() {
      _showPlaylist = show;
    });
  }

  Widget _buildController() {
    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(CustomIcons.media_shuffle),
                onPressed: _toggleShuffle,
                color: _shuffle ? Colors.black : Colors.grey,
              ),
              Container(
                width: _screenWidth * 0.4,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // previous
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: _selected == 0 && !_shuffle ? null : _prev,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: _selected == (_songs.length - 1) && !_shuffle
                          ? null
                          : _next,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(CustomIcons.media_loop),
                onPressed: _toggleRepeat,
                color: _repeat ? Colors.black : Colors.grey,
              ),
            ],
          ),
          AnimatedContainer(
            curve: Curves.fastOutSlowIn,
            duration: Duration(milliseconds: 200),
            height: _radius,
            width: _radius,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              elevation: 20,
              highlightElevation: 10,
              onPressed: () {
                _controller.isAnimating ? _pause() : _play();
              },
              child: _controller.isAnimating
                  ? Icon(Icons.pause, size: 20)
                  : Icon(Icons.play_arrow, size: 36),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        elevation: 0,
        leading: Icon(CustomIcons.chevron_left, size: 28),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 30),
            child: Icon(CustomIcons.short_text, size: 9),
          )
        ],
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget _buildMusicCover() {
    return GestureDetector(
      onVerticalDragStart: (dragDetails) {
        setState(() {
          _dragStart = dragDetails;
        });
      },
      onVerticalDragUpdate: (dragDetails) {
        setState(() {
          _dragUpdate = dragDetails;
        });
      },
      onVerticalDragEnd: (endDetails) {
        double dy =
            _dragUpdate.globalPosition.dy - _dragStart.globalPosition.dy;

        dy < 0 ? _setPlaylistStatus(true) : _setPlaylistStatus(false);
      },
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
              duration: _swipeDuration,
              curve: _swipeCurve,
              height: _showPlaylist ? _screenHeight * 0.4 : _screenHeight * 0.7,
              width: _screenWidth * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_screenWidth),
                  bottomRight: Radius.circular(_screenWidth),
                ),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(_songs[_selected].cover),
                ),
              )),
          AnimatedContainer(
            duration: _swipeDuration,
            curve: _swipeCurve,
            height: _showPlaylist ? _screenHeight * 0.4 : _screenHeight * 0.7,
            width: _screenWidth * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_screenWidth),
                bottomRight: Radius.circular(_screenWidth),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  _songs[_selected].name,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _songs[_selected].author.toUpperCase(),
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.white, fontSize: 12, letterSpacing: 1),
                ),
                SizedBox(height: 60)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaylist() {
    return AnimatedContainer(
      height: _showPlaylist ? _screenHeight * 0.3 : 0,
      duration: _swipeDuration,
      curve: _swipeCurve,
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          itemExtent: 50,
          itemBuilder: (context, index) {
            return ListTile(
              title: index == _selected
                  ? Row(
                      children: <Widget>[
                        Icon(CustomIcons.pulse, size: 20),
                        SizedBox(width: 5),
                        Text(
                          _songs[index].name,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Text(
                          _songs[index].name,
                          softWrap: true,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
              trailing: index == _selected
                  ? Text(
                      formatDuration(_songs[index].duration),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      formatDuration(_songs[index].duration),
                      style: TextStyle(),
                    ),
              onTap: () => _select(index),
            );
          },
          itemCount: _songs.length,
        ),
      ),
    );
  }

  Widget _buildMusicSlider() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 40,
          child: Text(
            formatDuration(
                Duration(
                    seconds: (_controller.value *
                            _songs[_selected].duration.inSeconds)
                        .toInt()),
                true),
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(
            value: _controller.value * _songs[_selected].duration.inSeconds,
            min: 0,
            max: _songs[_selected].duration.inSeconds.toDouble(),
            activeColor: Colors.black,
            onChanged: _slide,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            formatDuration(_songs[_selected].duration, true),
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _provider = this;
    _controller = AnimationController(
        duration: _songs[_selected].duration, vsync: _provider);
    _listenController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: _swipeDuration,
            curve: _swipeCurve,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[200], Colors.grey[100]],
              ),
            ),
            padding: _showPlaylist
                ? EdgeInsets.fromLTRB(20, 0, 20, 20)
                : EdgeInsets.fromLTRB(20, 0, 20, 60),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildMusicCover(),
                _buildPlaylist(),
                Column(
                  children: <Widget>[
                    _buildMusicSlider(),
                    _buildController(),
                  ],
                ),
              ],
            ),
          ),
          _buildAppBar(),
        ],
      ),
    );
  }
}

// cont() {
//   AnimatedSwitcher(
//   child: _controller.isAnimating ? _pauseButton() : _playButton(),
//   duration: Duration(milliseconds: 300),
//   transitionBuilder: (Widget child, Animation<double> animation) {
//     return ScaleTransition(
//       child: child,
//       scale: animation,
//     );
//   },
// )
//         Widget _playButton() {
//   return SizedBox(
//     key: UniqueKey(),
//     height: 70,
//     width: 70,
//     child: FloatingActionButton(
//       onPressed: _handlePlayPause,
//       backgroundColor: Colors.black,
//       elevation: 20,
//       highlightElevation: 10,
//       child: Icon(Icons.play_arrow),
//     ),
//   );
// }

// Widget _pauseButton() {
//   return SizedBox(
//     key: UniqueKey(),
//     height: 50,
//     width: 50,
//     child: FloatingActionButton(
//       onPressed: _handlePlayPause,
//       backgroundColor: Colors.black,
//       elevation: 20,
//       highlightElevation: 10,
//       child: Icon(Icons.pause),
//     ),
//   );
// }
// }

// _controller.addListener(() {
//   int currentStep =
//       (_controller.value * _songs[_selected].duration.inSeconds).toInt();

//   if (_stepper == currentStep) {
//     return;
//   }
//   _stepper = currentStep;
//   setState(() {});
// });
