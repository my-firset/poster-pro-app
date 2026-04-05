import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class FacebookPostingService {
  late WebViewController _webViewController;
  final String _groupUrl;
  final String _postText;
  final String? _cookies;

  FacebookPostingService({
    required String groupUrl,
    required String postText,
    String? cookies,
  })  : _groupUrl = groupUrl,
        _postText = postText,
        _cookies = cookies;

  Future<bool> postToGroup() async {
    try {
      // Initialize WebView
      _initializeWebView();

      // Load the group page
      await _webViewController.loadRequest(Uri.parse(_groupUrl));

      // Wait for page to load
      await Future.delayed(const Duration(seconds: 3));

      // Inject cookies if available
      if (_cookies != null && _cookies!.isNotEmpty) {
        await _injectCookies();
      }

      // Wait for page to fully load
      await Future.delayed(const Duration(seconds: 2));

      // Find and click the write button
      final writeButtonFound = await _findAndClickWriteButton();
      if (!writeButtonFound) {
        return false;
      }

      // Wait for text input to be ready
      await Future.delayed(const Duration(seconds: 1));

      // Inject the post text
      await _injectPostText();

      // Wait before posting
      await Future.delayed(const Duration(seconds: 1));

      // Find and click the post button
      final postButtonFound = await _findAndClickPostButton();
      if (!postButtonFound) {
        return false;
      }

      // Wait for post to be submitted
      await Future.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      print('Error posting to group: $e');
      return false;
    }
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web error: ${error.description}');
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      );
  }

  Future<void> _injectCookies() async {
    try {
      final cookieScript = '''
        document.cookie = "$_cookies";
      ''';
      await _webViewController.runJavaScript(cookieScript);
    } catch (e) {
      print('Error injecting cookies: $e');
    }
  }

  Future<bool> _findAndClickWriteButton() async {
    try {
      final script = '''
        (function() {
          var selectors = [
            'div[role="button"][tabindex="0"]',
            '[data-testid="status-attachment-mentions-input"]',
            'div[contenteditable="true"]'
          ];
          
          for (var s of selectors) {
            var el = document.querySelector(s);
            if (el) {
              el.click();
              return true;
            }
          }
          
          var all = document.querySelectorAll('div[role="button"]');
          for (var b of all) {
            var t = b.innerText.toLowerCase();
            if (t.includes('write') || t.includes('اكتب') || t.includes("what's on")) {
              b.click();
              return true;
            }
          }
          
          return false;
        })()
      ''';

      final result = await _webViewController.runJavaScriptReturningResult(script);
      return result == true || result == 'true';
    } catch (e) {
      print('Error finding write button: $e');
      return false;
    }
  }

  Future<void> _injectPostText() async {
    try {
      final script = '''
        (function() {
          function injectText(element, text) {
            element.focus();
            document.execCommand('selectAll', false, null);
            document.execCommand('insertText', false, text);
            
            var tracker = element._valueTracker;
            if (tracker) tracker.setValue('');
            
            element.innerText = text;
            element.dispatchEvent(new Event('input', { bubbles: true }));
            element.dispatchEvent(new Event('change', { bubbles: true }));
            element.dispatchEvent(new KeyboardEvent('keyup', { bubbles: true }));
          }
          
          var selectors = [
            '[data-testid="status-attachment-mentions-input"]',
            'div[contenteditable="true"]',
            'textarea'
          ];
          
          for (var s of selectors) {
            var el = document.querySelector(s);
            if (el) {
              injectText(el, "${_postText.replaceAll('"', '\\"')}");
              return true;
            }
          }
          
          return false;
        })()
      ''';

      await _webViewController.runJavaScript(script);
    } catch (e) {
      print('Error injecting post text: $e');
    }
  }

  Future<bool> _findAndClickPostButton() async {
    try {
      final script = '''
        (function() {
          var ariaSelectors = [
            '[aria-label="Post"]',
            '[aria-label="نشر"]',
            '[aria-label="Share"]',
            '[aria-label="مشاركة"]'
          ];
          
          for (var s of ariaSelectors) {
            var el = document.querySelector(s);
            if (el && el.offsetParent !== null) {
              el.click();
              return true;
            }
          }
          
          var all = document.querySelectorAll('div[role="button"], button');
          for (var b of all) {
            var txt = b.innerText.trim().toLowerCase();
            if (['post','نشر','share','مشاركة'].includes(txt)) {
              b.click();
              return true;
            }
          }
          
          return false;
        })()
      ''';

      final result = await _webViewController.runJavaScriptReturningResult(script);
      return result == true || result == 'true';
    } catch (e) {
      print('Error finding post button: $e');
      return false;
    }
  }

  WebViewController getWebViewController() {
    return _webViewController;
  }
}
