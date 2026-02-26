import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'controllers/auth/auth_bloc.dart';
import 'controllers/auth/auth_state.dart';
import 'controllers/product/product_bloc.dart';
import 'controllers/profile/profile_bloc.dart';
import 'controllers/profile/profile_event.dart';
import 'repositories/auth_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/user_repository.dart';
import 'services/api_service.dart';
import 'views/home/home_view.dart';
import 'views/login/login_view.dart';
import 'views/profile/profile_view.dart';

class DarazApp extends StatefulWidget {
  const DarazApp({super.key});

  @override
  State<DarazApp> createState() => _DarazAppState();
}

class _DarazAppState extends State<DarazApp> {
  late final ApiService _apiService;
  late final AuthRepository _authRepository;
  late final ProductRepository _productRepository;
  late final UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authRepository = AuthRepository(apiService: _apiService);
    _productRepository = ProductRepository(apiService: _apiService);
    _userRepository = UserRepository(apiService: _apiService);
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //======================> Provide all BLoC controllers at the app level so they're accessible from any route. <===========
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: _authRepository)),
        BlocProvider(
          create: (_) => ProductBloc(productRepository: _productRepository),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(userRepository: _userRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Daraz Scroll Architecture',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF85606)),
          useMaterial3: true,
        ),
        //=========================> Auth-aware root: shows LoginView or HomeView based on auth state. <==========================
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomeView();
            }
            return const LoginView();
          },
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/profile':
              return MaterialPageRoute(
                builder: (context) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<ProfileBloc>().add(
                      ProfileLoadRequested(userId: authState.userId),
                    );
                  }
                  return const ProfileView();
                },
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
