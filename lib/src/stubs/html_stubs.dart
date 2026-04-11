/// Stub implementations for dart:html and dart:ui_web on non-web platforms
class IFrameElement {
  String? src;
  late _CSSStyleDeclaration style;

  IFrameElement() {
    style = _CSSStyleDeclaration();
  }

  void setAttribute(String name, String value) {}
}

class _CSSStyleDeclaration {
  String? border;
  String? width;
  String? height;
}

class PlatformViewRegistry {
  void registerViewFactory(String viewType, dynamic callback) {}
}

final platformViewRegistry = PlatformViewRegistry();
