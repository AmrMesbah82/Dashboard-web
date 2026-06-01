part of '../../pages/home_edit.dart';

extension _HomeEditActions on _HomeEditPageMasterState {
  Widget _publishScheduleSection() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text('Publish Date',
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = DatePicker();
                      final picked = await picker.showDatePicker(
                        context,
                        _publishDate != null ? [_publishDate] : [],
                        _publishDate ?? DateTime.now(),
                        CalendarDatePicker2Type.single,
                        firstDate: DateTime.now(),
                      );
                      if (picked != null && picked.isNotEmpty && picked.first != null) {
                        setState(() => _publishDate = picked.first);
                      }
                    },
                    child: Container(
                      height: 36.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _publishDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_publishDate!)
                                  : 'Select Date',
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: _publishDate != null
                                    ? AppColors.text
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ),
                          CustomSvg(
                            assetPath: 'assets/control/Calendar.svg',
                            width: 20.w, height: 20.h, fit: BoxFit.scaleDown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_publishDate != null) ...[
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() => _publishDate = null),
                    child: Container(
                      height: 36.h, width: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Center(child: Icon(Icons.close, color: Colors.red, size: 16.sp)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      SizedBox(width: 15.sp),
      Expanded(child: Container()),
    ],
  );

  Widget _bottomButtons(HomeCmsCubit cubit) {
    final bool canPublish = _isFormValid;
    final bool isScheduled =
        _publishDate != null && _publishDate!.isAfter(DateTime.now());

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => navigateTo(context, HomePreviewPageMaster()),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF608570),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(child: Text('Preview',
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: AbsorbPointer(
                absorbing: !canPublish || _isSaving,
                child: Opacity(
                  opacity: (canPublish && !_isSaving) ? 1.0 : 0.6,
                  child: GestureDetector(
                    onTap: () {
                      if (!canPublish) {
                        setState(() => _submitted = true);
                        return;
                      }
                      showPublishConfirmDialog(
                        context: context,
                        title: isScheduled ? 'SCHEDULE PAGE' : 'PUBLISH PAGE',
                        subtitle: isScheduled
                            ? 'Your changes will be scheduled for ${DateFormat('dd/MM/yyyy').format(_publishDate!)}. The published version will remain live until then.'
                            : 'Do you want to publish this page now?',
                        confirmLabel: isScheduled ? 'Schedule' : 'Publish',
                        onConfirm: () => _save(
                          cubit,
                          publishStatus: 'published',
                          scheduledPublishDate: _publishDate,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: _isSaving
                            ? (isScheduled
                                  ? ColorPick.scheduled.withValues(alpha: .5)
                                  : ColorPick.primary.withValues(alpha: 0.5))
                            : (isScheduled ? ColorPick.scheduled : ColorPick.primary),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          isScheduled ? 'Schedule' : 'Publish',
                          style: StyleText.fontSize14Weight600.copyWith(
                            color: Colors.white.withValues(alpha: 
                              (canPublish && !_isSaving) ? 1.0 : 0.55,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                onTap: () {
                  if (_isEditingDraft) {
                    showPublishConfirmDialog(
                      context: context,
                      title: 'DISCARD DRAFT',
                      subtitle:
                          'Are you sure you want to discard this draft? The published version will remain unchanged.',
                      confirmLabel: 'Discard',
                      onConfirm: () => cubit.discardDraft(),
                    );
                  } else {
                    showConfirmDialog(
                      context: context,
                      title: 'Discard Changes',
                      subtitle: 'Are you sure you want to discard all changes?',
                      confirmLabel: 'Discard',
                      cancelLabel: 'Cancel',
                      onConfirm: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeMainPageMaster()),
                          );
                        }
                      },
                    );
                  }
                },
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF797979),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(child: Text('Discard',
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                ),
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: GestureDetector(
                onTap: _isSaving
                    ? null
                    : () {
                        showPublishConfirmDialog(
                          context: context,
                          title: 'SAVE AS DRAFT',
                          subtitle:
                              'Your changes will be saved as a draft. The published version will remain live and unchanged.',
                          confirmLabel: 'Save Draft',
                          onConfirm: () => _save(cubit, publishStatus: 'draft'),
                        );
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: _isSaving ? Colors.grey.shade400 : const Color(0xFF525252),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(child: Text('Save For Later',
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(title,
                      style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _gap() => SizedBox(height: 10.h);
}
