import 'dart:async';

import 'package:amity_sdk/src/core/core.dart';
import 'package:amity_sdk/src/domain/domain.dart';
import 'package:amity_sdk/src/domain/repo/channel_member_repo.dart';

/// [ChannelMemberQueryUsecase]
class ChannelMemberQueryUsecase extends UseCase<
    PageListData<List<AmityChannelMember>, String>, GetChannelMembersRequest> {
  /// Channel Member Repo
  final ChannelMemberRepo channelMemberRepo;

  /// Channel Composer Usecase
  final ChannelComposerUsecase channelComposerUsecase;

  /// Init [ChannelMemberQueryUsecase]
  ChannelMemberQueryUsecase(
      {required this.channelMemberRepo, required this.channelComposerUsecase});

  @override
  Future<PageListData<List<AmityChannelMember>, String>> get(
      GetChannelMembersRequest params) async {
    return await channelMemberRepo.queryMembers(params);
  }

  @override
  Stream<PageListData<List<AmityChannelMember>, String>> listen(
      GetChannelMembersRequest params) {
    throw UnimplementedError();
  }
}
