import 'package:booking_app/screens/forgot_password_screen.dart';
import 'package:booking_app/screens/terms_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(">>> FlutterError: ${details.exception}");
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng giao hàng Út Ngân',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: false,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      // Chỉ giữ lại các route thật sự cần dùng pushNamed
      onGenerateRoute: (settings) {
        final routes = <String, Widget Function(BuildContext, Object?)>{
          '/': (context, _) => AuthScreen(),
          '/forgot_password': (context, _) => const ForgotPasswordScreen(),
          '/terms': (context, _) => TermsScreen(),
          '/edit_profile': (context, args) {
            final username = args as String?;
            if (username == null) {
              return const Scaffold(
                body: Center(child: Text('Không tìm thấy thông tin')),
              );
            }
            return EditProfileScreen(username: username);
          },
          '/change_password': (context, args) {
            final username = args as String?;
            if (username == null) {
              return const Scaffold(
                body: Center(child: Text('Không tìm thấy thông tin')),
              );
            }
            return ChangePasswordScreen(username: username);
          },
        };

        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: (context) => builder(context, settings.arguments),
          );
        }

        // Trang mặc định khi không tìm thấy route
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Không tìm thấy trang.')),
          ),
        );
      },
    );
  }
}
