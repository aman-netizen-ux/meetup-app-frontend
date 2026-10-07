import 'package:app_links/app_links.dart';

class AppLinkDataSource {
  AppLinkDataSource(this._appLinks);

  final AppLinks _appLinks;

  Future<Uri?> initialLink() => _appLinks.getInitialLink();

  Stream<Uri> get links => _appLinks.uriLinkStream;
}
