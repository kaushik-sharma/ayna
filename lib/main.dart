import 'package:ayna/core/constants/theme.dart';
import 'package:ayna/router/router_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../di.dart' as di;
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/home/presentation/blocs/home_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>('auth_box');
  await Hive.openBox<Map<String, dynamic>>('messages_box');

  di.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // if (FirebaseAuth.instance.currentUser != null) {
  //   await FirebaseAuth.instance.currentUser!.reload();
  //   final authToken = await FirebaseAuth.instance.currentUser!.getIdToken(true);
  //   if (authToken == null) {
  //
  //   } else {
  //     AuthLocalDatasource().saveAuthToken(authToken);
  //   }
  // }

  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1200),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<AuthBloc>()),
          BlocProvider(create: (context) => di.sl<HomeBloc>()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          scaffoldMessengerKey: kScaffoldMessengerKey,
          theme: kTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
