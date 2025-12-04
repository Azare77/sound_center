import 'package:flutter/material.dart';

class ManualTest {
  static List<String> justAudioErrors = [];

  static void showJustAdioErrors(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: justAudioErrors.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(justAudioErrors[index]),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  justAudioErrors = [];
                  showJustAdioErrors(context);
                },
                child: Text("Clear"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("EXIT"),
              ),
            ],
          ),
        );
      },
    );
  }
}
