import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling.dart';



class VideoCallRoom extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  bool cameraIsOpen=false, voiceIsOpen=false;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" Room"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  ElevatedButton(
                    onPressed: () async {
                      roomId = await signaling.createRoom(_remoteRenderer);
                      textEditingController.text = roomId!;
                      setState(() {});
                    },
                    child: Text("create new Meet"),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add roomId
                      signaling.joinRoom(
                        textEditingController.text,
                        _remoteRenderer,
                      );
                    },
                    child: Text("join to meet"),
                  ),

                ],
              ),
              SizedBox(
                height: 8,
              ),



              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            child: RTCVideoView(_localRenderer, mirror: true)),
                      )),
                      Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                          child: RTCVideoView(_remoteRenderer)))),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text("enter to following meeting "),
                    Flexible(
                      child: TextFormField(
                        controller: textEditingController,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8)
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 110),
              width: MediaQuery.of(context).size.width*0.65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    heroTag: '1',
                    onPressed: (){
                    signaling.openUserCamera(_localRenderer, _remoteRenderer);
                    setState((){
                      cameraIsOpen=true;
                    });
                  },child: Icon(cameraIsOpen?Icons.videocam:Icons.videocam_off_outlined),),
                  SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: FittedBox(
                      child: FloatingActionButton(
                        heroTag: '2',

                        onPressed: (){
                        signaling.hangUp(_localRenderer);


                      },
                        child: Icon(Icons.call_end),backgroundColor: Colors.red, ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: '3',

                    onPressed: (){
                    signaling.openUserVoice(_localRenderer, _remoteRenderer);
                    setState((){
                      voiceIsOpen=true;
                    });
                  },child: Icon(voiceIsOpen?Icons.mic_rounded:Icons.mic_off_rounded),),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}