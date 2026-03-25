/// ******************* FILE INFO *******************
/// File Name: service_state.dart
/// Created by: Amr Mesbah

import 'package:web_app_admin/model/services_model.dart';

abstract class ServiceCmsState {}

class ServiceCmsInitial extends ServiceCmsState {}
class ServiceCmsLoading  extends ServiceCmsState {}

class ServiceCmsLoaded extends ServiceCmsState {
  final ServicePageModel data;
  ServiceCmsLoaded(this.data);
}

class ServiceCmsSaved extends ServiceCmsState {
  final ServicePageModel data;
  ServiceCmsSaved(this.data);
}

class ServiceCmsError extends ServiceCmsState {
  final String message;
  ServiceCmsError(this.message);
}