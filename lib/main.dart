import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telekonsul/provider/diagnosis_provider.dart';
import 'package:telekonsul/provider/transaction_provider.dart';
import 'page/pages.dart';
import 'provider/consultation_schedule_provider.dart';
import 'provider/patient_provider.dart';
import 'provider/queue_provider.dart';
import 'provider/doctor_provider.dart';
import 'provider/user_provider.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before using any firebase services, we need to initiate the firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Wrap the root widget with MultiProvider
    // So, we can use all the provider below the tree widget
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider to initiate 1 Provider
        ChangeNotifierProvider(
          create: (context) => DoctorProvider(),
        ),

        // ChangeNotifierProxyProvider can be used if you need other Provider within Provider
        // With update we can set the Provider we need inside the class Provider we using
        // We need DoctorProvider inside UserProvider to check whether the user login as Doctor or Patient
        ChangeNotifierProxyProvider<DoctorProvider, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, value, previous) => previous!..update = value,
        ),
        ChangeNotifierProvider(
          create: (context) => ConsultationScheduleProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => QueueProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PatientProvider(),
        ),
        ChangeNotifierProxyProvider<PatientProvider, TransactionProvider>(
          create: (context) => TransactionProvider(),
          update: (context, value, previous) => previous!..updatePatientProvider = value,
        ),
        ChangeNotifierProvider(
          create: (context) => DiagnosisProvider(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const LandingPage(),
          },
          theme: AppTheme.themeData,
          builder: (context, child) {
            // To consume Provider we need to use Consumer Widget
            // We using UserProvider to check wheter user already login or haven't login yet
            return Consumer<UserProvider>(
              child: child,
              builder: (context, value, child) {
                if (value.isLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // If the user login as patient, they will redirected to User page
                // We need to wrap it inside MaterialApp, because we need a Navigator
                // Which already included inside MaterialApp
                // If we don't have the Navigator, we won't able to navigate through app / screen
                if (value.user != null) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.themeData,
                    home: const BottomNavigationBarUserScreen(),
                  );
                }

                // So here we using the DoctorProvider that already been updated, so the value won't be null
                // We checking wheter the user login as Doctor, if so then it will be redirected to Doctor page
                if (value.doctorProvider!.doctor != null) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.themeData,
                    home: const BottomNavigationBarDoctor(),
                  );
                }

                // Child is our initialroute widget that already been set at MaterialApp above
                // Which is '/': (context) => SplashPage(), So if the user hasn't login yet
                // They will go to SplashPage() (child)
                return child!;
              },
            );
          },
        );
      },
    );
  }
}
