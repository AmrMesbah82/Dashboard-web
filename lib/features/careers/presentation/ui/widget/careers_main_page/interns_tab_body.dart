part of '../../pages/careers_main_page.dart';

class _InternsTabBody extends StatefulWidget {
  @override
  State<_InternsTabBody> createState() => _InternsTabBodyState();
}

class _InternsTabBodyState extends State<_InternsTabBody> {
  bool   _isGrid     = true;
  String _search     = '';
  final  _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<InternModel> _filtered(List<InternModel> all) {
    if (_search.isEmpty) return all;
    final q = _search.toLowerCase();
    return all
        .where((i) =>
    i.fullName.toLowerCase().contains(q) ||
        i.position.toLowerCase().contains(q) ||
        i.degrees.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternCubit, InternState>(
      listener: (context, state) {
        if (state is InternError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red,
          ));
        }
      },
      builder: (context, state) {
        List<InternModel> interns = [];
        bool loading = false;

        if (state is InternLoading) loading = true;
        if (state is InternLoaded)  interns = state.interns;
        if (state is InternCreated) interns = state.interns;
        if (state is InternUpdated) interns = state.interns;
        if (state is InternDeleted) interns = state.interns;

        final cubit    = context.read<InternCubit>();
        final filtered = _filtered(interns);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Row(children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
                  child: Row(children: [
                    SizedBox(width: 12.w),
                    Icon(Icons.search, color: AppColors.secondaryText, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: StyleText.fontSize13Weight400.copyWith(color: AppColors.text),
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                  ]),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                    color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
                child: Center(
                  child: Text('Time Frame',
                      style: StyleText.fontSize13Weight500.copyWith(color: Colors.white)),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                      value: cubit, child: const AddInternPage()),
                )),
                child: Container(
                  height: 40.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                      color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
                  child: Center(
                    child: Text('Add New Intern',
                        style: StyleText.fontSize13Weight500.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ]),
            SizedBox(height: 14.h),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: ColorPick.white, borderRadius: BorderRadius.circular(6.r)),
                  child: Text(
                    'Total Interns:  ${filtered.length}',
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.text),
                  ),
                ),
                const Spacer(),
                customButtonWithImage(
                  title: 'Export',
                  function: () => showDialog(context: context,
                      builder: (_) => _InternExportDialog(interns: filtered)),
                  textStyle: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  height: 32.h, space: 4.w, radius: 6,
                  color: ColorPick.primary, image: 'assets/images/export.svg',
                  widthImage: 14.sp, heightImage: 14.sp,
                  colorBorder: ColorPick.primary, svgColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                ),
                SizedBox(width: 8.w),
                customButtonWithImage(
                  title: '', function: () => setState(() => _isGrid = true),
                  textStyle: const TextStyle(),
                  height: 32.sp, width: 32.sp, space: 0, radius: 6,
                  color: _isGrid ? ColorPick.primary : ColorPick.white,
                  image: 'assets/images/grid.svg',
                  widthImage: 16.sp, heightImage: 16.sp,
                  colorBorder: Colors.transparent,
                  svgColor: _isGrid ? Colors.white : AppColors.secondaryText,
                ),
                SizedBox(width: 4.w),
                customButtonWithImage(
                  title: '', function: () => setState(() => _isGrid = false),
                  textStyle: const TextStyle(),
                  height: 32.sp, width: 32.sp, space: 0, radius: 6,
                  color: !_isGrid ? ColorPick.primary : ColorPick.white,
                  image: 'assets/images/table.svg',
                  widthImage: 16.sp, heightImage: 16.sp,
                  colorBorder: Colors.transparent,
                  svgColor: !_isGrid ? Colors.white : AppColors.secondaryText,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            if (loading)
              const Center(child: CircularProgressIndicator(color: ColorPick.primary))
            else if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40.w),
                  child: Text(
                    _search.isEmpty
                        ? 'No interns yet. Tap "Add New Intern" to get started.'
                        : 'No results for "$_search".',
                    style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_isGrid)
                _GridView(interns: filtered, cubit: cubit)
              else
                _InternTableView(interns: filtered, cubit: cubit),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRID VIEW  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
