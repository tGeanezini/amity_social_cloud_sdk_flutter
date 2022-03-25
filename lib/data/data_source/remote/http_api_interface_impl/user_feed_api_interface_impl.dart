import 'package:amity_sdk/core/core.dart';
import 'package:amity_sdk/core/model/api_request/get_user_feed_request.dart';
import 'package:amity_sdk/data/data.dart';
import 'package:amity_sdk/data/data_source/remote/api_interface/user_feed_api_interface.dart';
import 'package:dio/dio.dart';

class UserFeedApiInterfaceImpl extends UserFeedApiInterface {
  UserFeedApiInterfaceImpl({required this.httpApiClient});
  final HttpApiClient httpApiClient;
  @override
  Future<CreatePostResponse> getUserFeed(GetUserFeedRequest request) async {
    try {
      final data = await httpApiClient()
          .get(USER_FEED_V3_URL, queryParameters: request.toJson());
      return CreatePostResponse.fromJson(data.data);
    } on DioError catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }
}
