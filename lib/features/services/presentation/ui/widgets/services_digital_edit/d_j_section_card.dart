part of '../../pages/digital_services/services_digital_edit.dart';

class _DJSectionCard extends StatefulWidget {
  final String           lastUpdated;
  final ServicePageModel model;
  final VoidCallback     onEditTap;

  const _DJSectionCard({
    required this.lastUpdated,
    required this.model,
    required this.onEditTap,
  });

  @override
  State<_DJSectionCard> createState() => _DJSectionCardState();
}

class _DJSectionCardState extends State<_DJSectionCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border:       Border.all(color: ColorPick.white),
      ),
      child: Column(
        children: [
          // ── Header bar ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: _open
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                )
                    : BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Digital Journey',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize:   14.sp,
                          fontWeight: FontWeight.w600,
                          color:      Colors.white)),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          if (_open) ...[
            // ── Last updated + Edit button ───────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.lastUpdated,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize:   11.sp,
                          color:      AppColors.secondaryBlack)),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onEditTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: ColorPick.primary,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Text('Edit Details',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize:   12.sp,
                                  fontWeight: FontWeight.w600,
                                  color:      Colors.white)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.settings,
                          size: 18.sp,
                          color: AppColors.secondaryBlack),
                    ],
                  ),
                ],
              ),
            ),

            // ── Journey item grid ────────────────────────────────────
            if (widget.model.journeyItems.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: _JourneyGrid(items: widget.model.journeyItems),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Journey Grid (4-column preview) ─────────────────────────────────────────
