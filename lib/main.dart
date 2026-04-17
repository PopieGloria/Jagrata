import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart';
import 'add_incident_page.dart';
import 'profile_page.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'admin_login_page.dart';
import 'admin_department_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global service to manage Firebase initialization
class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Track initialization state
  bool _initialized = false;
  String _error = '';

  bool get isInitialized => _initialized;
  String get error => _error;

  // Initialize Firebase only once
  Future<void> initialize() async {
    // Skip if already initialized
    if (_initialized) return;

    try {
      // First, check if there's an existing app and use it
      if (Firebase.apps.isNotEmpty) {
        print('Using existing Firebase app: ${Firebase.apps[0].name}');
        _initialized = true;
        _error = '';
        return;
      }

      // If no app exists, initialize a new one
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Configure Firestore
      if (!kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } else {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }

      // Configure Auth persistence
      if (!kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      } else {
        await FirebaseAuth.instance.setPersistence(Persistence.INDEXED_DB);
      }

      _initialized = true;
      _error = '';
    } catch (e) {
      _error = e.toString();
      print('Firebase initialization error: $_error');
      
      // Even if there's an error, try to continue with an existing app if available
      if (Firebase.apps.isNotEmpty) {
        print('Continuing with existing Firebase app despite error');
        _initialized = true;
        _error = '';
      } else {
        _initialized = false;
      }
    }
  }
}

// Change from private to public for external access
bool globalProfileComplete = false;

// Update to use shared preferences to persist profile completion status
Future<void> updateProfileCompletionStatus(bool isComplete) async {
  globalProfileComplete = isComplete;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_complete', isComplete);
    print('Profile completion status saved to prefs: $isComplete');
  } catch (e) {
    print('Failed to save profile status to prefs: $e');
  }
}

// Method to load profile completion status from shared preferences
Future<bool> getProfileCompletionStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isComplete = prefs.getBool('profile_complete') ?? false;
    globalProfileComplete = isComplete;
    print('Profile completion status loaded from prefs: $isComplete');
    return isComplete;
  } catch (e) {
    print('Failed to load profile status from prefs: $e');
    return false;
  }
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load profile completion status early, so it's available before UI builds
  try {
    final prefs = await SharedPreferences.getInstance();
    globalProfileComplete = prefs.getBool('profile_complete') ?? false;
    print('Early profile status load: $globalProfileComplete');
  } catch (e) {
    print('Failed to load early profile status: $e');
  }
  
  // Enable smooth scrolling and high refresh rates for all platforms
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      // Enable edge-to-edge mode and optimize for high refresh rate displays
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
      
      // Hint to the OS that this app prefers high refresh rate
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChannels.platform.invokeMethod('SystemChrome.setSystemUIChangeCallback');
    } else if (Platform.isIOS) {
      // iOS-specific high refresh rate and smooth animation settings
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ));
    }
  }
  
  // Run with error handling
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  
  @override
  void initState() {
    super.initState();
    // Start initialization after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Update status
      setState(() {
        _statusMessage = 'Initializing Firebase...';
      });
      
      // Initialize Firebase through the service
      await _firebaseService.initialize();
      
      if (_firebaseService.isInitialized) {
        // Load profile status from shared preferences
        setState(() {
          _statusMessage = 'Loading user data...';
        });
        
        // Ensure profile status is loaded from prefs
        await getProfileCompletionStatus();
        print('Profile status loaded in splash screen: $globalProfileComplete');
        
        // If initialization succeeded, navigate to actual app
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MyApp()),
          );
        }
      } else {
        // If initialization failed, show error dialog
        _showErrorDialog(_firebaseService.error);
      }
    } catch (e) {
      print('Error in _initializeApp: $e');
      _showErrorDialog(e.toString());
    }
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Initialization Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to initialize the application.'),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Try to continue without full initialization
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => MyApp()),
              );
            },
            child: Text('Try Anyway'),
          ),
          TextButton(
            onPressed: () {
              // Exit the app
              SystemNavigator.pop();
            },
            child: Text('Close App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jagrata',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jagrata',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'GoogleSans', // Set as default font for entire app
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'GoogleSans'),
          displayMedium: TextStyle(fontFamily: 'GoogleSans'),
          displaySmall: TextStyle(fontFamily: 'GoogleSans'),
          headlineLarge: TextStyle(fontFamily: 'GoogleSans'),
          headlineMedium: TextStyle(fontFamily: 'GoogleSans'),
          headlineSmall: TextStyle(fontFamily: 'GoogleSans'),
          titleLarge: TextStyle(fontFamily: 'GoogleSans'),
          titleMedium: TextStyle(fontFamily: 'GoogleSans'),
          titleSmall: TextStyle(fontFamily: 'GoogleSans'),
          bodyLarge: TextStyle(fontFamily: 'GoogleSans'),
          bodyMedium: TextStyle(fontFamily: 'GoogleSans'),
          bodySmall: TextStyle(fontFamily: 'GoogleSans'),
          labelLarge: TextStyle(fontFamily: 'GoogleSans'),
          labelMedium: TextStyle(fontFamily: 'GoogleSans'),
          labelSmall: TextStyle(fontFamily: 'GoogleSans'),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        // Add smoother animation settings
        splashFactory: InkRipple.splashFactory,
        useMaterial3: true, // Use Material 3 design for smoother components
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          // Add explicit dropdown styling for smoother appearance
          menuStyle: MenuStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.white),
            elevation: MaterialStatePropertyAll(8.0),
            surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
            shadowColor: MaterialStatePropertyAll(Colors.black12),
          ),
        ),
        platform: TargetPlatform.android,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/admin_login': (context) => AdminDepartmentSelectionPage(),
        '/main': (context) => MainScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any routes that aren't defined in the routes map
        return MaterialPageRoute(
          builder: (context) => AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get arguments from route if available
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final initialTab = args?['initialTab'] as int?;
    
    print("AuthWrapper received initialTab: $initialTab");
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Add more detailed handling of connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Authenticating...'),
                ],
              ),
            ),
          );
        }
        
        // Handle error state
        if (snapshot.hasError) {
          print('Auth state error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 16),
                  Text('Authentication error'),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => WelcomePage())
                    ),
                    child: Text('Go to Welcome Page'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // If authenticated, go to MainScreen with initial tab if provided
        if (snapshot.hasData) {
          print('Auth state changed: ${snapshot.data?.uid}');
          // Pass initialTab to MainScreen if specified
          return MainScreen(initialTab: initialTab);
        }
        
        // Not authenticated, go to WelcomePage
        return WelcomePage();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int? initialTab;
  const MainScreen({Key? key, this.initialTab}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  bool _isProfileComplete = false; // Track profile completion status
  bool _isLoading = false;
  
  // Initialize _pages with an empty list to avoid null check errors
  static List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    print('=== MAIN SCREEN INIT ===');
    
    // Set the initial index before checking profile completion
    _selectedIndex = widget.initialTab ?? 0;
    print('MainScreen initialized with tab: $_selectedIndex');
    
    // First check if global status is true (from shared prefs)
    if (globalProfileComplete) {
      print('Using cached profile completion status: $globalProfileComplete');
      setState(() {
        _isProfileComplete = true;
        _isLoading = false;
      });
      // Initialize pages with profile complete state
      _refreshPages();
    } else {
      // Otherwise initialize pages with empty state and check DB
      _refreshPages();
      _checkProfileCompletion();
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle updates to the widget, including changes to initialTab
    if (widget.initialTab != null && widget.initialTab != _selectedIndex) {
      print('MainScreen updated with new initialTab: ${widget.initialTab}');
      setState(() {
        _selectedIndex = widget.initialTab!;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload profile status when dependencies change (e.g., after navigation)
    _reloadProfileStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Make sure pages are initialized
    if (_pages.isEmpty) {
      _refreshPages();
    }

    return Scaffold(
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your profile...')
              ],
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              // Handle back button press - prevent accidental app exit
              if (_selectedIndex != 0) {
                // If not on home tab, go to home tab
                setState(() {
                  _selectedIndex = 0;
                });
                return false;
              }
              return true; // Allow exit on home tab
            },
            child: IndexedStack(
        index: _selectedIndex,
        children: _pages,
            ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade300,
        onTap: _handleTabSelection,
      ),
    );
  }

  // Add method to force reload profile status
  Future<void> _reloadProfileStatus() async {
    print("Force reloading profile status from shared preferences");
    
    try {
      // Get fresh status from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isComplete = prefs.getBool('profile_complete') ?? false;
      
      // Log the status
      print('SharedPreferences profile status: $isComplete');
      
      // If status is true, immediately update UI
      if (isComplete && !_isProfileComplete) {
        setState(() {
          _isProfileComplete = true;
          print('Profile status updated to COMPLETE');
        });
        _refreshPages();
      } else if (!isComplete) {
        // Only check database if SharedPreferences says incomplete
    _checkProfileCompletion();
      }
    } catch (e) {
      print('Error reloading profile status: $e');
    }
  }

  // Extracted tab selection logic for clarity
  void _handleTabSelection(int index) async {
    // Skip if loading
    if (_isLoading) return;
    
    // Refresh profile status before processing tab selection
    try {
      final prefs = await SharedPreferences.getInstance();
      final isComplete = prefs.getBool('profile_complete') ?? false;
      // Use the most recent status
      globalProfileComplete = isComplete;
      if (isComplete != _isProfileComplete) {
        setState(() {
          _isProfileComplete = isComplete;
          print("Profile status updated during tab selection: $_isProfileComplete");
        });
      }
    } catch (e) {
      print('Error updating profile status: $e');
    }
    
    print('Tab tapped: $index. Current profile complete: $_isProfileComplete');
    
    // For the Report tab, check profile status only if not complete
    if (index == 1) {
      if (!_isProfileComplete) {
        print('Redirecting to profile tab because profile is incomplete');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your profile before submitting a report.'),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate to profile tab
        navigateToProfileTab();
        return;
      }
      
      // Profile is complete, open AddIncidentPage modal
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddIncidentPage(
            isProfileComplete: _isProfileComplete, // This should be true here
            onRequestProfileTab: navigateToProfileTab,
          ),
        ),
      );
      
      // After return, refresh profile status
      _reloadProfileStatus();
      
      // Handle any return result from the page
      if (result is Map && result['goToProfile'] == true) {
        print('Received goToProfile result from AddIncidentPage');
        navigateToProfileTab();
      }
    } else {
      // Normal tab selection for Home and Profile
      setState(() {
        _selectedIndex = index;
        print('Updated selected index to: $index');
      });
    }
  }

  Future<void> _checkProfileCompletion() async {
    print('--- CHECKING PROFILE COMPLETION ---');
    setState(() => _isLoading = true);
    
    try {
      // First check shared preferences for a cached value
      final cachedComplete = await getProfileCompletionStatus();
      if (cachedComplete) {
        print('Found cached profile status: COMPLETE');
        setState(() {
          _isProfileComplete = true;
          _isLoading = false;
        });
        _refreshPages();
        return;
      }

      // Check if user's profile is complete in database
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Checking profile completion for user: ${user.uid}');
        
        // Get the latest user data
        final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
        if (!userData.exists) {
          print('User document does not exist');
          if (mounted) {
            // Create a basic user profile
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'email': user.email,
                  'createdAt': FieldValue.serverTimestamp(),
                  'isProfileComplete': false,
                });
            
            // Update state
            setState(() {
              _isProfileComplete = false;
              _isLoading = false;
            });
            // Persist status to shared preferences
            await updateProfileCompletionStatus(false);
            
            // Update UI
            _refreshPages();
            return;
          }
        }

        final data = userData.data() ?? {};
        
        // Debug log all profile data
        print('USER PROFILE DATA:');
        data.forEach((key, value) {
          print('$key: $value');
        });
        
        // Check if isProfileComplete flag exists and is true
        final bool isComplete = data['isProfileComplete'] == true;
        print('isProfileComplete flag = $isComplete');
        
        // Also check if all required fields are filled
        final bool hasAllFields = 
            data['name'] != null && data['name'].toString().isNotEmpty &&
            data['phone'] != null && data['phone'].toString().isNotEmpty &&
            data['govtId'] != null && data['govtId'].toString().isNotEmpty &&
            data['country'] != null && data['country'].toString().isNotEmpty &&
            data['gender'] != null && data['gender'].toString().isNotEmpty;
        
        print('Profile has all required fields: $hasAllFields');
        
        // If all fields exist but flag is not set, update it
        if (hasAllFields && !isComplete) {
          print('FIXING: Profile has all fields but flag is not set. Updating flag to true.');
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'isProfileComplete': true});
                
            print('Successfully updated profile completion flag to true');
            
            // Update the global shared preference flag
            await updateProfileCompletionStatus(true);
            
            if (mounted) {
              setState(() {
                _isProfileComplete = true;
                _isLoading = false;
              });
              
              _refreshPages();
              return;
            }
          } catch (updateError) {
            print('Error updating profile completion flag: $updateError');
          }
        }
        
        // Use either the flag or field check (prioritize flag)
        final finalCompletionStatus = isComplete || hasAllFields;
        print('Final decision - profile is complete: $finalCompletionStatus');
        
        // Update global status
        await updateProfileCompletionStatus(finalCompletionStatus);
        
        if (mounted) {
          setState(() {
            _isProfileComplete = finalCompletionStatus;
            _isLoading = false;
          });
          
          // Refresh pages to reflect the current state
          _refreshPages();
        }
      } else {
        print('No user logged in');
        if (mounted) {
          setState(() {
            _isProfileComplete = false;
            _isLoading = false;
          });
          await updateProfileCompletionStatus(false);
        }
      }
    } catch (e) {
      print('Error checking profile completion: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Direct navigation to profile tab without delays or loading states
  void navigateToProfileTab() {
    print('Direct navigation to profile tab using synchronous approach');
    
    // Ensure proper mounting before updating state
    if (!mounted) return;
    
    // Force rebuild with profile tab selected
    setState(() {
      // Show the profile tab immediately
      _selectedIndex = 2;
      // No loading state - simpler and more reliable
      print('Selected tab set directly to profile (index 2)');
    });
  }

  // New method to refresh pages with current state
  void _refreshPages() {
    print('Refreshing pages. Profile complete: $_isProfileComplete, Selected index: $_selectedIndex');
    
    // Create new instance of pages
    _pages = <Widget>[
      HomePage(),
      // For Report tab, we'll use a placeholder that shows instructions
      // since we're handling this tab with a modal now
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 24),
            Text(
              'Report an Incident',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Tap this tab to submit a report about corruption or misconduct.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
      ProfilePage(
        onProfileUpdated: () {
          print('onProfileUpdated callback triggered in MainScreen');
          if (mounted) {
            // Force check profile status from database again
            _checkProfileCompletionAfterUpdate();
          }
        },
      ),
    ];
  }
  
  // Special method to check profile completion after an update
  Future<void> _checkProfileCompletionAfterUpdate() async {
    print('--- CHECKING PROFILE AFTER UPDATE ---');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Fetch latest profile data
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (!userData.exists) return;
      
      final data = userData.data() ?? {};
      final bool isComplete = data['isProfileComplete'] == true;
      
      print('Profile updated - isProfileComplete flag = $isComplete');
      
      // Update global status immediately
      await updateProfileCompletionStatus(isComplete);
      
      if (mounted) {
        setState(() {
          _isProfileComplete = isComplete;
          print('MainScreen state updated: isProfileComplete = $isComplete');
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! You can now report incidents.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh pages
        _refreshPages();
      }
    } catch (e) {
      print('Error checking profile after update: $e');
    }
  }

  Future<void> checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user is an admin
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      
      if (adminDoc.exists) {
        // Skip profile completion for admins
        return;
      }

      // Get cached profile status first
      final cachedStatus = await getProfileCompletionStatus();
      if (cachedStatus) {
        print('Using cached profile status: complete');
        return;
      }

      // Only check database if cache didn't have a positive result
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final isProfileComplete = userData['isProfileComplete'] ?? false;

        // Update shared preferences for next time
        await updateProfileCompletionStatus(isProfileComplete);
        
        // We don't force navigation here anymore
        // Just update the status in memory
          return;
      }
    }
  }
}

// Add this custom page transition builder
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
