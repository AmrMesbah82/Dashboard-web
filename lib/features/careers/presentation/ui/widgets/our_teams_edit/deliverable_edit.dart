part of '../../pages/our_teams_edit.dart';

class _DeliverableEdit {
  final String id;
  final TextEditingController enCtrl;
  final TextEditingController arCtrl;

  _DeliverableEdit({required this.id, String en = '', String ar = ''})
      : enCtrl = TextEditingController(text: en),
        arCtrl = TextEditingController(text: ar);

  void dispose() {
    enCtrl.dispose();
    arCtrl.dispose();
  }
}
