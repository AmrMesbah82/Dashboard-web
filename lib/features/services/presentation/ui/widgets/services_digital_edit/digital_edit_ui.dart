// ******************* FILE INFO *******************
// Part of: services_digital_main.dart
// Contains: _buildItemAccordion, _buildAccordion, _actionButtons,
//           _iconPreview, _labelStyle, _ordinal

part of '../../pages/digital_services/services_digital_main.dart';

extension _DigitalEditUi on _ServicesDigitalJourneyEditPageState {
  // ── Ordinal helper ────────────────────────────────────────────────────────────
  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  // ── Per-item accordion ────────────────────────────────────────────────────────
  Widget _buildItemAccordion(int i) {
    final c      = _itemCtrls[i];
    final isOpen = _itemOpen[i];

    return _buildAccordion(
      title: '${_ordinal(i + 1)} Digital Journey',
      isOpen: isOpen,
      onToggle: () => setState(() => _itemOpen[i] = !isOpen),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon row ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Icon', style: _labelStyle()),
                GestureDetector(
                  onTap: () => _removeItem(i),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                        color: Colors.red, borderRadius: BorderRadius.circular(6.r)),
                    child: Text('Remove',
                        style: StyleText.fontSize12Weight600
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _iconPreview(c.iconUrl,
                isLoading: c.iconUrl == 'loading', onPick: () => _uploadIcon(i)),
            SizedBox(height: 6.h),

            // ── Title fields ────────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Title *', style: _labelStyle()),
              Text('العنوان *', style: _labelStyle()),
            ]),
            SizedBox(height: 6.h),
            Row(children: [
              Expanded(
                child: CustomTextField(
                  controller: c.titleEnCtrl,
                  hint: 'Text Here',
                  isRequired: true,
                  submitted: _submitted,
                  primaryColor: ColorPick.primary,
                  fillColor: Colors.white,
                  textDirection: TextDirection.ltr,
                  height: 36,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: c.titleArCtrl,
                  hint: 'أدخل النص هنا',
                  isRequired: true,
                  submitted: _submitted,
                  primaryColor: ColorPick.primary,
                  fillColor: Colors.white,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  height: 36,
                ),
              ),
            ]),
            SizedBox(height: 14.h),

            // ── Description fields ──────────────────────────────────────────
            Text('Description *', style: _labelStyle()),
            SizedBox(height: 6.h),
            CustomTextField(
              controller: c.descEnCtrl,
              hint: 'Text Here',
              isRequired: true,
              submitted: _submitted,
              primaryColor: ColorPick.primary,
              textDirection: TextDirection.ltr,
              maxLines: 4,
              height: 100,
              fillColor: Colors.white,
              showCharCount: true,
              maxLength: 500,
            ),
            SizedBox(height: 14.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text('الوصف *', style: _labelStyle()),
            ),
            SizedBox(height: 6.h),
            CustomTextField(
              controller: c.descArCtrl,
              hint: 'أدخل النص هنا',
              isRequired: true,
              submitted: _submitted,
              fillColor: Colors.white,
              primaryColor: ColorPick.primary,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 4,
              height: 100,
              showCharCount: true,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable accordion ────────────────────────────────────────────────────────
  Widget _buildAccordion({
    required String       title,
    required bool         isOpen,
    required VoidCallback onToggle,
    required Widget       child,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                  color: ColorPick.primary,
                  borderRadius: BorderRadius.circular(6.r)),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20.sp,
                ),
              ]),
            ),
          ),
          if (isOpen) child,
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────────
  Widget _actionButtons() {
    final isFormValid  = _isFormValid();
    final isSaveEnabled = _hasChanges && isFormValid && !_isSaving;

    return Column(children: [
      Row(children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _onPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF608570),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Preview',
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: AbsorbPointer(
            absorbing: !isSaveEnabled,
            child: Opacity(
              opacity: isSaveEnabled ? 1.0 : 0.5,
              child: SizedBox(
                height: 44.h,
                child: ElevatedButton(
                  onPressed: isSaveEnabled
                      ? () => showPublishConfirmDialog(
                    context: context,
                    title: 'EDITING SERVICES DETAILS',
                    subtitle:
                    'Do you want to save the changes made to this Service Details?',
                    confirmLabel: 'PUBLISHED',
                    onConfirm: _onSave,
                  )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPick.primary,
                    disabledBackgroundColor: ColorPick.back,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Published',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ]),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(
          child: customButton(
            title: 'Discard',
            function: _onDiscard,
            height: 44.h,
            color: const Color(0xFF797979),
            radius: 8.r,
            textColor: Colors.white,
            textStyle: StyleText.fontSize14Weight600.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(child: Container()),
      ]),
    ]);
  }

  // ── Icon preview widget ───────────────────────────────────────────────────────
  Widget _iconPreview(String url, {bool isLoading = false, VoidCallback? onPick}) {
    if (isLoading || url == 'loading') {
      return Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
        child: Center(
          child: SizedBox(
            width: 24.w, height: 24.h,
            child: CircularProgressIndicator(strokeWidth: 2, color: ColorPick.primary),
          ),
        ),
      );
    }

    if (url.isNotEmpty && url.startsWith('http')) {
      return Stack(clipBehavior: Clip.none, children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 60.w, height: 60.h,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: NetworkImageView(url: url,
                    width: 30.w, height: 30.h, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 25.w, height: 25.h,
              decoration: BoxDecoration(
                color: ColorPick.primary, shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(child: Icon(Icons.camera_alt, size: 12.sp, color: Colors.white)),
            ),
          ),
        ),
      ]);
    }

    // Empty state
    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(
        onTap: onPick,
        child: Container(
          width: 60.w, height: 60.h,
          decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
          child: Center(child: Icon(Icons.add, color: Colors.grey, size: 22.sp)),
        ),
      ),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 25.w, height: 25.h,
            decoration: BoxDecoration(
              color: ColorPick.primary, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(child: Icon(Icons.camera_alt, size: 12.sp, color: Colors.white)),
          ),
        ),
      ),
    ]);
  }

  TextStyle _labelStyle() =>
      StyleText.fontSize12Weight600.copyWith(color: AppColors.text);
}
