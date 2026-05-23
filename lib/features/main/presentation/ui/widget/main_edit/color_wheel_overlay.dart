part of '../../pages/main_edit.dart';

class _ColorWheelOverlay extends StatefulWidget {
  final LayerLink layerLink;
  final Color initialColor;
  final ValueChanged<Color> onApply;
  final VoidCallback onClose;

  const _ColorWheelOverlay({
    required this.layerLink,
    required this.initialColor,
    required this.onApply,
    required this.onClose,
  });

  @override
  State<_ColorWheelOverlay> createState() => _ColorWheelOverlayState();
}

class _ColorWheelOverlayState extends State<_ColorWheelOverlay> {
  late Color _picked;

  @override
  void initState() { super.initState(); _picked = widget.initialColor; }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: widget.onClose,
          behavior: HitTestBehavior.translucent,
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ),
      Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: 400.w,
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: ColorPick.white),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select Color',
                        style: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.text)),
                    SizedBox(height: 16.h),
                    LayoutBuilder(builder: (context, constraints) {
                      final double pickerW =
                      (constraints.maxWidth).clamp(200.0, 320.0);
                      return SizedBox(
                        width: pickerW,
                        child: ColorPicker(
                          pickerColor: _picked,
                          onColorChanged: (c) => setState(() => _picked = c),
                          colorPickerWidth: pickerW,
                          pickerAreaHeightPercent: 0.65,
                          enableAlpha: false,
                          displayThumbColor: true,
                          portraitOnly: true,
                          pickerAreaBorderRadius: BorderRadius.circular(8.r),
                          hexInputBar: true,
                          labelTypes: const [],
                        ),
                      );
                    }),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: ColorPick.white),
                            ),
                            child: Text('Cancel',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: AppColors.text)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => widget.onApply(_picked),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            decoration: BoxDecoration(
                                color: ColorPick.primary,
                                borderRadius: BorderRadius.circular(6.r)),
                            child: Text('Apply',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeEditPage
// ─────────────────────────────────────────────────────────────────────────────
