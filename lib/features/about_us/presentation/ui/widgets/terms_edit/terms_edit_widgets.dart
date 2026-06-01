part of '../../pages/terms_page/terms_edit.dart';

extension _TermsEditWidgets on _TermsEditPageState {
  // ── Standardized Image Widget ─────────────────────────────────────────────
  Widget _imgBox({
    required _PickedImage picked,
    bool isAdd = false,
    VoidCallback? onPick,
  }) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.memory(picked.bytes!,
                width: 30.w, height: 30.h, fit: BoxFit.contain),
          ),
        ),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: SvgPicture.network(picked.url!,
                width: 30.w, height: 30.h, fit: BoxFit.contain,
                placeholderBuilder: (_) =>
                const CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      );
    } else {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9), shape: BoxShape.circle),
        child: Center(
          child: Icon(isAdd ? Icons.add : Icons.image_outlined,
              color: Colors.grey, size: 22.sp),
        ),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(onTap: onPick, child: content),
        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 25.w, height: 25.h,
              decoration: BoxDecoration(
                color: _kGreenSolid,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: CustomSvg(
                  assetPath: "assets/control/camera.svg",
                  width: 10.w, height: 10.h, fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section Editor ────────────────────────────────────────────────────────
  Widget _sectionEditor({
    required _PickedImage svgPicked,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
    required _DocItem docEn,
    required _DocItem docAr,
    required VoidCallback onPickSvg,
    required VoidCallback onPickDocEn,
    required VoidCallback onPickDocAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        _fieldLabel('Icon'),
        SizedBox(height: 8.h),
        _imgBox(picked: svgPicked, onPick: onPickSvg),
        SizedBox(height: 16.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          fillColor: Colors.white,
          hint: 'Text Here',
          controller: descEnCtrl,
          height: 120,
          maxLines: 5,
          maxLength: 10000,
          showCharCount: false,
          submitted: false,
          isRequired: false,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          primaryColor: _kGreenSolid,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('Description'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          fillColor: Colors.white,
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 120,
          maxLines: 5,
          maxLength: 10000,
          showCharCount: false,
          submitted: false,
          isRequired: false,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: _kGreenSolid,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _docUploadField(
              label: 'Attach English Document',
              docItem: docEn,
              onPick: onPickDocEn,
              onRemove: () => setState(() {
                docEn.bytes = null;
                docEn.fileName = '';
                docEn.existingUrl = '';
                _checkForChanges();
              }),
            )),
            SizedBox(width: 16.w),
            Expanded(child: _docUploadField(
              label: 'Attach Arabic Document',
              docItem: docAr,
              onPick: onPickDocAr,
              onRemove: () => setState(() {
                docAr.bytes = null;
                docAr.fileName = '';
                docAr.existingUrl = '';
                _checkForChanges();
              }),
            )),
          ],
        ),
      ],
    );
  }

  // ── Doc Upload Field ──────────────────────────────────────────────────────
  Widget _docUploadField({
    required String label,
    required _DocItem docItem,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(height: 8.h),
        docItem.hasFile
            ? Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r)),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 18.sp, color: _kRed),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(docItem.displayName,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.text),
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22.w, height: 22.h,
                  decoration: BoxDecoration(
                      color: _kRed, shape: BoxShape.circle),
                  child: Icon(Icons.remove,
                      color: Colors.white, size: 14.sp),
                ),
              ),
            ],
          ),
        )
            : GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
                color: _kGreenSolid,
                borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text('Attach Document',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
            decoration: BoxDecoration(
                color: _kGreenSolid,
                borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: Colors.white)),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white, size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.r))),
            child: child,
          ),
      ],
    );
  }

  // ── Bilingual Row ─────────────────────────────────────────────────────────
  Widget _bilingualRow({
    required TextEditingController enCtrl,
    required TextEditingController arCtrl,
    required String enHint,
    required String arHint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextFieldMaster(
            fillColor: Colors.white,
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: false,
            isRequired: false,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            primaryColor: _kGreenSolid,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            fillColor: Colors.white,
            hint: arHint,
            controller: arCtrl,
            height: 42,
            maxLines: 1,
            maxLength: 200,
            submitted: false,
            isRequired: false,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: _kGreenSolid,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  // ── Field Labels ──────────────────────────────────────────────────────────
  Widget _fieldLabel(String t) => Text(t,
      style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text));

  Widget _fieldLabelAr(String t) => Align(
    alignment: Alignment.centerRight,
    child: Text(t,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        )),
  );

  // ── Button ────────────────────────────────────────────────────────────────
  Widget _btn({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8.r)),
          child: Center(
            child: Text(label,
                style: StyleText.fontSize16Weight400
                    .copyWith(color: Colors.white)),
          ),
        ),
      );

  // ── Saving Overlay ────────────────────────────────────────────────────────
  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w, height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _kGreenSolid),
            SizedBox(height: 12.h),
            Text('Saving...',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}
