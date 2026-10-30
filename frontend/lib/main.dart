
import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BorrowingApp());
}

const ink = Color(0xFF182C45);
const brand = Color(0xFF174EA6);
const brandDark = Color(0xFF10356E);
const softText = Color(0xFF53657D);
const pageColor = Color(0xFFF3F7FD);

const assetDay = 'assets/images/campus_day.jpg';
const assetLogo = 'assets/images/uls_logo.png';

class BorrowingApp extends StatelessWidget {
  const BorrowingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Equipment Borrowing Reminder System',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageColor,
        colorScheme: ColorScheme.fromSeed(seedColor: brand),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.92),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDDE7F4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brand, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

// ------------------------------
// COMMON WIDGETS
// ------------------------------

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.98),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14143A72),
                blurRadius: 20,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeading(this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: brand,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: softText),
          ),
        ],
      ),
    );
  }
}

class InfoStrip extends StatelessWidget {
  final String message;
  final IconData icon;

  const InfoStrip({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E6F8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: brand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: ink, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class ApiData extends StatefulWidget {
  final Future<dynamic> Function() loader;
  final Widget Function(dynamic) builder;
  final int refreshKey;

  const ApiData({
    super.key,
    required this.loader,
    required this.builder,
    required this.refreshKey,
  });

  @override
  State<ApiData> createState() => _ApiDataState();
}

class _ApiDataState extends State<ApiData> {
  late Future<dynamic> future;

  @override
  void initState() {
    super.initState();
    future = widget.loader();
  }

  @override
  void didUpdateWidget(covariant ApiData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      future = widget.loader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const GlassPanel(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return GlassPanel(
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check the Laravel API and refresh the page.',
                  style: TextStyle(color: softText),
                ),
              ],
            ),
          );
        }

        return widget.builder(snapshot.data);
      },
    );
  }
}

String valueOf(dynamic value) => value?.toString() ?? '—';

List<dynamic> rowsOf(dynamic data) {
  if (data is List) return data;
  if (data is Map && data['data'] is List) {
    return data['data'] as List;
  }
  return [];
}

// ------------------------------
// APPLICATION ROOT
// ------------------------------

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final ApiClient api = ApiClient();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool loggedIn = false;
  bool collapsed = false;
  String username = 'Operator';
  int page = 0;
  int refresh = 0;

  final labels = const [
    'Overview',
    'Equipment',
    'Borrowings',
    'Automation',
    'User Guide',
  ];

  final icons = const [
    Icons.space_dashboard_rounded,
    Icons.inventory_2_rounded,
    Icons.assignment_return_rounded,
    Icons.bolt_rounded,
    Icons.menu_book_rounded,
  ];

  void reload() {
    if (mounted) setState(() => refresh++);
  }

  void notify(String text, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : brandDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {
      api.token = null;
    }

    if (!mounted) return;

    setState(() {
      loggedIn = false;
      page = 0;
    });
  }

  void navigate(int index, bool mobile) {
    setState(() => page = index);

    if (mobile && scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  Widget currentPage() {
    switch (page) {
      case 0:
        return OverviewScreen(api: api, refresh: refresh);
      case 1:
        return EquipmentScreen(
          api: api,
          refresh: refresh,
          changed: reload,
          notify: notify,
        );
      case 2:
        return BorrowingsScreen(
          api: api,
          refresh: refresh,
          changed: reload,
          notify: notify,
        );
      case 3:
        return AutomationScreen(
          api: api,
          refresh: refresh,
          changed: reload,
          notify: notify,
        );
      default:
        return const UserGuideScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return LoginScreen(
        api: api,
        onLogin: (name) {
          if (!mounted) return;

          setState(() {
            loggedIn = true;
            username = name;
            refresh++;
          });
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 980;

        Widget sidebar() {
          return SidebarMenu(
            labels: labels,
            icons: icons,
            selected: page,
            collapsed: desktop && collapsed,
            onSelect: (index) => navigate(index, !desktop),
            onToggle: () => setState(() => collapsed = !collapsed),
            onLogout: logout,
          );
        }

        return Scaffold(
          key: scaffoldKey,
          drawer: desktop
              ? null
              : Drawer(
            backgroundColor: pageColor,
            child: SafeArea(child: sidebar()),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(assetDay, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.91),
                ),
              ),
              SafeArea(
                child: Row(
                  children: [
                    if (desktop)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: collapsed ? 94 : 266,
                        padding: const EdgeInsets.all(14),
                        child: sidebar(),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            child: GlassPanel(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 9,
                              ),
                              child: Row(
                                children: [
                                  if (!desktop)
                                    IconButton(
                                      icon: const Icon(Icons.menu_rounded),
                                      onPressed: () => scaffoldKey
                                          .currentState
                                          ?.openDrawer(),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          labels[page],
                                          style: const TextStyle(
                                            color: ink,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Text(
                                          'Welcome, $username',
                                          style: const TextStyle(
                                            color: softText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Refresh',
                                    onPressed: reload,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: brand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                  const BoxConstraints(maxWidth: 1250),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      GlassPanel(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 54,
                                              height: 54,
                                              child: Image.asset(
                                                assetLogo,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'UNIVERSITY OF LA SALETTE',
                                                    style: TextStyle(
                                                      color: brand,
                                                      fontSize: 11,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    labels[page],
                                                    style: const TextStyle(
                                                      color: ink,
                                                      fontWeight:
                                                      FontWeight.w800,
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Equipment Borrowing Reminder System',
                                                    style: TextStyle(
                                                      color: softText,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      currentPage(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------
// LOGIN SCREEN
// ------------------------------

class LoginScreen extends StatefulWidget {
  final ApiClient api;
  final ValueChanged<String> onLogin;

  const LoginScreen({
    super.key,
    required this.api,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || busy) return;

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final result = await widget.api.login(
        email.text.trim(),
        password.text,
      );

      if (!mounted) return;

      final user = result['user'];
      final name = user is Map
          ? valueOf(user['name'])
          : 'Operator';

      widget.onLogin(name);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(assetDay, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.87),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 800;

                    final branding = GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            assetLogo,
                            height: 85,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Equipment Borrowing\nReminder System',
                            style: TextStyle(
                              color: ink,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'University equipment inventory, borrowing, returns, and reminder monitoring.',
                            style: TextStyle(
                              color: softText,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );

                    final loginForm = GlassPanel(
                      padding: const EdgeInsets.all(25),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.lock_person_rounded,
                                  color: brand,
                                  size: 32,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Operator email',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              validator: (v) {
                                if (v == null || !v.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter your password';
                                }
                                return null;
                              },
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: busy ? null : submit,
                              child: busy
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text('Sign in'),
                            ),
                            const SizedBox(height: 16),
                            const InfoStrip(
                              message:
                              'Training environment. Reminder delivery is simulated.',
                            ),
                          ],
                        ),
                      ),
                    );

                    if (compact) {
                      return Column(
                        children: [
                          branding,
                          const SizedBox(height: 18),
                          loginForm,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: branding),
                        const SizedBox(width: 20),
                        Expanded(child: loginForm),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------
// SIDEBAR NAVIGATION
// ------------------------------

class SidebarMenu extends StatelessWidget {
  final List<String> labels;
  final List<IconData> icons;
  final int selected;
  final bool collapsed;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggle;
  final VoidCallback onLogout;

  const SidebarMenu({
    super.key,
    required this.labels,
    required this.icons,
    required this.selected,
    required this.collapsed,
    required this.onSelect,
    required this.onToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 42,
                width: 42,
                child: Image.asset(assetLogo),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'EQUIPTRACK',
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          IconButton(
            tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
            onPressed: onToggle,
            icon: Icon(
              collapsed
                  ? Icons.keyboard_double_arrow_right_rounded
                  : Icons.keyboard_double_arrow_left_rounded,
              color: brand,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tooltip(
                message: labels[i],
                child: Material(
                  color: selected == i
                      ? const Color(0xFFE5EFFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    hoverColor: const Color(0xFFE7F0FE),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        mainAxisAlignment: collapsed
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          Icon(icons[i], color: brand),
                          if (!collapsed) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                labels[i],
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          ListTile(
            onTap: onLogout,
            leading: const Icon(Icons.logout_rounded, color: brand),
            title: collapsed
                ? null
                : const Text(
              'Log out',
              style: TextStyle(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------
// OVERVIEW
// ------------------------------

class OverviewScreen extends StatelessWidget {
  final ApiClient api;
  final int refresh;

  const OverviewScreen({
    super.key,
    required this.api,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          'System overview',
          'Current inventory and reminder status.',
        ),
        ApiData(
          refreshKey: refresh,
          loader: () => api.call('GET', '/dashboard'),
          builder: (data) {
            final d = data as Map;

            final stats = [
              ['Equipment types', d['equipment_types'], Icons.inventory],
              ['Available units', d['available_units'], Icons.check_circle],
              ['Active loans', d['active_borrowings'], Icons.assignment],
              ['Due within 48h', d['due_soon'], Icons.schedule],
              ['Needs review', d['needs_review'], Icons.warning_amber],
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1050
                    ? 5
                    : width >= 650
                    ? 3
                    : width >= 430
                    ? 2
                    : 1;

                final cardWidth =
                    (width - (columns - 1) * 12) / columns;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final stat in stats)
                      SizedBox(
                        width: cardWidth,
                        child: GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                stat[2] as IconData,
                                color: brand,
                                size: 28,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                stat[0] as String,
                                style: const TextStyle(
                                  color: softText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                valueOf(stat[1]),
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
        const GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Equipment management',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Use Equipment to register inventory, Borrowings to issue and return items, and Automation to review simulated reminder results.',
                style: TextStyle(color: softText, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------
// EQUIPMENT REGISTRATION DIALOG
// ------------------------------

class EquipmentFormDialog extends StatefulWidget {
  const EquipmentFormDialog({super.key});

  @override
  State<EquipmentFormDialog> createState() => _EquipmentFormDialogState();
}

class _EquipmentFormDialogState extends State<EquipmentFormDialog> {
  final keyForm = GlobalKey<FormState>();

  String tag = '';
  String name = '';
  String category = '';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register equipment'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: keyForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Asset tag',
                  ),
                  onChanged: (v) => tag = v.trim(),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Asset tag is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Equipment name',
                  ),
                  onChanged: (v) => name = v.trim(),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Equipment name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  onChanged: (v) => category = v.trim(),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Category is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                  ),
                  onChanged: (v) => quantity = int.tryParse(v) ?? 0,
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1
                      ? 'Enter a positive whole number'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!keyForm.currentState!.validate()) return;

            Navigator.pop(context, {
              'asset_tag': tag,
              'name': name,
              'category': category,
              'quantity_total': quantity,
            });
          },
          child: const Text('Save equipment'),
        ),
      ],
    );
  }
}

// ------------------------------
// EQUIPMENT SCREEN
// ------------------------------

class EquipmentScreen extends StatelessWidget {
  final ApiClient api;
  final int refresh;
  final VoidCallback changed;
  final void Function(String, {bool error}) notify;

  const EquipmentScreen({
    super.key,
    required this.api,
    required this.refresh,
    required this.changed,
    required this.notify,
  });

  Future<void> addEquipment(BuildContext context) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const EquipmentFormDialog(),
    );

    if (data == null) return;

    try {
      await api.call('POST', '/equipment', data);
      changed();
      notify('Equipment registered successfully.');
    } catch (e) {
      notify('$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          'Equipment inventory',
          'Register and monitor available equipment.',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => addEquipment(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add equipment'),
          ),
        ),
        const SizedBox(height: 15),
        ApiData(
          refreshKey: refresh,
          loader: () => api.call('GET', '/equipment'),
          builder: (data) {
            final rows = rowsOf(data);

            if (rows.isEmpty) {
              return const GlassPanel(
                child: Text('No equipment registered yet.'),
              );
            }

            return GlassPanel(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Asset tag')),
                    DataColumn(label: Text('Equipment')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Available')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: [
                    for (final item in rows)
                      DataRow(
                        cells: [
                          DataCell(Text(valueOf(item['asset_tag']))),
                          DataCell(Text(valueOf(item['name']))),
                          DataCell(Text(valueOf(item['category']))),
                          DataCell(Text(valueOf(item['quantity_available']))),
                          DataCell(Text(valueOf(item['quantity_total']))),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------
// BORROWING FORM
// ------------------------------

class BorrowingFormDialog extends StatefulWidget {
  final List<dynamic> equipment;

  const BorrowingFormDialog({
    super.key,
    required this.equipment,
  });

  @override
  State<BorrowingFormDialog> createState() =>
      _BorrowingFormDialogState();
}

class _BorrowingFormDialogState extends State<BorrowingFormDialog> {
  final formKey = GlobalKey<FormState>();

  int? equipmentId;
  String borrowerName = '';
  late DateTime dueDate;

  @override
  void initState() {
    super.initState();

    equipmentId = widget.equipment.first['id'] as int;
    dueDate = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> chooseDate() async {
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
    );

    if (!mounted || picked == null) return;

    setState(() => dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New borrowing'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: equipmentId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Equipment',
                  ),
                  items: [
                    for (final e in widget.equipment)
                      DropdownMenuItem<int>(
                        value: e['id'] as int,
                        child: Text(
                          '${e['name']} (${e['quantity_available']} available)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    equipmentId = value;
                  },
                  validator: (value) =>
                  value == null ? 'Select equipment' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Borrower name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  onChanged: (value) {
                    borrowerName = value.trim();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Borrower name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due: ${dueDate.year}-'
                            '${dueDate.month.toString().padLeft(2, '0')}-'
                            '${dueDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: chooseDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Choose'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            final due = DateTime(
              dueDate.year,
              dueDate.month,
              dueDate.day,
              17,
            );

            Navigator.pop(context, {
              'equipment_id': equipmentId,
              'borrower_name': borrowerName,
              'due_at': due.toIso8601String(),
            });
          },
          child: const Text('Create borrowing'),
        ),
      ],
    );
  }
}

// ------------------------------
// BORROWINGS SCREEN
// ------------------------------

class BorrowingsScreen extends StatelessWidget {
  final ApiClient api;
  final int refresh;
  final VoidCallback changed;
  final void Function(String, {bool error}) notify;

  const BorrowingsScreen({
    super.key,
    required this.api,
    required this.refresh,
    required this.changed,
    required this.notify,
  });

  Future<void> createBorrowing(BuildContext context) async {
    try {
      final response = await api.call('GET', '/equipment');
      final available = rowsOf(response).where((item) {
        return (num.tryParse(
          valueOf(item['quantity_available']),
        ) ??
            0) >
            0;
      }).toList();

      if (!context.mounted) return;

      if (available.isEmpty) {
        notify('No equipment is currently available.', error: true);
        return;
      }

      final data = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (_) => BorrowingFormDialog(equipment: available),
      );

      if (data == null || !context.mounted) return;

      await api.call('POST', '/borrowings', data);

      changed();
      notify('Borrowing created successfully.');
    } catch (e) {
      notify('$e', error: true);
    }
  }

  Future<void> performAction(
      int id,
      String action,
      String success,
      ) async {
    try {
      await api.call('POST', '/borrowings/$id/$action');
      changed();
      notify(success);
    } catch (e) {
      notify('$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          'Borrowing records',
          'Issue, return, and monitor equipment borrowings.',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => createBorrowing(context),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('New borrowing'),
          ),
        ),
        const SizedBox(height: 15),
        ApiData(
          refreshKey: refresh,
          loader: () => api.call('GET', '/borrowings'),
          builder: (data) {
            final rows = rowsOf(data);

            if (rows.isEmpty) {
              return const GlassPanel(
                child: Text('No borrowing records yet.'),
              );
            }

            return Column(
              children: [
                for (final item in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassPanel(
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueOf(item['equipment']?['name']),
                                  style: const TextStyle(
                                    color: brand,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Loan #${item['id']} • ${item['borrower_name']}',
                                ),
                                Text(
                                  'Due: ${valueOf(item['due_at']).split('T').first}',
                                  style: const TextStyle(color: softText),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Loan: ${item['status']}',
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Reminder: ${item['reminder_status']}',
                            ),
                          ),
                          if (item['status'] == 'active')
                            OutlinedButton(
                              onPressed: () => performAction(
                                item['id'] as int,
                                'return',
                                'Equipment returned successfully.',
                              ),
                              child: const Text('Mark returned'),
                            ),
                          if (item['status'] == 'active' &&
                              item['reminder_status'] == 'needs_review')
                            OutlinedButton(
                              onPressed: () => performAction(
                                item['id'] as int,
                                'reset-reminder',
                                'Reminder reset successfully.',
                              ),
                              child: const Text('Reset reminder'),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------
// AUTOMATION SCREEN
// ------------------------------

class AutomationScreen extends StatefulWidget {
  final ApiClient api;
  final int refresh;
  final VoidCallback changed;
  final void Function(String, {bool error}) notify;

  const AutomationScreen({
    super.key,
    required this.api,
    required this.refresh,
    required this.changed,
    required this.notify,
  });

  @override
  State<AutomationScreen> createState() =>
      _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  String mode = 'success';
  bool busy = false;
  Map<String, dynamic>? result;

  Future<void> runAutomation() async {
    if (busy) return;

    setState(() => busy = true);

    try {
      final response = await widget.api.call(
        'POST',
        '/automation/run',
        {'mode': mode},
      );

      if (!mounted) return;

      setState(() {
        result = Map<String, dynamic>.from(response as Map);
      });

      widget.changed();
      widget.notify('Automation completed. Check the event logs.');
    } catch (e) {
      widget.notify('$e', error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          'Reminder automation',
          'Demonstrate success, retry, recovery, and manual review.',
        ),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Automation scenario',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: mode,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'success',
                    child: Text('Normal success'),
                  ),
                  DropdownMenuItem(
                    value: 'transient_once',
                    child: Text('Transient failure → retry → success'),
                  ),
                  DropdownMenuItem(
                    value: 'transient_always',
                    child: Text('All attempts fail → review queue'),
                  ),
                  DropdownMenuItem(
                    value: 'permanent_failure',
                    child: Text('Permanent failure → review queue'),
                  ),
                ],
                onChanged: busy
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() => mode = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              const InfoStrip(
                message:
                'Reminders are simulated for testing. No real messages are sent.',
              ),
              const SizedBox(height: 15),
              FilledButton.icon(
                onPressed: busy ? null : runAutomation,
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Run automation'),
              ),
              if (result != null) ...[
                const SizedBox(height: 18),
                Text(
                  'Run: ${result!['run_id']}\n'
                      'Processed: ${result!['processed']}\n'
                      'Completed: ${result!['completed']}\n'
                      'Retries: ${result!['retries']}\n'
                      'Needs review: ${result!['needs_review']}',
                  style: const TextStyle(
                    color: ink,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Structured event logs',
          style: TextStyle(
            color: brand,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ApiData(
          refreshKey: widget.refresh,
          loader: () => widget.api.call(
            'GET',
            '/automation/events',
          ),
          builder: (data) {
            final events = rowsOf(data);

            if (events.isEmpty) {
              return const GlassPanel(
                child: Text('No automation events recorded yet.'),
              );
            }

            return Column(
              children: [
                for (final event in events)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassPanel(
                      child: ListTile(
                        leading: const Icon(
                          Icons.receipt_long_rounded,
                          color: brand,
                        ),
                        title: Text(
                          '${event['event_type']} • ${event['result_code']}',
                          style: const TextStyle(
                            color: ink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Loan: ${event['borrowing_id'] ?? '—'}\n'
                              'Attempt: ${event['attempt']}\n'
                              'Run: ${event['run_id']}\n'
                              '${event['created_at']}',
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------
// USER GUIDE
// ------------------------------

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      [
        '1. Register equipment',
        'Open Equipment and click Add equipment. Enter asset tag, name, category, and quantity.',
      ],
      [
        '2. Create borrowing',
        'Open Borrowings, click New borrowing, select equipment, enter a fictional borrower, and select a due date.',
      ],
      [
        '3. Run normal automation',
        'Open Automation, select Normal success, and click Run automation.',
      ],
      [
        '4. Test retry',
        'Create another eligible borrowing and select Transient failure to demonstrate retry and recovery.',
      ],
      [
        '5. Test permanent failure',
        'Create another eligible borrowing and select Permanent failure to demonstrate manual review.',
      ],
      [
        '6. Return equipment',
        'Open Borrowings and click Mark returned for an active loan.',
      ],
      [
        '7. Log out',
        'Use the sidebar Log out button to end the session.',
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          'User guide',
          'Step-by-step instructions for system operations.',
        ),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final step in steps) ...[
                Text(
                  step[0],
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  step[1],
                  style: const TextStyle(
                    color: softText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const InfoStrip(
                message:
                'Capture actual application screenshots and backend test results for Week 13 evidence.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
