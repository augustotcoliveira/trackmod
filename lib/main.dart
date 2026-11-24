import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart'; // gerado pelo "flutterfire configure"
import 'logic/manage_auth/auth_bloc.dart';
import 'logic/manage_garagem/manage_garagem_bloc.dart';
import 'logic/monitor_garagem/monitor_garagem_bloc.dart';
import 'view/screens/main_navigation.dart';
import 'view/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TrackModApp());
}

class TrackModApp extends StatelessWidget {
  const TrackModApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Os BLoCs ficam acima do MaterialApp para que TODAS as rotas
    // (inclusive as abertas com Navigator.push) consigam acessá-los.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => MonitorGaragemBloc()),
        BlocProvider(create: (_) => ManageGaragemBloc()),
      ],
      child: MaterialApp(
        title: 'TrackMod',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.tema,
        // Deixa DatePicker e textos padrão do Material em português
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainNavigation(),
      ),
    );
  }
}
