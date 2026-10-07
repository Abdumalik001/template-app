import 'package:template_app/core/api/dio_client.dart';

class DioClientDummyJson extends DioClient {
  DioClientDummyJson({super.isUnitTest, super.onLogout})
    : super(baseUrl: 'https://dummyjson.com');
}
