import 'package:cactus_hr/core/api/dio_client.dart';

class DioClientDummyJson extends DioClient {
  DioClientDummyJson({super.isUnitTest})
    : super(baseUrl: 'https://dummyjson.com');
}
