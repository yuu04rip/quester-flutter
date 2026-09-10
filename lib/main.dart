// lib/main.dart

import 'dart:io' show Platform;

import 'package:Quester/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/database/database_provider.dart';
import 'data/models/shop_item.dart';
import 'data/preferences/theme_preferences.dart';
import 'repository/auth_repository.dart';
import 'repository/mission_repository.dart';
import 'repository/user_repository.dart';
import 'data/session/session_manager.dart';
import 'domain/service/auth_service.dart';
import 'domain/service/currency_service.dart';
import 'domain/service/mission_service.dart';
import 'domain/service/reminder_service.dart';
import 'domain/service/shop_service.dart';
import 'domain/service/sync_service.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/nav_bar.dart';
import 'ui/theme/app_theme.dart';

// Plugin for local notifications
final FlutterLocalNotificationsPlugin notificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI database only on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize notifications and request permissions
  await _initNotifications();

  // Initialize database
  final databaseProvider = DatabaseProvider.instance;
  final appDatabase = await databaseProvider.getDatabase();

  // Initialize DAOs
  final userDao = appDatabase.userDao;
  final missionDao = appDatabase.missionDao;
  final subTaskDao = appDatabase.subTaskDao;
  final shopDao = appDatabase.shopDao;
  final ownedCosmeticDao = appDatabase.ownedCosmeticDao;

  // Initialize repositories
  final authRepository = AuthRepository(userDao);
  final missionRepository = MissionRepository(
    missionDao: missionDao,
    subTaskDao: subTaskDao,
  );
  final userRepository = UserRepository(
    userDao: userDao,
    ownedCosmeticDao: ownedCosmeticDao,
    missionDao: missionDao,
  );

  // Initialize services
  final sessionManager = SessionManager();
  final themePreferences = ThemePreferences();
  final currencyService = CurrencyService(
    userRepository: userRepository,
    sessionManager: sessionManager,
  );
  final reminderService = ReminderService(notificationsPlugin);
  await reminderService.init();

  final syncService = SyncService(
    userRepository: userRepository,
    missionRepository: missionRepository,
  );

  final shopService = ShopService(
    userRepository: userRepository,
    shopDao: shopDao,
    ownedDao: ownedCosmeticDao,
    sessionManager: sessionManager,
  );

  final authService = AuthService(
    sessionManager: sessionManager,
    authRepository: authRepository,
    userRepository: userRepository,
    syncService: syncService,
  );

  final missionService = MissionService(
    missionRepository: missionRepository,
    userRepository: userRepository,
    currencyService: currencyService,
    sessionManager: sessionManager,
    reminderService: reminderService,
    syncService: syncService,
  );

  // Initialize shop with complete forced refresh
  await _initShop(shopDao);

  // Load saved theme and set it on Notifier
  final savedTheme = await themePreferences.getTheme();
  ThemeManager.setTheme(savedTheme);

  runApp(
    QuesterApp(
      authService: authService,
      missionService: missionService,
      shopService: shopService,
      sessionManager: sessionManager,
      missionRepository: missionRepository,
      userRepository: userRepository,
      shopDao: shopDao,
      reminderService: reminderService,
    ),
  );
}

/// Initialize local notifications and request system permissions (Android 13+ / iOS)
Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/launcher_icon');

  const DarwinInitializationSettings iosSettings =
  DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(initSettings);

  // Explicit permission request for notifications (essential for Android 13+)
  if (Platform.isAndroid) {
    final androidImplementation =
    notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  } else if (Platform.isIOS) {
    final iosImplementation =
    notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

/// Initialize or update shop items forcing correct data and clearing old artifacts
Future<void> _initShop(dynamic shopDao) async {
  // Legacy ID migration -> Canonical IDs
  await shopDao.db.delete(
    'shop_items',
    where: 'itemId = ?',
    whereArgs: ['elmo_cavaliere'],
  );
  await shopDao.db.delete(
    'owned_cosmetics',
    where:
    "itemId = ? AND EXISTS (SELECT 1 FROM owned_cosmetics o2 WHERE o2.userId = owned_cosmetics.userId AND o2.itemId = ?)",
    whereArgs: ['elmo_cavaliere', 'hat_cavaliere'],
  );
  await shopDao.db.update(
    'owned_cosmetics',
    {'itemId': 'hat_cavaliere'},
    where: 'itemId = ?',
    whereArgs: ['elmo_cavaliere'],
  );

  // Pulisci completamente la tabella shop_items per assicurarsi che non rimangano filtri o disallineamenti
  await shopDao.deleteAllItems();

  await shopDao.upsertItems([
    ShopItem(
      itemId: 'frame_mago',
      name: 'Cornice del Mago',
      price: 30,
      description: 'Cornice con rune magiche e stelle cadenti',
      iconName: 'ic_frame_mago',
    ),
    ShopItem(
      itemId: 'frame_cavaliere',
      name: 'Cornice del Cavaliere',
      price: 30,
      description: 'Cornice con spade incrociate e scudi',
      iconName: 'ic_frame_cavaliere',
    ),
    ShopItem(
      itemId: 'frame_scifi',
      name: 'Cornice Sci-Fi',
      price: 30,
      description: 'Cornice con circuiti luminosi e neon',
      iconName: 'ic_frame_scifi',
    ),
    ShopItem(
      itemId: 'hat_mago',
      name: 'Cappello del Mago',
      price: 100,
      description: 'Cappello a punta con stelle magiche',
      iconName: 'ic_char_wizard',
    ),
    ShopItem(
      itemId: 'staff_mago',
      name: 'Bastone del Mago',
      price: 100,
      description: 'Bastone con gemma magica incantata',
      iconName: 'ic_char_weapon_staff',
    ),
    ShopItem(
      itemId: 'gun_spaziale',
      name: 'Space Pistol',
      price: 100,
      description: 'High-tech laser pistol',
      iconName: 'ic_gun_spaziale',
    ),
    ShopItem(
      itemId: 'sword_cavaliere',
      name: 'Spada del Cavaliere',
      price: 100,
      description: 'Spada luminosa forgiata nell\'acciaio',
      iconName: 'ic_char_weapon_blade',
    ),
    ShopItem(
      itemId: 'hat_cavaliere',
      name: 'Elmo del Cavaliere',
      price: 100,
      description: 'Elmo con visiera protettiva',
      iconName: 'ic_char_helm',
    ),
    ShopItem(
      itemId: 'visor_futuristico',
      name: 'Visore Futuristico',
      price: 100,
      description: 'Visore high-tech con HUD integrato',
      iconName: 'ic_visor_futuristico',
    ),
    ShopItem(
      itemId: 'theme_arcade',
      name: 'Tema Arcade',
      price: 500,
      description: 'Stile retrò con colori neon e pixel art',
      iconName: 'ic_theme_arcade',
    ),
    ShopItem(
      itemId: 'theme_fantasy',
      name: 'Tema Bacheca Fantasy',
      price: 500,
      description: 'Stile pergamena antica e rune magiche',
      iconName: 'ic_dragon',
    ),
    ShopItem(
      itemId: 'reward_corona',
      name: 'Corona dell\'Eroe',
      price: 0,
      description: 'Riservata ai veri Campioni!',
      iconName: 'ic_crown',
    ),
    ShopItem(
      itemId: 'reward_tema_regale',
      name: 'Tema Regale',
      price: 0,
      description: 'Tema esclusivo per i Re di Quester',
      iconName: 'ic_throne',
    ),
  ]);
}

/// Widget to manage the dynamic Arcade background (pixelated image)
class ArcadeBackground extends StatelessWidget {
  final Widget child;

  const ArcadeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;

    if (!isArcade) {
      return child;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg_arcade_pixel.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFF100323)),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.35)),
        ),
        child,
      ],
    );
  }
}

/// Main app widget
class QuesterApp extends StatefulWidget {
  final AuthService authService;
  final MissionService missionService;
  final ShopService shopService;
  final SessionManager sessionManager;
  final MissionRepository missionRepository;
  final UserRepository userRepository;
  final dynamic shopDao;
  final ReminderService reminderService;

  const QuesterApp({
    super.key,
    required this.authService,
    required this.missionService,
    required this.shopService,
    required this.sessionManager,
    required this.missionRepository,
    required this.userRepository,
    required this.shopDao,
    required this.reminderService,
  });

  @override
  State<QuesterApp> createState() => _QuesterAppState();
}

class _QuesterAppState extends State<QuesterApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  int _currentIndex = 1; // Maintains active tab state on theme change

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Verify if user is logged in and handle synchronization
  Future<void> _checkSession() async {
    final loggedIn = await widget.sessionManager.isLoggedIn();

    if (loggedIn) {
      try {
        final userId = await widget.sessionManager.loggedUserId();
        if (userId != null) {
          final syncService = SyncService(
            userRepository: widget.userRepository,
            missionRepository: widget.missionRepository,
          );

          await syncService.performFullSync(userId);

          final missions = await widget.missionRepository.getAllMissionsForUser(userId);
          final activeCount = missions.where((m) => !m.completed).length;

          await widget.reminderService.scheduleDailySummaryReminder(
            activeMissionsCount: activeCount,
          );
        }
      } catch (e) {
        debugPrint("ERROR: Auto-sync during checkSession failed -> $e");
      }
    }

    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: FantasyBackground,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icona connessione
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FantasyGold.withOpacity(0.08),
                    border: Border.all(
                      color: FantasyGold.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    size: 45,
                    color: FantasyGold,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Connessione in corso',
                  style: TextStyle(
                    color: FantasyText,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Connessione al database...',
                  style: TextStyle(
                    color: FantasyTextSecondary.withOpacity(0.75),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: FantasyGold,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Attendi qualche istante',
                  style: TextStyle(
                    color: FantasyTextSecondary.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }



    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'Quester',
          debugShowCheckedModeBanner: false,
          theme: QuesterTheme.getThemeData(
            themeType: currentTheme,
            darkTheme: true,
          ),
          home: ArcadeBackground(
            child: _isLoggedIn
                ? NavBar(
              services: NavServices(
                missionService: widget.missionService,
                authService: widget.authService,
                shopService: widget.shopService,
              ),
              repositories: NavRepositories(
                missionRepository: widget.missionRepository,
                userRepository: widget.userRepository,
                shopDao: widget.shopDao,
              ),
              sessionManager: widget.sessionManager,
              onLogout: () {
                setState(() => _isLoggedIn = false);
              },
              currentIndex: _currentIndex,
              onTabChanged: (index) {
                setState(() => _currentIndex = index);
              },
            )
                : AuthScreen(
              authService: widget.authService,
              onAuthSuccess: () {
                setState(() => _isLoggedIn = true);
              },
            ),
          ),
        );
      },
    );
  }
}