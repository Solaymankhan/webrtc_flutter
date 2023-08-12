import 'package:flutter/material.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:videocall/models/meeting_details.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:videocall/pages/home_screen.dart';
import 'package:videocall/utils/user.utils.dart';
import 'package:videocall/widgets/control_panel.dart';
import 'package:videocall/widgets/remote_connection.dart';

class meeting_page extends StatefulWidget {
  meeting_page(
      {Key? key, this.meetingId, this.name, required this.meetingDetail})
      : super(key: key);

  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;

  @override
  State<meeting_page> createState() => _meeting_pageState();
}

class _meeting_pageState extends State<meeting_page> {
  @override
  void initState() {
    initRenderer();
    startMeeting();
    super.initState();
  }

  @override
  void deactivate() {
    _locallRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
    super.deactivate();
  }

  final _locallRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {'audio': true, 'video': true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: control_panel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnable(),
        audioEnabled: isAudioEnable(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
        url: 'http://192.168.1.9:4000',
        meetingId: widget.meetingDetail.id,
        userId: userId,
        name: widget.name);
    MediaStream _localStream =
        await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    _locallRenderer.srcObject = _localStream;
    meetingHelper!.stream = _localStream;

    meetingHelper!.on("open", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("connection", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("user-left", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("video-toggle", context, (ev, context) {
      setState(() {});
    });
    meetingHelper!.on("audio-toggle", context, (ev, context) {
      setState(() {});
    });
    meetingHelper!.on("meeting-ended", context, (ev, context) {
      onMeetingEnd();
    });
    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("stream-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    setState(() {});
  }

  initRenderer() async {
    await _locallRenderer.initialize();
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children:
                    List.generate(meetingHelper!.connections.length, (index) {
                  return Padding(
                    padding: EdgeInsets.all(1),
                    child: remote_connection(
                        renderer: meetingHelper!.connections[index].renderer,
                        connection: meetingHelper!.connections[index]),
                  );
                }))
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Waiting for participants",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ),
              ),
        Positioned(
            bottom: 10,
            right: 0,
            child: SizedBox(
              width: 150,
              height: 200,
              child: RTCVideoView(_locallRenderer),
            ))
      ],
    );
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  bool isVideoEnable() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  bool isAudioEnable() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => home_screen()));
  }
}
