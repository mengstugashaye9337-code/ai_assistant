import 'service.dart';

abstract class ServicesRepository {
  Future<List<Service>> getServices();
  Future<Service?> getServiceById(String id);
}
