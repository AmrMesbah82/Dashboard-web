// ******************* FILE INFO *******************
// File Name: main_cubit.dart
// Description: BLoC Cubit for the Main page CMS.
//              Reuses all Home CMS logic but is bound to its OWN Firestore
//              collection ('mainPage') so Main and Home data never mix.
// Created by: Amr Mesbah

import '../../../home/domain/base_repository/home_repo.dart';
import '../../../home/presentation/controller/home_cubit.dart';

/// Separate cubit type for the Main page so it can be provided independently
/// of [HomeCmsCubit]. It inherits the full editing/publishing behaviour from
/// [HomeCmsCubit]; only the backing repository (and therefore the Firestore
/// collection) differs.
class MainCmsCubit extends HomeCmsCubit {
  MainCmsCubit({required HomeRepository repository})
      : super(repository: repository);
}
