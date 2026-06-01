part of '../../pages/digital_services/services_digital_main.dart';

class _ItemControllers {
  final String itemId;
  final TextEditingController titleEnCtrl;
  final TextEditingController titleArCtrl;
  final TextEditingController descEnCtrl;
  final TextEditingController descArCtrl;
  String iconUrl;

  _ItemControllers({
    required this.itemId,
    required this.titleEnCtrl,
    required this.titleArCtrl,
    required this.descEnCtrl,
    required this.descArCtrl,
    required this.iconUrl,
  });

  factory _ItemControllers.fromModel(JourneyItemModel m) => _ItemControllers(
    itemId: m.id,
    titleEnCtrl: TextEditingController(text: m.title.en),
    titleArCtrl: TextEditingController(text: m.title.ar),
    descEnCtrl: TextEditingController(text: m.description.en),
    descArCtrl: TextEditingController(text: m.description.ar),
    iconUrl: m.iconUrl,
  );

  factory _ItemControllers.empty() => _ItemControllers(
    itemId: 'ji_${DateTime.now().millisecondsSinceEpoch}',
    titleEnCtrl: TextEditingController(),
    titleArCtrl: TextEditingController(),
    descEnCtrl: TextEditingController(),
    descArCtrl: TextEditingController(),
    iconUrl: '',
  );

  void dispose() {
    titleEnCtrl.dispose();
    titleArCtrl.dispose();
    descEnCtrl.dispose();
    descArCtrl.dispose();
  }
}

// ── Original item data ─────────────────────────────────────────────────────
