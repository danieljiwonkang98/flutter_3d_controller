import 'dart:convert';
import 'package:flutter_3d_controller/src/data/datasources/i_flutter_3d_datasource.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Flutter3DDatasource implements IFlutter3DDatasource {
  final WebViewController? _webViewController;

  Flutter3DDatasource([this._webViewController]);

  @override
  void playAnimation({String? animationName}) {
    animationName == null
        ? executeCustomJsCode(
            "const modelViewer = document.querySelector(\"model-viewer\");"
            "modelViewer.play();")
        : executeCustomJsCode(
            "const modelViewer = document.querySelector(\"model-viewer\");"
            "modelViewer.animationName = \"$animationName\";"
            "modelViewer.play();");
  }

  @override
  void pauseAnimation() {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.pause();");
  }

  @override
  void resetAnimation() {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.pause();"
        "modelViewer.currentTime = 0;"
        "modelViewer.play();");
  }

  @override
  Future<List<String>> getAvailableAnimations() async {
    final result = await executeCustomJsCodeWithResult(
        "document.querySelector(\"model-viewer\").availableAnimations;");
    // String checkedResult;
    if (result is String) {
      return _ensureQuotesAndConvertToList(result);
      // checkedResult = _tupleToList(result);
    } else {
      return [];
    }
    // return jsonDecode(checkedResult).map<String>((e) => e.toString()).toList();
  }

  List<String> _ensureQuotesAndConvertToList(String input) {
    // Removing parentheses and trimming the input string
    String cleanedInput = input.replaceAll('(', '').replaceAll(')', '').trim();

    // Splitting the string by commas
    List<String> elements = cleanedInput.split(',');

    // Trimming each element and removing any quotes
    List<String> resultList = elements.map((element) {
      String trimmedElement = element.trim();
      if (trimmedElement.startsWith('"') && trimmedElement.endsWith('"')) {
        return trimmedElement.substring(1, trimmedElement.length - 1);
      } else {
        return trimmedElement;
      }
    }).toList();

    return resultList;
  }

  @override
  void setTexture({required String textureName}) {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.variantName = \"$textureName\";");
  }

  @override
  Future<List<String>> getAvailableTextures() async {
    final result = await executeCustomJsCodeWithResult(
        "document.querySelector(\"model-viewer\").availableVariants;");
    String checkedResult;
    if (result is String) {
      checkedResult = _tupleToList(result);
    } else {
      return [];
    }
    return jsonDecode(checkedResult).map<String>((e) => e.toString()).toList();
  }

  @override
  void setCameraTarget(double x, double y, double z) {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.cameraTarget = \"${x}m ${y}m ${z}m\";");
  }

  @override
  void resetCameraTarget() {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.cameraTarget = \"auto auto auto\";");
  }

  @override
  void setCameraOrbit(double theta, double phi, double radius) {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.cameraOrbit = \"${theta}deg ${phi}deg $radius%\";");
  }

  @override
  void resetCameraOrbit() {
    executeCustomJsCode(
        "const modelViewer = document.querySelector(\"model-viewer\");"
        "modelViewer.cameraOrbit = \"0deg 75deg 105%\" ;");
  }

  @override
  void executeCustomJsCode(String code) {
    _webViewController?.runJavaScript('''(() => {
        customEvaluate('$code'); 
      })();
    ''');
  }

  @override
  Future<dynamic> executeCustomJsCodeWithResult(String code) async {
    final result = await _webViewController?.runJavaScriptReturningResult(code);
    return result;
  }

  /*
  * Converts Tuple string to List
  * */
  String _tupleToList(String input) {
    String trimmedString = input.trim();
    if (trimmedString.isNotEmpty && trimmedString.length > 2) {
      if (trimmedString[0] == "(") {
        trimmedString = trimmedString.replaceFirst("(", "[");
      }
      if (trimmedString[trimmedString.length - 1] == ")") {
        trimmedString =
            trimmedString.substring(0, trimmedString.length - 2) + "]";
      }
      return trimmedString;
    } else {
      return "[]";
    }
  }
}
