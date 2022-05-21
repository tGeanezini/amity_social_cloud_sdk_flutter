import 'package:flutter/material.dart';
import 'package:flutter_social_sample_app/core/widget/feed_widget.dart';

class ReactionActionWidget extends StatelessWidget {
  const ReactionActionWidget(
      {Key? key,
      required this.layerLink,
      required this.onTapReaction,
      required this.removeCallback})
      : super(key: key);
  final ArgumentCallback<String> onTapReaction;
  final VoidCallback removeCallback;
  final LayerLink layerLink;
  static void showAsOverLay(BuildContext context, LayerLink link,
      ArgumentCallback<String> onTapReaction) {
    OverlayState _state = Overlay.of(context)!;
    late OverlayEntry _entry;

    _entry = OverlayEntry(
      builder: (context) {
        return ReactionActionWidget(
          layerLink: link,
          onTapReaction: (reaction) {
            onTapReaction(reaction);
          },
          removeCallback: () {
            _entry.remove();
          },
        );
      },
    );

    _state.insert(_entry);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // type: MaterialType.transparency,
      color: Colors.black.withOpacity(.2),
      child: InkWell(
        onTap: () {
          removeCallback();
        },
        child: Center(
          child: CompositedTransformFollower(
            offset: Offset(0, 24),
            link: layerLink,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      onTapReaction.call('like');
                      removeCallback();
                    },
                    icon: Image.asset(
                      'packages/amity_sdk/assets/ic_liked.png',
                    ),
                    iconSize: 24,
                  ),
                  IconButton(
                    onPressed: () {
                      onTapReaction.call('heart');
                      removeCallback();
                    },
                    icon: Image.asset(
                      'packages/amity_sdk/assets/ic_heart.png',
                    ),
                    iconSize: 24,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
