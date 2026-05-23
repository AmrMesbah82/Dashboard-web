part of '../../pages/job_listing_detail.dart';

class _DashboardTab extends StatelessWidget {
  final JobPostModel job;
  final List<ApplicationModel> applications;
  final bool loading;
  const _DashboardTab({
    required this.job,
    required this.applications,
    required this.loading,
  });

  int get _total => applications.length;
  int get _qualified =>
      applications.where((a) => a.status == ApplicationStatus.qualified).length;
  int get _unqualified => applications
      .where((a) => a.status == ApplicationStatus.unqualified)
      .length;
  int get _applied =>
      applications.where((a) => a.status == ApplicationStatus.applied).length;
  int get _interviewPassed => applications
      .where((a) => a.status == ApplicationStatus.interviewPassed)
      .length;
  int get _interviewFailed => applications
      .where((a) => a.status == ApplicationStatus.interviewFailed)
      .length;
  int get _interviewWithdrew => applications
      .where((a) => a.status == ApplicationStatus.interviewWithdrew)
      .length;
  int get _offerApproved => applications
      .where((a) => a.status == ApplicationStatus.offerApproved)
      .length;
  int get _offerPending => applications
      .where((a) => a.status == ApplicationStatus.offerPending)
      .length;
  int get _offerRejected => applications
      .where((a) => a.status == ApplicationStatus.offerRejected)
      .length;
  int get _hired =>
      applications.where((a) => a.status == ApplicationStatus.hired).length;
  int get _appliedStage => _applied + _qualified + _unqualified;
  int get _interviewStage =>
      _interviewPassed + _interviewFailed + _interviewWithdrew;
  int get _offerStage => _offerApproved + _offerPending + _offerRejected;

  Map<int, int> get _appsByMonth {
    final map = <int, int>{};
    for (final a in applications) {
      if (a.applicationDate != null) {
        final month = a.applicationDate!.month;
        map[month] = (map[month] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get _scoreDistribution {
    int poor = 0, weak = 0, good = 0, veryGood = 0, excellent = 0;
    for (final a in applications) {
      final avg =
      (a.technicalSkills +
          a.communicationSkills +
          a.experienceBackground +
          a.cultureFit +
          a.leadershipPotential);
      if (avg == 0) continue;
      final score = avg / 5.0;
      if (score <= 1)
        poor++;
      else if (score <= 2)
        weak++;
      else if (score <= 3)
        good++;
      else if (score <= 4)
        veryGood++;
      else
        excellent++;
    }
    return {
      'Poor': poor,
      'Weak': weak,
      'Good': good,
      'Very Good': veryGood,
      'Excellent': excellent,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.sp),
          child: const CircularProgressIndicator(color: ColorPick.primary),
        ),
      );
    if (applications.isEmpty)
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.sp),
          child: Text(
            'No applications yet for this job.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText),
          ),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartRow(
          left: _buildApplicationsReceived(),
          right: _buildCandidateClassification(),
        ),
        SizedBox(height: 16.h),
        _chartRow(left: _buildHiringStage(), right: _buildInterviewStage()),
        SizedBox(height: 16.h),
        _chartRow(
          left: _buildJobOffer(),
          right: _buildScoreDistributionChart(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _chartRow({required Widget left, required Widget right}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: left),
      SizedBox(width: 16.w),
      Expanded(child: right),
    ],
  );

  Widget _buildApplicationsReceived() {
    final labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final byMonth = _appsByMonth;
    final values = List.generate(12, (i) => (byMonth[i + 1] ?? 0).toDouble());
    final maxY =
    ((values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b)) + 10)
        .toDouble();
    return _card(
      title: 'Applications Received',
      subtitle: 'Total: ${_fmtNum(_total)}',
      height: 280,
      child: Expanded(
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barGroups: values
                .asMap()
                .entries
                .map(
                  (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    width: 14.sp,
                    color: _Ch.green,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ],
                showingTooltipIndicators: e.value > 0 ? [0] : [],
              ),
            )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35.sp,
                  interval: maxY > 50 ? (maxY / 5).ceilToDouble() : 10,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22.sp,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    return i >= 0 && i < 12
                        ? Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.grey,
                      ),
                    )
                        : const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY > 50 ? (maxY / 5).ceilToDouble() : 10,
              getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFEFF3F9), strokeWidth: 1),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 4,
                getTooltipColor: (_) => Colors.transparent,
                tooltipBorder: BorderSide.none,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  rod.toY.toInt().toString(),
                  TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: _Ch.darkGreen,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateClassification() {
    final qualifiedCount =
        _qualified + _interviewPassed + _offerApproved + _offerPending + _hired;
    final unqualifiedCount =
        _unqualified + _interviewFailed + _interviewWithdrew + _offerRejected;
    final totalClassified = qualifiedCount + unqualifiedCount;
    final qPct = totalClassified > 0
        ? (qualifiedCount / totalClassified * 100).round()
        : 0;
    final uPct = totalClassified > 0 ? 100 - qPct : 0;
    return _card(
      title: 'Candidate Classification',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendRow(_Ch.green, '$qPct%', 'Qualified'),
                  SizedBox(height: 12.h),
                  _legendRow(_Ch.grey, '$uPct%', 'Unqualified'),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 44.sp,
                      sections: [
                        PieChartSectionData(
                          value: qualifiedCount.toDouble().clamp(
                            0.1,
                            double.infinity,
                          ),
                          color: _Ch.green,
                          radius: 30.sp,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: unqualifiedCount.toDouble().clamp(
                            0.1,
                            double.infinity,
                          ),
                          color: _Ch.grey,
                          radius: 30.sp,
                          title: '',
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total\nApplication',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9.sp, color: Colors.black54),
                      ),
                      Text(
                        _fmtNum(_total),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHiringStage() {
    // ── Rejected = unqualified + interview failed + offer rejected + interview withdrew
    final rejected = _unqualified + _interviewFailed + _offerRejected + _interviewWithdrew;

    final stages = [
      _FunnelItem('Applied', _appliedStage, _Ch.darkGreen),
      _FunnelItem('Interviewed', _interviewStage, const Color(0xFF2E7D32)),
      _FunnelItem('Rejected', rejected, _Ch.lightGreen),
      _FunnelItem('Offer Sent', _offerStage, const Color(0xFF4CAF50)),
      _FunnelItem('Hired', _hired, const Color(0xFFA5D6A7)),
    ];

    final maxVal = stages
        .map((s) => s.value)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, 999999);

    return _card(
      title: 'Hiring Stage',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            // ── Legend column ──
            SizedBox(
              width: 100.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stages
                    .map(
                      (s) => Padding(
                    padding: EdgeInsets.only(bottom: 10.sp),
                    child: Row(
                      children: [
                        Container(
                          width: 10.sp,
                          height: 10.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.color,
                          ),
                        ),
                        SizedBox(width: 6.sp),
                        Expanded(
                          child: Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
            // ── Funnel bars (centered, decreasing width) ──
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fullWidth = constraints.maxWidth;
                  // Each stage gets a fraction of the max width,
                  // decreasing from top to bottom (funnel effect)
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(stages.length, (i) {
                      // Funnel: width decreases linearly from 100% to ~30%
                      final funnelFraction =
                          1.0 - (i / (stages.length)) * 0.7;
                      final barWidth = fullWidth * funnelFraction;
                      final barHeight = 32.sp;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 4.sp),
                        child: ClipPath(
                          clipper: _TrapezoidClipper(
                            // Next stage width ratio for trapezoid bottom
                            bottomWidthFraction: i < stages.length - 1
                                ? (1.0 -
                                ((i + 1) / (stages.length)) * 0.7)
                                : (1.0 - (i / (stages.length)) * 0.7) *
                                0.85,
                            topWidthFraction: funnelFraction,
                          ),
                          child: Container(
                            width: fullWidth,
                            height: barHeight,
                            color: stages[i].color,
                            child: Center(
                              child: Text(
                                _fmtNum(stages[i].value),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewStage() {
    final passed = _interviewPassed;
    final failed = _interviewFailed;
    final withdrew = _interviewWithdrew;
    final total = passed + failed + withdrew;
    final pPct = total > 0 ? (passed / total * 100).round() : 0;
    final fPct = total > 0 ? (failed / total * 100).round() : 0;
    final wPct = total > 0 ? 100 - pPct - fPct : 0;
    return _card(
      title: 'Interview Stage',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendRow(_Ch.green, '$pPct%', 'Passed'),
                  SizedBox(height: 8.h),
                  _legendRow(_Ch.lightGreen, '$fPct%', 'Failed'),
                  SizedBox(height: 8.h),
                  _legendRow(_Ch.grey, '$wPct%', 'Candidate Withdrew'),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  sections: [
                    PieChartSectionData(
                      value: passed.toDouble().clamp(0.1, double.infinity),
                      color: _Ch.green,
                      radius: 60.sp,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: failed.toDouble().clamp(0.1, double.infinity),
                      color: _Ch.lightGreen,
                      radius: 60.sp,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: withdrew.toDouble().clamp(0.1, double.infinity),
                      color: _Ch.grey,
                      radius: 60.sp,
                      title: '',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOffer() {
    final items = [
      _PieItem('Approved', _offerApproved.toDouble(), _Ch.green),
      _PieItem('Pending', _offerPending.toDouble(), _Ch.yellow),
      _PieItem('Rejected', _offerRejected.toDouble(), _Ch.red),
    ];
    final sum = _offerApproved + _offerPending + _offerRejected;
    return _card(
      title: 'Job Offer',
      height: 280,
      child: Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map(
                      (item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.sp),
                    child: Row(
                      children: [
                        Container(
                          width: 10.sp,
                          height: 10.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.color,
                          ),
                        ),
                        SizedBox(width: 6.sp),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          _fmtNum(item.value.toInt()),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40.sp,
                      sections: items
                          .map(
                            (item) => PieChartSectionData(
                          value: item.value.clamp(0.1, double.infinity),
                          color: item.color,
                          radius: 28.sp,
                          title: '',
                        ),
                      )
                          .toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmtNum(sum),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistributionChart() {
    final dist = _scoreDistribution;
    final segments = [
      _ScoreSegment('Poor', dist['Poor'] ?? 0, _Ch.poor),
      _ScoreSegment('Weak', dist['Weak'] ?? 0, _Ch.weak),
      _ScoreSegment('Good', dist['Good'] ?? 0, _Ch.good),
      _ScoreSegment('Very Good', dist['Very Good'] ?? 0, _Ch.veryGood),
      _ScoreSegment('Excellent', dist['Excellent'] ?? 0, _Ch.excellent),
    ];
    final total = segments.fold<int>(0, (s, e) => s + e.value);
    return _card(
      title: 'Candidate Score Distribution',
      height: 280,
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: segments
                  .map(
                    (s) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.sp,
                      height: 10.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color,
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      _fmtNum(s.value),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Row(
                children: total > 0
                    ? segments
                    .map(
                      (s) => Flexible(
                    flex: s.value.clamp(1, 999999),
                    child: Container(height: 20.sp, color: s.color),
                  ),
                )
                    .toList()
                    : [
                  Expanded(
                    child: Container(
                      height: 20.sp,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required double height,
    required Widget child,
    String? subtitle,
  }) {
    final innerChild = child is Expanded ? child.child : child;
    return Container(
      height: height.h,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333333),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.sp, color: Colors.black45),
            ),
          ],
          SizedBox(height: 10.h),
          Expanded(child: innerChild),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String percent, String label) => Row(
    children: [
      Container(
        width: 12.sp,
        height: 12.sp,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      SizedBox(width: 6.sp),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            percent,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.black54),
          ),
        ],
      ),
    ],
  );

  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
