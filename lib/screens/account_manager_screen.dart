import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/account_provider.dart';

class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({Key? key}) : super(key: key);

  @override
  State<AccountManagerScreen> createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> {
  late WebViewController _webViewController;
  bool _showWebView = false;
  bool _isDetectingLogin = false;
  String _accountType = 'personal';

  @override
  void initState() {
    super.initState();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            debugPrint('Page finished: $url');
            _autoDetectLogin(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web error: ${error.description}');
          },
        ),
      )
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36')
      ..loadRequest(Uri.parse('https://m.facebook.com/login'));
  }

  Future<void> _autoDetectLogin(String url) async {
    if (_isDetectingLogin) return;

    final isLoggedIn = url.contains('m.facebook.com/?') ||
        url.contains('m.facebook.com/home') ||
        url.contains('facebook.com/home.php') ||
        (url.contains('facebook.com') &&
            !url.contains('/login') &&
            !url.contains('/checkpoint') &&
            !url.contains('/two_step'));

    if (isLoggedIn) {
      setState(() {
        _isDetectingLogin = true;
      });

      String userName = '';
      try {
        final nameResult = await _webViewController.runJavaScriptReturningResult(
          '''(function() {
            var nameEl = document.querySelector('[data-sigil="profile-name"]') ||
                         document.querySelector(".profileName") ||
                         document.querySelector("h1");
            return nameEl ? nameEl.innerText.trim() : "";
          })()''',
        );
        userName = nameResult.toString().replaceAll('"', '').trim();
      } catch (e) {
        debugPrint('Error getting name: $e');
      }

      String cookies = '';
      try {
        final cookieResult = await _webViewController.runJavaScriptReturningResult(
          'document.cookie',
        );
        cookies = cookieResult.toString();
      } catch (e) {
        debugPrint('Error getting cookies: $e');
      }

      if (mounted) {
        _showSaveAccountDialog(userName, cookies);
      }

      setState(() {
        _isDetectingLogin = false;
      });
    }
  }

  Future<List<Map<String, String>>> _fetchGroups() async {
    List<Map<String, String>> groups = [];

    try {
      await _webViewController.loadRequest(
        Uri.parse('https://m.facebook.com/groups/?seemore=1'),
      );

      await Future.delayed(const Duration(seconds: 4));

      final result = await _webViewController.runJavaScriptReturningResult(
        '''(function() {
          var groups = [];
          var links = document.querySelectorAll("a[href*='/groups/']");
          links.forEach(function(link) {
            var href = link.getAttribute("href") || "";
            var name = link.innerText.trim();
            if (name && name.length > 2 && href.includes("/groups/") && 
                !href.includes("?") && !href.includes("create") &&
                !href.includes("discover") && !href.includes("feed")) {
              var fullUrl = href.startsWith("http") ? href : "https://www.facebook.com" + href;
              var exists = groups.find(function(g) { return g.url === fullUrl; });
              if (!exists && groups.length < 300) {
                groups.push({name: name, url: fullUrl});
              }
            }
          });
          return JSON.stringify(groups);
        })()''',
      );

      final String jsonStr = result.toString();
      final cleaned = jsonStr.startsWith('"') && jsonStr.endsWith('"')
          ? jsonStr.substring(1, jsonStr.length - 1).replaceAll('\\"', '"').replaceAll('\\\\', '\\')
          : jsonStr;

      final List<dynamic> parsed = json.decode(cleaned);
      groups = parsed
          .map((g) => {
                'name': g['name'].toString(),
                'url': g['url'].toString(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching groups: $e');
    }

    return groups;
  }

  void _showSaveAccountDialog(String detectedName, String cookies) {
    final nameController = TextEditingController(text: detectedName);
    bool isFetchingGroups = false;
    List<Map<String, String>> fetchedGroups = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: const Text(
            'تم تسجيل الدخول ✅',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'اسم الحساب',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'مثال: حسابي الشخصي',
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1877F2)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'نوع الحساب:',
                  style: TextStyle(color: Colors.grey),
                ),
                DropdownButton<String>(
                  value: _accountType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2a2a2a),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'personal',
                      child: Text('حساب شخصي'),
                    ),
                    DropdownMenuItem(
                      value: 'page',
                      child: Text('صفحة'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _accountType = value ?? 'personal';
                    });
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isFetchingGroups
                        ? null
                        : () async {
                            setDialogState(() {
                              isFetchingGroups = true;
                            });
                            final groups = await _fetchGroups();
                            setDialogState(() {
                              fetchedGroups = groups;
                              isFetchingGroups = false;
                            });
                          },
                    icon: isFetchingGroups
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.group),
                    label: Text(isFetchingGroups
                        ? 'جاري جلب الجروبات...'
                        : 'جلب جروباتي (${fetchedGroups.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                    ),
                  ),
                ),
                if (fetchedGroups.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'تم جلب ${fetchedGroups.length} جروب ✅',
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showWebView = false;
                  _isDetectingLogin = false;
                });
              },
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final account = FacebookAccount(
                    name: nameController.text,
                    type: _accountType,
                    isLoggedIn: true,
                    groups: fetchedGroups,
                  );

                  context.read<AccountProvider>().addAccount(account);
                  context.read<AccountProvider>().saveCookies(account.id, cookies);

                  Navigator.pop(context);
                  setState(() {
                    _showWebView = false;
                    _isDetectingLogin = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حفظ الحساب مع ${fetchedGroups.length} جروب ✅',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
              ),
              child: const Text('حفظ الحساب'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1877F2),
        title: const Text(
          'إدارة الحسابات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_showWebView)
            TextButton(
              onPressed: () {
                setState(() {
                  _showWebView = false;
                  _isDetectingLogin = false;
                });
              },
              child: const Text('رجوع', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _showWebView
          ? Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isDetectingLogin)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF1877F2)),
                          SizedBox(height: 16),
                          Text(
                            'تم اكتشاف تسجيل الدخول...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : Consumer<AccountProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (provider.accounts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1877F2).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Color(0xFF1877F2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'لم تقم بإضافة أي حساب بعد',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'أضف حسابك لتبدأ النشر التلقائي',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showWebView = true;
                                  });
                                  _initializeWebView();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة حساب فيسبوك'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...provider.accounts.map((account) {
                            return Card(
                              color: const Color(0xFF1a1a1a),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1877F2),
                                  radius: 24,
                                  child: Text(
                                    account.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  account.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.type == 'personal' ? 'حساب شخصي' : 'صفحة',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '${account.groups?.length ?? 0} جروب مرتبط',
                                      style: const TextStyle(
                                        color: Color(0xFF1877F2),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: account.isLoggedIn
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton(
                                      color: const Color(0xFF2a2a2a),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'حذف',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          context
                                              .read<AccountProvider>()
                                              .deleteAccount(account.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showWebView = true;
                                });
                                _initializeWebView();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة حساب جديد'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1877F2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
    );
  }
}