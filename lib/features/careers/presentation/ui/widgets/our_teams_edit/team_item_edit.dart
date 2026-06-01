part of '../../pages/our_teams_edit.dart';

class _TeamItemEdit {
  final String id;
  _PickedImage icon;
  final TextEditingController headingEn;
  final TextEditingController headingAr;
  final TextEditingController titleEn;
  final TextEditingController titleAr;
  final TextEditingController descEn;
  final TextEditingController descAr;
  final List<_DeliverableEdit> deliverables;

  _TeamItemEdit({
    required this.id,
    _PickedImage? icon,
    String headingEn = '',
    String headingAr = '',
    String titleEn   = '',
    String titleAr   = '',
    String descEn    = '',
    String descAr    = '',
    List<_DeliverableEdit>? deliverables,
  })  : icon       = icon ?? const _PickedImage(),
        headingEn  = TextEditingController(text: headingEn),
        headingAr  = TextEditingController(text: headingAr),
        titleEn    = TextEditingController(text: titleEn),
        titleAr    = TextEditingController(text: titleAr),
        descEn     = TextEditingController(text: descEn),
        descAr     = TextEditingController(text: descAr),
        deliverables = deliverables ?? [];

  void dispose() {
    headingEn.dispose();
    headingAr.dispose();
    titleEn.dispose();
    titleAr.dispose();
    descEn.dispose();
    descAr.dispose();
    for (final d in deliverables) d.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
