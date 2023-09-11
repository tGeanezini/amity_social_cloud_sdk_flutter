import 'dart:async';

import 'package:amity_sdk/src/core/core.dart';
import 'package:amity_sdk/src/data/data.dart';
import 'package:amity_sdk/src/domain/domain.dart';

class CommunityMemberRepoImpl extends CommunityMemberRepo {
  final CommunityMemmberApiInterface communityMemmberApiInterface;
  final CommunityMemberPagingDbAdapter communityMemberPagingDbAdapter;
  final CommunityMemberDbAdapter communityMemberDbAdapter;
  final CommunityDbAdapter communityDbAdapter;
  final UserDbAdapter userDbAdapter;
  final FileDbAdapter fileDbAdapter;

  CommunityMemberRepoImpl(
      {required this.communityMemmberApiInterface,
      required this.communityMemberPagingDbAdapter,
      required this.communityMemberDbAdapter,
      required this.communityDbAdapter,
      required this.userDbAdapter,
      required this.fileDbAdapter});

  @override
  Future<PageListData<List<AmityCommunityMember>, String>> queryMembers(GetCommunityMembersRequest request) async {
    final data = await communityMemmberApiInterface.getCommunityMembers(request);

    //Save members sequence in to feed db
    await communityMemberPagingDbAdapter
        .updateCommunityMemmberCollection(data.convertToCommunityMemberPagingHiveEntity());

    final amityCommunityMembers = await _saveDataToDb(data);

    return PageListData(amityCommunityMembers, data.paging!.next ?? '');
  }

  @override
  Future joinCommunity(String communityId) async {
    final data = await communityMemmberApiInterface.joinCommunity(communityId);
    await _saveDataToDb(data);
    return true;
  }

  @override
  Future leaveCommunity(String communityId) async {
    final data = await communityMemmberApiInterface.leaveCommunity(communityId);
    await _saveDataToDb(data);
    return true;
  }

  @override
  Future addMember(UpdateCommunityMembersRequest request) async {
    final data = await communityMemmberApiInterface.addMember(request);
    await _saveDataToDb(data);
    return true;
  }

  @override
  Future removeMember(UpdateCommunityMembersRequest request) async {
    final data = await communityMemmberApiInterface.removeMember(request);
    await _saveDataToDb(data);
    return true;
  }

  @override
  Future<AmityCommunityMember> getMember(String communityId, String userId) async {
    final member =
        communityMemberDbAdapter.getCommunityMemberEntity(communityId + userId)!.convertToAmityCommunityMember();
    return member;
  }

  @override
  Future<AmityCommunityMember?> getMemberOptional(String communityId, String userId) async {
    final memberEntity = communityMemberDbAdapter.getCommunityMemberEntity(communityId + userId);
    if(memberEntity!=null){
      return memberEntity.convertToAmityCommunityMember();
    }
    return null;
  }

  @override
  Future addRole(UpdateCommunityRoleRequest request) async {
    final data = await communityMemmberApiInterface.addRole(request);
    await _saveDataToDb(data);
    return true;
  }

  @override
  Future removeRole(UpdateCommunityRoleRequest request) async {
    final data = await communityMemmberApiInterface.removeRole(request);
    await _saveDataToDb(data);
    return true;
  }

  @override
  List<String>? getMemberPermission(String communityId, String userId) {
    final member = communityMemberDbAdapter.getCommunityMemberEntity(communityId + userId)!;
    return member.permissions;
  }

  @override
  Future banMember(UpdateCommunityMembersRequest request) async {
    final data = await communityMemmberApiInterface.banMember(request);
    await _saveDataToDb(data);
    return true;
  }

  @override
  Future unbanMember(UpdateCommunityMembersRequest request) async {
    final data = await communityMemmberApiInterface.unbanMember(request);
    await _saveDataToDb(data);
    return true;
  }

  Future<List<AmityCommunityMember>> _saveDataToDb(GetCommunityMembersResponse data) async {
    //Convert to File Hive Entity
    //we have save the file first, since every object depends on file
    List<FileHiveEntity> fileHiveEntities = data.files.map((e) => e.convertToFileHiveEntity()).toList();

    //Convert to Community Hive Entity
    List<CommunityHiveEntity> communityHiveEntities =
        data.communities.map((e) => e.convertToCommunityHiveEntity()).toList();

    //Convert to User Hive Entity
    List<UserHiveEntity> userHiveEntities = data.users.map((e) => e.convertToUserHiveEntity()).toList();

    //Convert to Community Member Hive Entity
    List<CommnityMemberHiveEntity> communityMemberHiveEntities =
        data.communityUsers.map((e) => e.convertToCommnityMemberHiveEntity()).toList();

    //Save the File Entity
    for (var e in fileHiveEntities) {
      await fileDbAdapter.saveFileEntity(e);
    }

    //Save the Community Entity
    for (var e in communityHiveEntities) {
      await communityDbAdapter.saveCommunityEntity(e);
    }

    //Save the User Entity
    for (var e in userHiveEntities) {
      await userDbAdapter.saveUserEntity(e);
    }

    //Save the Community Member Entity
    for (var e in communityMemberHiveEntities) {
      await communityMemberDbAdapter.saveCommunityMemberEntity(e);
    }

    return communityMemberHiveEntities.map((e) => e.convertToAmityCommunityMember()).toList();
  }

  @override
  bool hasLocalCommunity(String communityId, String userId) {
    return communityMemberDbAdapter.getCommunityMemberEntity(communityId + userId) != null;
  }
}
