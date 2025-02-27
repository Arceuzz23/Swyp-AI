import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swyp_ai/constants/constants.dart';
import 'package:swyp_ai/core/network/api_client.dart';
import 'package:swyp_ai/core/providers/api_providers.dart';
import 'package:swyp_ai/screens/splashScreen.dart';
import 'package:swyp_ai/core/network/auth_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/router.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: CustomTheme.theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
