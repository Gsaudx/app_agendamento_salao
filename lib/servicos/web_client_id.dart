// Only compiled on web via conditional import.
import 'package:web/web.dart' as web;

String? readGoogleClientId() {
  final element =
      web.document.querySelector('meta[name="google-signin-client_id"]');
  // ignore: invalid_runtime_check_with_js_interop_types
  if (element is web.HTMLMetaElement) {
    final content = element.content.trim();
    return content.isEmpty ? null : content;
  }
  return null;
}
