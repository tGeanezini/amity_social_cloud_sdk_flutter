import 'package:amity_sdk/src/core/core.dart';
import 'package:amity_sdk/src/data/data.dart';
import 'package:dio/dio.dart';

/// [ChannelMemberApiInterfaceImpl]
class ChannelMemberApiInterfaceImpl extends ChannelMemberApiInterface {
  /// init [ChannelMemberApiInterfaceImpl]
  ChannelMemberApiInterfaceImpl({required this.httpApiClient});

  /// Http Client
  final HttpApiClient httpApiClient;

  @override
  Future<CreateChannelResponse> addMember(
      UpdateChannelMembersRequest request) async {
    try {
      final data = await httpApiClient().post(
          '$CHANNELS_V3/${request.channelId}/$USERS',
          data: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> removeMember(
      UpdateChannelMembersRequest request) async {
    try {
      final param = <String, String>{"channelId": request.channelId};
      final data = await httpApiClient().delete(
          '$CHANNELS_V3/${request.channelId}/$USERS',
          data: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> getChannelMembers(
      GetChannelMembersRequest request) async {
    try {
      final data = await httpApiClient().get(
          '$CHANNELS_V3/${request.channelId}/$USERS/',
          queryParameters: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> searchChannelMembers(
      GetChannelMembersRequestV4 request) async {
    try {
      final data = await httpApiClient().get(
          '$CHANNELS_V4/${request.channelId}/$USERS/',
          queryParameters: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> joinChannel(String channelId) async {
    try {
      final param = <String, String>{
        "channelId": channelId,
      };
      final data = await httpApiClient()
          .post('$CHANNELS_V3/$channelId/$JOIN', data: param);
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> leaveChannel(String channelId) async {
    try {
      final param = <String, String>{
        "channelId": channelId,
      };
      final data = await httpApiClient()
          .delete('$CHANNELS_V3/$channelId/$LEAVE', data: param);
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> banMember(
      UpdateChannelMembersRequest request) async {
    try {
      final data = await httpApiClient().put(
          '$CHANNELS_V3/${request.channelId}/$USERS/$BAN',
          data: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> unbanMember(
      UpdateChannelMembersRequest request) async {
    try {
      final data = await httpApiClient().put(
          '$CHANNELS_V3/${request.channelId}/$USERS/$UNBAN',
          data: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> addRole(
      UpdateChannelRoleRequest request) async {
    try {
      final data = await httpApiClient().post(
          '$CHANNELS_V3/${request.channelId}/$USERS/$ROLES',
          data: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future<CreateChannelResponse> removeRole(
      UpdateChannelRoleRequest request) async {
    try {
      final data = await httpApiClient().delete(
          '$CHANNELS_V3/${request.channelId}/$USERS/$ROLES',
          data: request.toJson());
      return CreateChannelResponse.fromJson(data.data);
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }

  @override
  Future muteMember(UpdateChannelMembersRequest request) async {
    try {
      await httpApiClient().put('$CHANNEL_V2/${request.channelId}/$USERS/mute',
          data: request.toJson());
      return;
    } on DioException catch (error) {
      final amityError = AmityErrorResponse.fromJson(error.response!.data);
      return Future.error(amityError.amityException());
    }
  }
}
