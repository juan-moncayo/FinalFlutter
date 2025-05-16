import 'package:appwrite/appwrite.dart';
import 'package:placas_app/core/constants/appwrite_constants.dart';

class AppwriteConfig {
  static late Client client;
  static late Account account;
  static late Databases databases;
  static late Storage storage;

  static Future<void> init() async {
    client = Client()
      ..setEndpoint(AppwriteConstants.endpoint)
      ..setProject(AppwriteConstants.projectId)
      ..setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}
