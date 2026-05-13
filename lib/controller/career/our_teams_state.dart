// ******************* FILE INFO *******************
// File Name: our_teams_state.dart

import 'package:web_app_admin/model/our_teams_model.dart';

abstract class OurTeamsState {}

class OurTeamsInitial extends OurTeamsState {}

class OurTeamsLoading extends OurTeamsState {}

class OurTeamsLoaded extends OurTeamsState {
  final OurTeamsModel data;
  OurTeamsLoaded(this.data);
}

class OurTeamsSaved extends OurTeamsState {
  final OurTeamsModel data;
  OurTeamsSaved(this.data);
}

class OurTeamsError extends OurTeamsState {
  final String message;
  OurTeamsError(this.message);
}