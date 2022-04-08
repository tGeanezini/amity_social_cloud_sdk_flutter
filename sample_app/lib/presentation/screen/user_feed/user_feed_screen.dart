import 'package:amity_sdk/core/utils/paging_controller.dart';
import 'package:amity_sdk/domain/model/amity_post.dart';
import 'package:amity_sdk/public/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_sample_app/core/constant/global_constant.dart';
import 'package:flutter_social_sample_app/core/route/app_route.dart';
import 'package:flutter_social_sample_app/core/widget/feed_widget.dart';
import 'package:go_router/go_router.dart';

class UserFeedScreen extends StatefulWidget {
  const UserFeedScreen({Key? key, required this.userId, this.showAppBar = true})
      : super(key: key);
  final String userId;
  final bool showAppBar;
  @override
  State<UserFeedScreen> createState() => _UserFeedScreenState();
}

class _UserFeedScreenState extends State<UserFeedScreen> {
  late PagingController<AmityPost> _controller;
  final amityPosts = <AmityPost>[];

  final scrollcontroller = ScrollController();
  bool loading = false;
  @override
  void initState() {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(widget.userId)
          .includeDeleted(false)
          .getPagingData(token: token, limit: GlobalConstant.pageSize),
      pageSize: GlobalConstant.pageSize,
    )..addListener(
        () {
          if (_controller.error == null) {
            setState(() {
              amityPosts.clear();
              amityPosts.addAll(_controller.loadedItems);
            });
          } else {
            //Error on pagination controller
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(_controller.error.toString()),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).goNamed(AppRoute.login);
                    },
                    child: const Text('Logout'),
                  )
                ],
              ),
            );
          }
        },
      );

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    scrollcontroller.addListener(pagination);

    super.initState();
  }

  void pagination() {
    if ((scrollcontroller.position.pixels ==
            scrollcontroller.position.maxScrollExtent) &&
        _controller.hasMoreItems) {
      setState(() {
        _controller.fetchNextPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text('User Feed - ${widget.userId}'))
          : null,
      body: Column(
        children: [
          Expanded(
            child: amityPosts.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () async {
                      _controller.reset();
                      _controller.fetchNextPage();
                    },
                    child: ListView.builder(
                      controller: scrollcontroller,
                      itemCount: amityPosts.length,
                      itemBuilder: (context, index) {
                        final amityPost = amityPosts[index];
                        return FeedWidget(amityPost: amityPost);
                      },
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
          ),
          if (_controller.isFetching)
            Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
