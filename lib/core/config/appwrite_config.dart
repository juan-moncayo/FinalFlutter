import 'package:appwrite/appwrite.dart';
import 'package:placas_app/core/constants/appwrite_constants.dart';

class AppwriteConfig {
  static Client client = Client();
  static late Account account;
  static late Databases databases;
  static late Storage storage;

  static Future<void> init() async {
    client
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId)
        .setSelfSigned(status: true); // Solo para desarrollo

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}
