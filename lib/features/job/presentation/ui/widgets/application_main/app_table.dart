// ******************* FILE INFO *******************
// Part of: application_main.dart
// Contains: _buildGrid, _buildTable

part of '../../pages/application_main.dart';

extension _ApplicationMainTable on _ApplicationMainPageState {
  // ── Card Grid (3 columns) ─────────────────────────────────────────────────
  Widget _buildGrid(List<ApplicationModel> apps) {
    final rows = (apps.length / 3).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final start = rowIndex * 3;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(3, (colIndex) {
                final i = start + colIndex;
                if (i >= apps.length) return const Expanded(child: SizedBox());
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIndex < 2 ? 12.w : 0),
                    child: _AppCard(
                      app: apps[i],
                      onTap: () => navigateTo(
                          context,
                          ApplicationDetailPage(
                              jobId: apps[i].jobId, appId: apps[i].id)),
                      onDownload: () => _downloadPdf(apps[i]),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  // ── Table View ─────────────────────────────────────────────────────────────
  Widget _buildTable(List<ApplicationModel> apps) {
    final headers = [
      'No', 'Candidate', 'Email', 'Phone', 'Department',
      'Job Title', 'Work Type', 'Location', 'Employment Type',
      'Experience Level', 'Salary Range', 'Application Date', 'Status', 'Download',
    ];

    final columnWidths = <int, TableColumnWidth>{
      0:  FixedColumnWidth(50.sp),
      1:  FixedColumnWidth(140.sp),
      2:  FixedColumnWidth(200.sp),
      3:  FixedColumnWidth(150.sp),
      4:  FixedColumnWidth(120.sp),
      5:  FixedColumnWidth(150.sp),
      6:  FixedColumnWidth(100.sp),
      7:  FixedColumnWidth(120.sp),
      8:  FixedColumnWidth(130.sp),
      9:  FixedColumnWidth(120.sp),
      10: FixedColumnWidth(120.sp),
      11: FixedColumnWidth(110.sp),
      12: FixedColumnWidth(110.sp),
      13: FixedColumnWidth(90.sp),
    };

    TextStyle cellStyle = TextStyle(fontSize: 11.sp, color: AppColors.text);

    Widget cell(Widget child) => Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(style: cellStyle, child: child),
    );

    Widget textCell(String text) => cell(
      Text(text.isEmpty ? '-' : text, maxLines: 2, overflow: TextOverflow.ellipsis),
    );

    Color statusColor(ApplicationStatus status) {
      switch (status) {
        case ApplicationStatus.hired:
          return Colors.green.shade600;
        case ApplicationStatus.unqualified:
        case ApplicationStatus.interviewFailed:
        case ApplicationStatus.offerRejected:
          return Colors.red.shade600;
        case ApplicationStatus.interviewPassed:
        case ApplicationStatus.interviewWithdrew:
          return Colors.blue.shade600;
        case ApplicationStatus.offerApproved:
        case ApplicationStatus.offerPending:
          return Colors.orange.shade600;
        case ApplicationStatus.qualified:
          return Colors.teal.shade600;
        case ApplicationStatus.applied:
        default:
          return ColorPick.primary;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [
            // ── Header Row ──
            TableRow(
              decoration: const BoxDecoration(color: ColorPick.primary),
              children: headers.map((h) => Padding(
                padding: EdgeInsets.all(10.sp),
                child: Text(
                  h,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )).toList(),
            ),

            // ── Data Rows ──
            ...List.generate(apps.length, (index) {
              final a = apps[index];
              final isEven = index.isEven;
              final rowColor = isEven ? const Color(0xFFF7F8FA) : Colors.white;

              final dateStr = a.applicationDate != null
                  ? '${a.applicationDate!.day}/${a.applicationDate!.month}/${a.applicationDate!.year}'
                  : '-';

              final cells = [
                textCell('${index + 1}'),
                textCell(a.fullName),
                textCell(a.email),
                textCell('${a.countryCode}${a.phone}'),
                textCell(a.department),
                textCell(a.jobTitle),
                textCell(a.workType),
                textCell(a.jobLocation),
                textCell(a.employmentType),
                textCell(a.experienceLevel),
                textCell(a.salaryRange),
                textCell(dateStr),
                cell(
                  Text(
                    a.status.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor(a.status),
                    ),
                  ),
                ),
                cell(
                  InkWell(
                    onTap: () => _downloadPdf(a),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: ColorPick.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, size: 12.sp, color: Colors.white),
                          SizedBox(width: 2.w),
                          Text('PDF',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ];

              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: List.generate(cells.length, (ci) {
                  if (ci < cells.length - 1) {
                    return InkWell(
                      onTap: () => navigateTo(context,
                          ApplicationDetailPage(jobId: a.jobId, appId: a.id)),
                      child: cells[ci],
                    );
                  }
                  return cells[ci];
                }),
              );
            }),
          ],
        ),
      ),
    );
  }
}
