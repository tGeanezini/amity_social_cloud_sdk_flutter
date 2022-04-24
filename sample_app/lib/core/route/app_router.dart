import 'package:amity_sdk/lib.dart';
import 'package:flutter_social_sample_app/core/route/app_route.dart';
import 'package:flutter_social_sample_app/presentation/screen/comment_query/comment_query_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/community_feed/community_feed_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/create_post/create_post_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/dashboard/dashboar_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/global_feed/global_feed_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/login/login_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/user_feed/user_feed_screen.dart';
import 'package:flutter_social_sample_app/presentation/screen/user_profile/user_profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoute.homeRoute,
    routes: [
      GoRoute(
          name: AppRoute.home,
          path: AppRoute.homeRoute,
          builder: (context, state) => const DashboardScreen(),
          routes: [
            GoRoute(
                name: AppRoute.profile,
                path: AppRoute.profileRoute,
                builder: (context, state) =>
                    UserProfileScreen(userId: state.params['userId']!),
                routes: [
                  GoRoute(
                    name: AppRoute.createPost + '_from_profile',
                    path: AppRoute.createPostRoute,
                    builder: (context, state) =>
                        CreatePostScreen(userId: state.params['userId']!),
                  ),
                ]),
            GoRoute(
              name: AppRoute.createPost,
              path: AppRoute.createPostRoute,
              builder: (context, state) =>
                  CreatePostScreen(userId: state.params['userId']!),
            ),
            GoRoute(
              name: AppRoute.globalFeed,
              path: AppRoute.globalFeedRoute,
              builder: (context, state) => const GlobalFeedScreen(),
              routes: [
                GoRoute(
                  name: 'commentGlobalFeed',
                  path: 'comment/:postId',
                  builder: (context, state) =>
                      CommentQueryScreen(state.params['postId']!),
                ),
              ],
            ),
            GoRoute(
              name: AppRoute.communityFeed,
              path: AppRoute.communityFeedRoute,
              builder: (context, state) => CommunityFeedScreen(
                  communityId: state.params['communityId']!),
              routes: [
                GoRoute(
                  path: 'comment/:postId',
                  builder: (context, state) =>
                      CommentQueryScreen(state.params['postId']!),
                ),
              ],
            ),
            GoRoute(
              name: AppRoute.userFeed,
              path: AppRoute.userFeedRoute,
              builder: (context, state) =>
                  UserFeedScreen(userId: state.params['userId']!),
              routes: [
                GoRoute(
                  path: 'comment/:postId',
                  builder: (context, state) =>
                      CommentQueryScreen(state.params['postId']!),
                ),
              ],
            ),
          ]),
      GoRoute(
        name: AppRoute.login,
        path: AppRoute.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    redirect: (state) {
      if (state.location != AppRoute.loginRoute) {
        return AmityCoreClient.isUserLoggedIn() ? null : AppRoute.loginRoute;
      }
      return null;
    },
    debugLogDiagnostics: true,
  );
}
