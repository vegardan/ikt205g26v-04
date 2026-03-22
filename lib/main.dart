import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/pages/home.dart';
import 'package:ikt205g26v_04/pages/signup.dart';
import 'package:ikt205g26v_04/utils/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: 'https://ilhbnupaodivrudwwnue.supabase.co', anonKey: 'sb_publishable_z20yHRWTH76-PD2XX8sYsg_Gxld3WmA');

  await NotificationService.instance.init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloudNotes',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: Supabase.instance.client.auth.currentSession == null ? SignupPage() : HomePage(),
    );
  }
}
