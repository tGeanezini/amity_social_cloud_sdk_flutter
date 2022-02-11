import 'package:amity_sdk/core/core.dart';
import 'package:amity_sdk/public/public.dart';
import 'package:amity_sdk/public/query_builder/login_query_builder.dart';
import 'package:amity_sdk/public/repo/user_repository.dart';

class AmityCoreClient {
  static void setup({required AmityCoreClientOption option}) async {
    if (serviceLocator.isRegistered<AmityCoreClientOption>()) {
      serviceLocator.unregister<AmityCoreClientOption>();
    }
    serviceLocator.registerLazySingleton<AmityCoreClientOption>(() => option);
    await SdkServiceLocator.initServiceLocator();
  }

  static LoginQueryBuilder login(String userId) {
    return LoginQueryBuilder(useCase: serviceLocator(), userId: userId);
  }

  static String getUserId() {
    if (serviceLocator.isRegistered<AmityUser>()) {
      return serviceLocator<AmityUser>().userId!;
    }
    throw AmityException(
        message: 'App dont have active user, Please login', code: 401);
  }

  static AmityUser getCurrentUser() {
    if (serviceLocator.isRegistered<AmityUser>()) {
      return serviceLocator<AmityUser>();
    }
    throw AmityException(
        message: 'App dont have active user, Please login', code: 401);
  }

  static UserRepository newUserRepository() => serviceLocator<UserRepository>();
}

class AmityCoreClientOption {
  final String apiKey;
  final AmityRegionalHttpEndpoint httpEndpoint;
  final AmityRegionalSocketEndpoint socketEndpoint;

  AmityCoreClientOption(
      {required this.apiKey,
      this.httpEndpoint = AmityRegionalHttpEndpoint.SG,
      this.socketEndpoint = AmityRegionalSocketEndpoint.SG});
}
