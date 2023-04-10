import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class DiagnosisPage extends StatelessWidget {
  final Uint8List? image;
  const DiagnosisPage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Image.memory(image!),
      ),
    );
  }
}
