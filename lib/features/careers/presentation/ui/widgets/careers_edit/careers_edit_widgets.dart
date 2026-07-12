part of '../../pages/careers_edit.dart';

extension _CareersEditWidgets on _CareersEditPageState {
  Widget _arField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    double height = 36,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: label, hint: hint, controller: ctrl,
        maxLines: maxLines, maxLength: 500,
        height: maxLines > 1 ? null : height,
        fillColor: Colors.white,
        textDirection: TextDirection.rtl, textAlign: TextAlign.right,
        required: isRequired, submitted: _submitted,
      ),
    );
  }

  Widget _enField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    double height = 36,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return CustomTextField(
      label: label, hint: hint, controller: ctrl,
      maxLines: maxLines, maxLength: 500,
      height: maxLines > 1 ? null : height,
      fillColor: Colors.white,
      textDirection: TextDirection.ltr, textAlign: TextAlign.left,
      required: isRequired, submitted: _submitted,
    );
  }

  Widget _iconUploadWidget({required String statId, required String label}) {
    final newBytes = _statIcons[statId];
    final savedUrl = _statIconUrls[statId] ?? '';

    Future<void> pickIcon() async {
      final bytes = await _pickSvgFile();
      if (bytes != null) setState(() { _statIcons[statId] = bytes; _hasChanges = true; });
    }

    // Delegates to the single shared image-upload circle (core/custom).
    return imageUploadCircle(
      label: label,
      bytes: newBytes,
      url: savedUrl,
      onTap: pickIcon,
    );
  }

  Widget _actionButtons() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _btn(label: 'Preview', color: const Color(0xFF608570), onTap: _preview)),
          SizedBox(width: 300.w),
          Expanded(
            child: Tooltip(
              message: _publishTooltip,
              child: _btn(label: 'Publish', color: ColorPick.primary, onTap: _isPublishEnabled ? _handlePublish : null),
            ),
          ),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(child: _btn(label: 'Discard', color: const Color(0xFF797979), onTap: _discard)),
          SizedBox(width: 300.w),
          Expanded(child: const SizedBox()),
        ]),
        if (_submitted && !_isFormValid)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text('Please fix validation errors above before publishing',
                style: StyleText.fontSize12Weight500.copyWith(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _accordion({required String key, required String title, required List<Widget> children}) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
            child: Row(children: [
              Expanded(child: Text(title, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 25.sp),
            ]),
          ),
        ),
        if (isOpen) Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ]),
    );
  }

  Widget _btn({required String label, required Color color, VoidCallback? onTap}) {
    final bool disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 44.h,
        decoration: BoxDecoration(
          color: disabled ? color.withValues(alpha: 0.45) : color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Text(label, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
      ),
    );
  }

  String _ord(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}
