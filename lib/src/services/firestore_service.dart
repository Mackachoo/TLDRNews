import 'package:tldrnews_app/src/services/firestore/channel_service.dart';
import 'package:tldrnews_app/src/services/firestore/account_service.dart';
import 'package:tldrnews_app/src/services/firestore/meta_service.dart';

/// Entry point to the Firestore services, one per top-level collection.
class FirestoreService {
  static final AccountService account = AccountService();
  static final MetaService meta = MetaService();
  static final ChannelService channel = ChannelService();
}
