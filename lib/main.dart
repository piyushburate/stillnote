import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/firebase_options.dart';
import 'package:stillnote/global_cubits/auth_cubit/auth_cubit.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_router.dart';
import 'package:stillnote/utils/x_themes.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Updates URL on using push() method
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setPathUrlStrategy();
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    FlutterNativeSplash.remove();
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set Navigation and Status Bar Theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      XThemesManager.setSystemUIOverlayStyle(context);
    });
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: XConsts.appName,
        debugShowCheckedModeBanner: false,
        theme: XThemes.appTheme,
        darkTheme: XDarkThemes.appTheme,
        themeMode: XThemesManager.themeMode,
        routerConfig: XRouter.router,
      ),
    );
  }
}
