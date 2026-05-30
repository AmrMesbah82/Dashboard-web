part of '../../pages/strategy_page/strategy_edit.dart';

extension _StrategyFormHelpers on _StrategyEditPageState {
  // ── File picker — SVG only ────────────────────────────────────────────────
  Future<Uint8List?> _pickSvgFile() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = '.svg,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }

      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.svg')) {
        showConfirmDialog(
          context: context,
          title: 'Invalid File',
          subtitle:
          'Please upload SVG files only! You selected: ${file.name}',
          confirmLabel: 'OK',
          cancelLabel: '',
          onConfirm: () {},
          iconWidget: Container(
            width: 60.r,
            height: 60.r,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child:
            Icon(Icons.error_outline, color: Colors.white, size: 36.r),
          ),
        );
        c.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) bytes = r.asUint8List();
        else if (r is Uint8List) bytes = r;
        c.complete(bytes);
      });
      reader.onError.listen((e) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  // ── Image picker (all types) ──────────────────────────────────────────────
  Future<Uint8List?> _pickImage() async {
    final c = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        c.complete(null);
        return;
      }
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final r = reader.result;
        Uint8List? bytes;
        if (r is ByteBuffer) bytes = r.asUint8List();
        else if (r is Uint8List) bytes = r;
        c.complete(bytes);
      });
      reader.onError.listen((e) => c.complete(null));
    });
    input.click();
    return c.future;
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: ColorPick.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22.sp),
            ],
          ),
        ),
      ),
      if (isOpen)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          padding: EdgeInsets.only(top: 16.h),
          child: child,
        ),
    ]);
  }

  // ── Device Tab Bar ────────────────────────────────────────────────────────
  Widget _deviceTabBar({
    required DeviceTab selected,
    required ValueChanged<DeviceTab> onChanged,
  }) {
    Widget tab(String label, DeviceTab value) {
      final isActive = selected == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isActive ? ColorPick.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          tab('Large Screen', DeviceTab.largeScreen),
          SizedBox(width: 4.w),
          tab('Tablet', DeviceTab.tablet),
          SizedBox(width: 4.w),
          tab('Mobile', DeviceTab.mobile),
        ],
      ),
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
            hint: enHint,
            controller: enCtrl,
            height: 42,
            maxLines: 1,
            fillColor: Colors.white,
            maxLength: 200,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomValidatedTextFieldMaster(
            hint: arHint,
            controller: arCtrl,
            height: 42,
            maxLines: 1,
            fillColor: Colors.white,
            maxLength: 200,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

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
              color: color,
              borderRadius: BorderRadius.circular(10.r)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      );

  Widget _savingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        width: 180.w,
        height: 100.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: ColorPick.primary),
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
