import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:videocall/models/meeting_details.dart';
import 'package:videocall/pages/meeting_page.dart';

class join_screen extends StatefulWidget {
  join_screen({Key? key, this.meetingDetail}) : super(key: key);
  final MeetingDetail? meetingDetail;

  @override
  State<join_screen> createState() => _join_screenState();
}

class _join_screenState extends State<join_screen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Meeting"),
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
            SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(context, 'userId', "Enter Name", (val) {
              if (val.isEnpty) {
                return "Name cant be empty";
              }
              return null;
            }, (onSaved) {
              userName = onSaved;
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
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: ((context) {
                          return meeting_page(
                              meetingId: widget.meetingDetail!.id,
                              name: userName,
                              meetingDetail: widget.meetingDetail!);
                        })));
                      }
                    }))
              ],
            )
          ],
        ),
      ),
    );
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
