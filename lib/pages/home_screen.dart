import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:videocall/api/meeting_api.dart';
import 'package:videocall/models/meeting_details.dart';
import 'package:videocall/pages/join_screen.dart';

class home_screen extends StatefulWidget {
  const home_screen({Key? key}) : super(key: key);

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String meetingId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting App"),
      ),
      body: Form(
        key: globalKey,
        child: formUi(),
      ),
    );
  }

  formUi() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Welcome"),
            SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
                context, 'meetingId', "Enter Meeting Id", (val) {
              if (val.isEnpty) {
                return "Meeting cant be empty";
              }
              return null;
            }, (onSaved) {
              meetingId = onSaved;
            }),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: FormHelper.submitButton("join Meeting", () {
                  if (validateAndSave()) {
                    validateMeeting(meetingId);
                  }
                })),
                Flexible(
                    child: FormHelper.submitButton("Start Meeting", () async {
                  var response = await startMeeting();
                  final body = json.decode(response!.body);

                  final meetId = body['data'];
                  validateMeeting(meetId);
                })),
              ],
            )
          ],
        ),
      ),
    );
  }

  void validateMeeting(String meetingId) async {
    try {
      var response = await joinMeeting(meetingId);
      var data = json.decode(response.body);
      final meetingDetail = MeetingDetail.fromJson(data['data']);
      goToJoinScreen(meetingDetail);
    } catch (error) {
      FormHelper.showSimpleAlertDialog(
          context, "Meeting app", "Invalide Meeting Id", "Ok", () {
        Navigator.pop(context);
      });
    }
  }

  goToJoinScreen(MeetingDetail meetingDetail) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => join_screen(
                  meetingDetail: meetingDetail,
                )));
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
