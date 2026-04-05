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
  String _accountType = 'personal';
  String? _selectedPageName;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            debugPrint('Page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web error: ${error.description}');
          },
        ),
      )
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36')
      ..loadRequest(Uri.parse('https://m.facebook.com/login'));
  }

  Future<void> _checkLoginStatus() async {
    try {
      final url = await _webViewController.currentUrl();
      debugPrint('Current URL: $url');
      
      if (url != null && (url.contains('/home') || url.contains('facebook.com/?'))) {
        // User is logged in
        final cookies = await _webViewController.runJavaScriptReturningResult(
          'document.cookie'
        );
        debugPrint('Cookies: $cookies');
        
        if (mounted) {
          _showAccountDialog(cookies.toString());
        }
      }
    } catch (e) {
      debugPrint('Error checking login: $e');
    }
  }

  void _showAccountDialog(String cookies) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الحساب',
                hintText: 'مثال: حسابي الشخصي',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _accountType,
              isExpanded: true,
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
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final account = FacebookAccount(
                  name: nameController.text,
                  type: _accountType,
                  isLoggedIn: true,
                );
                
                context.read<AccountProvider>().addAccount(account);
                context.read<AccountProvider>().saveCookies(account.id, cookies);
                
                Navigator.pop(context);
                setState(() {
                  _showWebView = false;
                });
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحسابات'),
        centerTitle: true,
      ),
      body: _showWebView
          ? WebViewWidget(controller: _webViewController)
          : Consumer<AccountProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (provider.accounts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.account_circle,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'لم تقم بإضافة أي حساب بعد',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showWebView = true;
                                  });
                                  _initializeWebView();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('إضافة حساب'),
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1877F2),
                                  child: Text(
                                    account.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(account.name),
                                subtitle: Text(
                                  account.type == 'personal'
                                      ? 'حساب شخصي'
                                      : 'صفحة',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: account.isLoggedIn
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('حذف'),
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
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showWebView = true;
                                });
                                _initializeWebView();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1877F2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('إضافة حساب جديد'),
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
