// lib/main.dart

import 'dart:io' show Platform;

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
import 'ui/screens/auth_screen.dart';
import 'ui/screens/nav_bar.dart';
import 'ui/theme/app_theme.dart';

// Plugin per le notifiche locali
final FlutterLocalNotificationsPlugin notificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il database FFI solo su desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inizializza le notifiche e richiedi i permessi
  await _initNotifications();

  // Inizializza il database
  final databaseProvider = DatabaseProvider.instance;
  final appDatabase = await databaseProvider.getDatabase();

  // Inizializza i DAO
  final userDao = appDatabase.userDao;
  final missionDao = appDatabase.missionDao;
  final subTaskDao = appDatabase.subTaskDao;
  final shopDao = appDatabase.shopDao;
  final ownedCosmeticDao = appDatabase.ownedCosmeticDao;

  // Inizializza i repository
  final authRepository = AuthRepository(userDao);
  final missionRepository = MissionRepository(
    missionDao: missionDao,
    subTaskDao: subTaskDao,
  );
  final userRepository = UserRepository(
    userDao: userDao,
    ownedCosmeticDao: ownedCosmeticDao,
  );

  // Inizializza i service
  final sessionManager = SessionManager();
  final themePreferences = ThemePreferences();
  final currencyService = CurrencyService(
    userRepository: userRepository,
    sessionManager: sessionManager,
  );
  final authService = AuthService(
    sessionManager: sessionManager,
    authRepository: authRepository,
    userRepository: userRepository,
  );
  final shopService = ShopService(
    userRepository: userRepository,
    shopDao: shopDao,
    ownedDao: ownedCosmeticDao,
    sessionManager: sessionManager,
  );
  final reminderService = ReminderService(notificationsPlugin);

  final missionService = MissionService(
    missionRepository: missionRepository,
    userRepository: userRepository,
    currencyService: currencyService,
    sessionManager: sessionManager,
    reminderService: reminderService,
  );

  // Inizializza lo shop con gli oggetti predefiniti solo se vuoto
  await _initShop(shopDao);

  // Carica il tema salvato e impostalo sul Notifier
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
    ),
  );
}

/// Inizializza le notifiche locali e richiede i permessi di sistema (Android 13+ / iOS)
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

  // Richiesta esplicita dei permessi di notifica (fondamentale per Android 13+)
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

/// Inizializza o aggiorna gli oggetti dello shop forzando i dati corretti
Future<void> _initShop(dynamic shopDao) async {
  // Migrazione ID legacy -> ID canonici
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

  await shopDao.upsertItems([
    ShopItem(
      itemId: 'frame_mago',
      name: 'Cornice del Mago',
      price: 30,
      description: 'Cornice con rune magiche e stelle cadenti',
      iconName: 'shopping_cart',
    ),
    ShopItem(
      itemId: 'frame_cavaliere',
      name: 'Cornice del Cavaliere',
      price: 30,
      description: 'Cornice con spade incrociate e scudi',
      iconName: 'shopping_cart',
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
      iconName: 'shopping_cart',
    ),
    ShopItem(
      itemId: 'staff_mago',
      name: 'Bastone del Mago',
      price: 100,
      description: 'Bastone con gemma magica incantata',
      iconName: 'shopping_cart',
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
      iconName: 'shopping_cart',
    ),
    ShopItem(
      itemId: 'hat_cavaliere',
      name: 'Elmo del Cavaliere',
      price: 100,
      description: 'Elmo con visiera protettiva',
      iconName: 'shopping_cart',
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
      iconName: 'shopping_cart',
    ),
    ShopItem(
      itemId: 'reward_corona',
      name: '👑 Corona dell\'Eroe',
      price: 0,
      description: '★ Riservata ai veri Campioni! ★',
      iconName: 'shopping_cart',
    ),
    ShopItem(
      itemId: 'reward_tema_regale',
      name: '✦ Tema Regale',
      price: 0,
      description: '✦ Tema esclusivo per i Re di Quester',
      iconName: 'shopping_cart',
    ),
  ]);
}

/// Widget per gestire lo sfondo dinamico Arcade (immagine pixelata)
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

/// Widget principale dell'app
class QuesterApp extends StatefulWidget {
  final AuthService authService;
  final MissionService missionService;
  final ShopService shopService;
  final SessionManager sessionManager;
  final MissionRepository missionRepository;
  final UserRepository userRepository;
  final dynamic shopDao;

  const QuesterApp({
    super.key,
    required this.authService,
    required this.missionService,
    required this.shopService,
    required this.sessionManager,
    required this.missionRepository,
    required this.userRepository,
    required this.shopDao,
  });

  @override
  State<QuesterApp> createState() => _QuesterAppState();
}

class _QuesterAppState extends State<QuesterApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  int _currentIndex = 1; // Mantiene lo stato del tab attivo anche al cambio tema

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Verifica se l'utente è già loggato
  Future<void> _checkSession() async {
    final loggedIn = await widget.sessionManager.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(body: const Center(child: CircularProgressIndicator())),
      );
    }

    // Ascolta i cambiamenti di ThemeManager in tempo reale
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
          // Avvolgiamo la home con ArcadeBackground per mostrare l'immagine in modalità Arcade
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
              currentIndex: _currentIndex, // Passiamo l'indice persistente
              onTabChanged: (index) {
                setState(() => _currentIndex = index); // Aggiorna l'indice quando navighi
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