import 'package:apple_auth/authentication/bloc/authentication_bloc.dart';
import 'package:apple_auth/core/values/app_constants.dart';
import 'package:apple_auth/login/bloc/login_bloc.dart';
import 'package:apple_id_auth_repository/apple_id_auth_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http_util/http_util.dart';
import 'package:local_data_source/local_data_source.dart';
import 'package:user_repository/user_repository.dart';

class InjectionContainer {
  static final sl = GetIt.instance;

  static Future<void> init() async {
    await initApp();
    await initAuth();
  }

  static Future<void> initApp() async {
    final httpClient = HttpUtil(url: AppConstants.SERVER_API_URL);
    final storageService = await LocalDataSource().init();
    sl

      /// Services
      ..registerLazySingleton<LocalDataSource>(() => storageService)
      ..registerLazySingleton<HttpUtil>(() => httpClient);
  }

  static Future<void> initAuth() async {
    sl

      /// Blocs
      ..registerFactory<AuthenticationBloc>(
        () => AuthenticationBloc(
          authenticationRepository: sl(),
          userRepository: sl(),
        ),
      )
      ..registerFactory<LoginBloc>(() => LoginBloc(
          appleIdAuthRepository: sl(),
          authenticationRepository: sl(),
          userRepository: sl()))

      /// Repositories
      ..registerLazySingleton<AuthenticationRepository>(
        () => AuthenticationRepository(httpClient: sl()),
        dispose: (repo) => repo.dispose(),
      )
      ..registerLazySingleton<AppleIdAuthRepository>(
        () => AppleIdAuthRepository(),
      )
      ..registerLazySingleton<UserRepository>(() => UserRepository(sl()));
  }
}
