import 'package:amity_sdk/src/core/model/api_request/create_post_request.dart';
import 'package:amity_sdk/src/core/model/api_request/get_post_request.dart';
import 'package:amity_sdk/src/core/model/api_request/update_post_request.dart';
import 'package:amity_sdk/src/data/data.dart';

abstract class PublicPostApiInterface {
  Future<CreatePostResponse> queryPost(GetPostRequest request);
  Future<CreatePostResponse> createPost(CreatePostRequest request);

  Future<CreatePostResponse> getPostById(String postId);
  Future<CreatePostResponse> updatePostById(UpdatePostRequest request);
  Future<bool> deletePostById(String postId);

  Future<CreatePostResponse> flagPost(String postId);
  Future<CreatePostResponse> unflagPost(String postId);
  Future<bool> isPostFlagByMe(String postId);

  Future<bool> approvePost(String postId);
  Future<bool> declinePost(String postId);
}
