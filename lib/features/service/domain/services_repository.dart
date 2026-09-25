import 'service.dart';

abstract class ServicesRepository {
  Future<List<Service>> getServices();
  Future<Service?> getServiceById(String id);
}


abstract class LocalServicesRepository extends ServicesRepository {
  Future<void> replaceServices(List<Service> services);
}