import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldrnews_app/src/utils/extensions/context.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
import 'package:tldrnews_app/src/widgets/channel_icon.dart';

/// The lightweight identity of a channel: enough to show its icon and name
/// without a Firestore read.
class ChannelSnippet {
  @JsonKey(includeToJson: false)
  final String id;
  final String name;
  /// The branded icon for this channel's [id].
  ChannelIcon get icon => ChannelIcon.fromId(id);

  ChannelSnippet({required this.id, required this.name});

  /// Icon button for navigation. The button for the channel matching the current
  /// route is greyed and inert; [desaturate] greys the others too. [onTap]
  /// receives [id].
  Widget button(BuildContext context, {bool desaturate = false, void Function(String id)? onTap}) {
    bool active = context.uri.pathSegments.isNotEmpty && context.uri.pathSegments.last == id;
    final dim = desaturate || active;
    return IconButton(
      padding: .zero,
      onPressed: !active && onTap != null ? () => onTap(id) : null,
      icon: dim ? ColorFiltered(colorFilter: ColorFilter.saturation(0.2), child: icon) : icon,
    );
  }
}

/// The fixed set of TLDR channels the app knows about.
class ChannelSnippets {
  static ChannelSnippet get uk => ChannelSnippet(id: 'uk', name: 'TLDR UK');
  static ChannelSnippet get global => ChannelSnippet(id: 'global', name: 'TLDR Global');
  static ChannelSnippet get eu => ChannelSnippet(id: 'eu', name: 'TLDR EU');
  static ChannelSnippet get business => ChannelSnippet(id: 'business', name: 'TLDR Business');
  static ChannelSnippet get podcasts => ChannelSnippet(id: 'podcasts', name: 'TLDR Podcasts');
  static ChannelSnippet get party => ChannelSnippet(id: 'party', name: 'TLDR Party');

  /// The channel with [id], or `null` if it is not one of ours.
  static ChannelSnippet? byId(String id) => all.firstWhereOrNull((channel) => channel.id == id);

  /// Every channel, including the members-only [party].
  static List<ChannelSnippet> get all => [party, uk, global, eu, business, podcasts];
  /// Channels open to everyone, i.e. all but [party].
  static List<ChannelSnippet> get free => [uk, global, eu, business, podcasts];
}
