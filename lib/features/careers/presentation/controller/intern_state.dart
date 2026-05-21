// ******************* FILE INFO *******************
// File Name: intern_state.dart


import '../../data/models/intern_model.dart';

abstract class InternState {}

class InternInitial   extends InternState {}
class InternLoading   extends InternState {}
class InternSaving    extends InternState {}

class InternLoaded extends InternState {
  final List<InternModel> interns;
  InternLoaded(this.interns);
}

class InternCreated extends InternState {
  final List<InternModel> interns;
  final InternModel       created;
  InternCreated(this.interns, this.created);
}

class InternUpdated extends InternState {
  final List<InternModel> interns;
  InternUpdated(this.interns);
}

class InternDeleted extends InternState {
  final List<InternModel> interns;
  InternDeleted(this.interns);
}

class InternError extends InternState {
  final String message;
  InternError(this.message);
}