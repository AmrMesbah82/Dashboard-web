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
      child: CustomValidatedTextFieldMaster(
        label: label, hint: hint, controller: ctrl,
        height: height, maxLines: maxLines, fillColor: Colors.white,
        showCharCount: true, maxLength: 500,
        textDirection: TextDirection.rtl, textAlign: TextAlign.right,
        primaryColor: ColorPick.primary, submitted: _submitted, isRequired: isRequired,
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
    return CustomValidatedTextFieldMaster(
      label: label, hint: hint, fillColor: Colors.white,
      controller: ctrl, maxLength: 500, showCharCount: true,
      height: height, maxLines: maxLines,
      textDirection: TextDirection.ltr,
      primaryColor: ColorPick.primary, submitted: _submitted, isRequired: isRequired,
    );
  }

  Widget _iconUploadWidget({required String statId, required String label}) {
    final newBytes = _statIcons[statId];
    final savedUrl = _statIconUrls[statId] ?? '';
    final hasIcon = newBytes != null || savedUrl.isNotEmpty;
    final hasError = _submitted && !hasIcon;

    Future<void> pickIcon() async {
      final bytes = await _pickSvgFile();
      if (bytes != null) setState(() { _statIcons[statId] = bytes; _hasChanges = true; });
    }

    Widget iconContent;
    if (newBytes != null) {
      iconContent = Padding(padding: EdgeInsets.all(8.r), child: SvgPicture.memory(newBytes, fit: BoxFit.contain));
    } else if (savedUrl.isNotEmpty) {
      iconContent = Padding(padding: EdgeInsets.all(8.r), child: NetworkImageView(url: savedUrl, fit: BoxFit.contain));
    } else {
      iconContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvg(assetPath: "assets/control/camera.svg", width: 20.w, height: 20.h, fit: BoxFit.scaleDown, color: hasError ? Colors.red : null),
          SizedBox(height: 2.h),
        ],
      );
    }

    final Widget circle = Container(
      width: 56.w, height: 56.w,
      decoration: BoxDecoration(
        color: hasError ? Colors.red.withValues(alpha: 0.08) : Colors.white,
        shape: BoxShape.circle,
        border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      child: ClipOval(child: iconContent),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleText.fontSize13Weight600.copyWith(color: AppColors.text)),
        SizedBox(height: 6.h),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(onTap: pickIcon, child: circle),
            Positioned(
              bottom: -4, right: -4,
              child: GestureDetector(
                onTap: pickIcon,
                child: Container(
                  width: 20.w, height: 20.h,
                  decoration: BoxDecoration(color: ColorPick.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: Center(child: CustomSvg(assetPath: "assets/control/camera.svg", width: 10.w, height: 10.h, fit: BoxFit.scaleDown)),
                ),
              ),
            ),
          ],
        ),
      ],
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
                style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500)),
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
