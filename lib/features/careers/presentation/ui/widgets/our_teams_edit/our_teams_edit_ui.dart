part of '../../pages/our_teams_edit.dart';

extension _OurTeamsEditUi on _OurTeamsEditPageState {
  Widget _itemWidget(int index, _TeamItemEdit item) {
    final iconHasError = _submitted && !item.icon.hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          Divider(color: const Color(0xFFE8E8E8), height: 1),
          SizedBox(height: 12.h),
        ] else
          SizedBox(height: 12.h),

        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: 'Heading', hint: 'Text Here', controller: item.headingEn,
              height: 36, fillColor: Colors.white, submitted: _submitted,
              textDirection: TextDirection.ltr, textAlign: TextAlign.left,
              primaryColor: ColorPick.primary, isRequired: true,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: 'العنوان', hint: 'أدخل النص هنا', controller: item.headingAr,
                height: 36, fillColor: Colors.white, submitted: _submitted,
                textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                primaryColor: ColorPick.primary, isRequired: true,
              ),
            ),
          ),
        ]),
        SizedBox(height: 14.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                  Text(' *', style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ]),
                SizedBox(height: 6.h),
                _imgBox(
                  picked: item.icon,
                  hasError: iconHasError,
                  onPick: () async {
                    final p = await _pickSvg();
                    if (p != null) setState(() { _isDirty = true; item.icon = p; });
                  },
                ),
                if (iconHasError) ...[
                  SizedBox(height: 4.h),
                  Text('Icon (SVG) is required', style: TextStyle(fontSize: 11.sp, color: ColorPick.red)),
                ],
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() { _isDirty = true; _items.removeAt(index); }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(color: ColorPick.red, borderRadius: BorderRadius.circular(4.r)),
                child: Text('Remove', style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        Row(children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: 'Title', hint: 'Text Here', controller: item.titleEn,
              height: 36, fillColor: Colors.white, submitted: _submitted,
              textDirection: TextDirection.ltr, textAlign: TextAlign.left,
              primaryColor: ColorPick.primary, isRequired: true,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: 'العنوان', hint: 'أدخل النص هنا', controller: item.titleAr,
                height: 36, fillColor: Colors.white, submitted: _submitted,
                textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                primaryColor: ColorPick.primary, isRequired: true,
              ),
            ),
          ),
        ]),
        SizedBox(height: 14.h),

        CustomValidatedTextFieldMaster(
          label: 'Description', hint: 'Text Here', controller: item.descEn,
          height: 80, maxLines: 3, fillColor: Colors.white, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          primaryColor: ColorPick.primary, isRequired: true,
        ),
        SizedBox(height: 8.h),

        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            label: 'الوصف', hint: 'أدخل النص هنا', controller: item.descAr,
            height: 80, maxLines: 3, fillColor: Colors.white, submitted: _submitted,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            primaryColor: ColorPick.primary, isRequired: true,
          ),
        ),
        SizedBox(height: 14.h),

        ...item.deliverables.asMap().entries.map((e) => _deliverableRow(e.key, e.value, item)),
        SizedBox(height: 8.h),

        GestureDetector(
          onTap: () => setState(() { _isDirty = true; item.deliverables.add(_DeliverableEdit(id: const Uuid().v4())); }),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(color: const Color(0xFF797979), borderRadius: BorderRadius.circular(4.r)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Deliverables', style: StyleText.fontSize13Weight500.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _deliverableRow(int index, _DeliverableEdit d, _TeamItemEdit item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: CustomValidatedTextFieldMaster(
              label: index == 0 ? 'Deliverable' : '', hint: 'Text Here',
              controller: d.enCtrl, height: 36, fillColor: Colors.white,
              submitted: _submitted, textDirection: TextDirection.ltr,
              textAlign: TextAlign.left, primaryColor: ColorPick.primary, isRequired: true,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomValidatedTextFieldMaster(
                label: index == 0 ? 'المخرجات' : '', hint: 'أدخل النص هنا',
                controller: d.arCtrl, height: 36, fillColor: Colors.white,
                submitted: _submitted, textDirection: TextDirection.rtl,
                textAlign: TextAlign.right, primaryColor: ColorPick.primary, isRequired: true,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => setState(() { _isDirty = true; item.deliverables.removeAt(index); }),
            child: Container(
              width: 20.w, height: 20.h,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgBox({required _PickedImage picked, bool hasError = false, VoidCallback? onPick}) {
    Widget content;
    if (picked.bytes != null) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(child: Padding(
          padding: EdgeInsets.all(15.r),
          child: SvgPicture.memory(picked.bytes!, width: 30.w, height: 30.h, fit: BoxFit.contain),
        )),
      );
    } else if (picked.url != null && picked.url!.isNotEmpty) {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(child: Padding(
          padding: EdgeInsets.all(15.r),
          child: SvgPicture.network(picked.url!, width: 30.w, height: 30.h, fit: BoxFit.contain,
              placeholderBuilder: (_) => const CircularProgressIndicator(strokeWidth: 2)),
        )),
      );
    } else {
      content = Container(
        width: 60.w, height: 60.h,
        decoration: BoxDecoration(
          color: hasError ? ColorPick.red.withValues(alpha: 0.08) : const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(Icons.add, color: hasError ? ColorPick.red : Colors.grey, size: 22.sp)),
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
              decoration: BoxDecoration(color: ColorPick.primary, shape: BoxShape.circle),
              child: Center(child: CustomSvg(assetPath: 'assets/control/camera.svg', width: 10.w, height: 10.h, fit: BoxFit.scaleDown)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accordion({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _accordionOpen = !_accordionOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                  Icon(
                    _accordionOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_accordionOpen)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ],
      ),
    );
  }

  Widget _bottomButtons(OurTeamsCubit cubit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(value: cubit, child: const OurTeamsPreviewPage()),
                )),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(color: ColorPick.preview, borderRadius: BorderRadius.circular(6.r)),
                  child: Center(child: Text('Preview', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: GestureDetector(
                onTap: _isSaving ? null : () => _handlePublish(cubit),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _isSaving ? ColorPick.primary.withValues(alpha: 0.5) : ColorPick.primary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(width: 18.w, height: 18.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Publish', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(color: ColorPick.discard, borderRadius: BorderRadius.circular(6.r)),
                  child: Center(child: Text('Discard', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(child: const SizedBox()),
          ],
        ),
      ],
    );
  }
}
