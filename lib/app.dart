import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'feature/data/sources/remote_data_source.dart';
import 'feature/data/repositories/auth_repository_impl.dart';
import 'feature/data/repositories/product_repository_impl.dart';
import 'feature/data/repositories/user_repository_impl.dart';
import 'feature/domain/usecases/auth/login_usecase.dart';
import 'feature/domain/usecases/product/get_all_products_usecase.dart';
import 'feature/domain/usecases/product/get_products_by_category_usecase.dart';
import 'feature/domain/usecases/user/get_user_usecase.dart';
import 'feature/presentation/blocs/auth/auth_bloc.dart';
import 'feature/presentation/blocs/auth/auth_state.dart';
import 'feature/presentation/blocs/product/product_bloc.dart';
import 'feature/presentation/blocs/profile/profile_bloc.dart';
import 'feature/presentation/blocs/profile/profile_event.dart';
import 'feature/presentation/widgets/home/home_view.dart';
import 'feature/presentation/widgets/login/login_view.dart';
import 'feature/presentation/widgets/profile/profile_view.dart';

class DarazApp extends StatefulWidget {
  const DarazApp({super.key});

  @override
  State<DarazApp> createState() => _DarazAppState();
}

class _DarazAppState extends State<DarazApp> {
  //======================> Data layer: Remote data source (HTTP client) <=======================
  late final RemoteDataSource _remoteDataSource;
  //======================> Data layer: Repository implementations <=======================
  late final AuthRepositoryImpl _authRepositoryImpl;
  late final ProductRepositoryImpl _productRepositoryImpl;
  late final UserRepositoryImpl _userRepositoryImpl;

  //======================> Domain layer: Use cases <=======================
  late final LoginUseCase _loginUseCase;
  late final GetAllProductsUseCase _getAllProductsUseCase;
  late final GetProductsByCategoryUseCase _getElectronicsUseCase;
  late final GetProductsByCategoryUseCase _getJeweleryUseCase;
  late final GetUserUseCase _getUserUseCase;

  @override
  void initState() {
    super.initState();
    // Initialize data source
    _remoteDataSource = RemoteDataSource();
    // Initialize repository implementations with data source
    _authRepositoryImpl = AuthRepositoryImpl(remoteDataSource: _remoteDataSource);
    _productRepositoryImpl = ProductRepositoryImpl(remoteDataSource: _remoteDataSource);
    _userRepositoryImpl = UserRepositoryImpl(remoteDataSource: _remoteDataSource);
    // Initialize use cases with repositories
    _loginUseCase = LoginUseCase(authRepository: _authRepositoryImpl);
    _getAllProductsUseCase = GetAllProductsUseCase(productRepository: _productRepositoryImpl);
    _getElectronicsUseCase = GetProductsByCategoryUseCase(productRepository: _productRepositoryImpl);
    _getJeweleryUseCase = GetProductsByCategoryUseCase(productRepository: _productRepositoryImpl);
    _getUserUseCase = GetUserUseCase(userRepository: _userRepositoryImpl);
  }

  @override
  void dispose() {
    _remoteDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //======================> Provide all BLoC controllers at the app level <=======================
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(loginUseCase: _loginUseCase),
        ),
        BlocProvider(
          create: (_) => ProductBloc(
            getAllProductsUseCase: _getAllProductsUseCase,
            getElectronicsUseCase: _getElectronicsUseCase,
            getJeweleryUseCase: _getJeweleryUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(getUserUseCase: _getUserUseCase),
        ),
      ],
      child: MaterialApp(
        title: 'Daraz Scroll Architecture',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF85606)),
          useMaterial3: true,
        ),
        //=========================> Auth-aware root: shows LoginView or HomeView <==========================
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
