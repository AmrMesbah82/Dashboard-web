import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/custom_svg.dart';
import '../theme/appcolors.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kDivider    = Color(0xFFDDE8DD);

// ─── Job Data ─────────────────────────────────────────────────────────────────

class _JobData {
  final String title;
  final String category;        // 'Business' | 'Design' | 'Development'
  final String hireDate;
  final String employmentType;
  final String yearsOfExperience;
  final String compensationRange;
  final String requiredQualification;
  final List<String> skills;
  final String location;
  const _JobData({
    required this.title,
    required this.category,
    required this.hireDate,
    required this.employmentType,
    required this.yearsOfExperience,
    required this.compensationRange,
    required this.requiredQualification,
    required this.skills,
    required this.location,
  });
}

const List<_JobData> _jobs = [
  _JobData(
    title: 'UI and UX Designer',
    category: 'Design',
    hireDate: '28 Aug 2026',
    employmentType: 'Remotely',
    yearsOfExperience: '3 Years',
    compensationRange: '5000',
    requiredQualification: 'Have a degree related to Design',
    skills: ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
    location: 'Cairo, Egypt',
  ),
  _JobData(
    title: 'Business Analyst',
    category: 'Business',
    hireDate: '15 Sep 2026',
    employmentType: 'On-Site',
    yearsOfExperience: '2 Years',
    compensationRange: '6000',
    requiredQualification: 'Have a degree related to Business',
    skills: ['Excel', 'Power BI', 'SQL', 'Stakeholder Management'],
    location: 'Cairo, Egypt',
  ),
  _JobData(
    title: 'Flutter Developer',
    category: 'Development',
    hireDate: '01 Oct 2026',
    employmentType: 'Hybrid',
    yearsOfExperience: '4 Years',
    compensationRange: '8000',
    requiredQualification: 'Have a degree related to Computer Science',
    skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
    location: 'Cairo, Egypt',
  ),
  _JobData(
    title: 'Digital Marketing Specialist',
    category: 'Business',
    hireDate: '20 Sep 2026',
    employmentType: 'Remotely',
    yearsOfExperience: '2 Years',
    compensationRange: '4500',
    requiredQualification: 'Have a degree related to Marketing',
    skills: ['SEO', 'Google Ads', 'Social Media', 'Analytics'],
    location: 'Cairo, Egypt',
  ),
  _JobData(
    title: 'Backend Developer',
    category: 'Development',
    hireDate: '10 Oct 2026',
    employmentType: 'On-Site',
    yearsOfExperience: '3 Years',
    compensationRange: '9000',
    requiredQualification: 'Have a degree related to Computer Science',
    skills: ['Node.js', 'PostgreSQL', 'Docker', 'AWS'],
    location: 'Cairo, Egypt',
  ),
  _JobData(
    title: 'Graphic Designer',
    category: 'Design',
    hireDate: '05 Oct 2026',
    employmentType: 'Hybrid',
    yearsOfExperience: '1 Year',
    compensationRange: '3500',
    requiredQualification: 'Have a degree related to Graphic Design',
    skills: ['Illustrator', 'Photoshop', 'Branding', 'Typography'],
    location: 'Cairo, Egypt',
  ),
];

// ─── Job Listings Page ────────────────────────────────────────────────────────

class JobListingsPage extends StatefulWidget {
  const JobListingsPage({super.key});

  @override
  State<JobListingsPage> createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> {
  String _selectedFilter = 'All';
  static const List<String> _filters = ['All', 'Business', 'Design', 'Development'];

  List<_JobData> get _filteredJobs => _selectedFilter == 'All'
      ? _jobs
      : _jobs.where((j) => j.category == _selectedFilter).toList();

  @override
  Widget build(BuildContext context) {
    final double contentW = (339.w * 4) + (12.w * 3);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppNavbar(currentRoute: '/careers'),
            SizedBox(height: 48.h),

            // ── Hero heading ────────────────────────────────────────────
            Center(
              child: SizedBox(
                width: contentW,
                child: Text(
                  'Unlock Your Potential in the Digital World',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // ── Filter tabs ─────────────────────────────────────────────
            Center(
              child: SizedBox(
                width: contentW,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _kDivider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _filters.map((f) {
                      final bool selected = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 4.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? _kGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),

            // ── Section title ───────────────────────────────────────────
            Center(
              child: SizedBox(
                width: contentW,
                child: Text(
                  'Job Listings at Bayanatz',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── Job cards ───────────────────────────────────────────────
            Center(
              child: SizedBox(
                width: contentW,
                child: Column(
                  children: _filteredJobs.isEmpty
                      ? [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      child: Text(
                        'No jobs found for "$_selectedFilter"',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          color: Colors.black45,
                        ),
                      ),
                    )
                  ]
                      : _filteredJobs
                      .map((j) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _JobCard(data: j),
                  ))
                      .toList(),
                ),
              ),
            ),

            SizedBox(height: 64.h),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Job Card ─────────────────────────────────────────────────────────────────

class _JobCard extends StatefulWidget {
  final _JobData data;
  const _JobCard({required this.data});
  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(25.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          // ── border removed ──
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.data.title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20.sp,          // +2
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Color(0xFF008037),
                    borderRadius: BorderRadius.circular(8.r),
                    // ── border removed ──
                  ),
                  child: Icon(Icons.share_outlined, size: 18.sp, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            Divider(color: _kDivider, height: 1),
            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(child: _InfoItem(label: 'Expected Hire Date',   value: widget.data.hireDate)),
                Expanded(child: _InfoItem(label: 'Year Of Experience',   value: widget.data.yearsOfExperience)),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: _InfoItem(label: 'Employment Type',      value: widget.data.employmentType)),
                Expanded(child: _InfoItem(label: 'Compensation Range',   value: widget.data.compensationRange)),
              ],
            ),
            SizedBox(height: 10.h),

            _InfoItem(label: 'Required Qualification', value: widget.data.requiredQualification),
            SizedBox(height: 14.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Skills:',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,          // +2
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 10.w),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: widget.data.skills.map((s) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6.r),
                      // ── border removed ──
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,      // +2
                        color: Colors.black87,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomSvg(
                      assetPath: "assets/images/careers/location.svg",
                      width: 21.w, height: 26.h, fit: BoxFit.fill,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.data.location,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,      // +2
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                _ViewJobBtn(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Item ────────────────────────────────────────────────────────────────

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,              // +2
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,              // +2
              fontWeight: FontWeight.w600,
              color: _kGreen,
            ),
          ),
        ],
      ),
    );
  }
}




// ─── View Job Button ──────────────────────────────────────────────────────────

class _ViewJobBtn extends StatefulWidget {
  @override
  State<_ViewJobBtn> createState() => _ViewJobBtnState();
}

class _ViewJobBtnState extends State<_ViewJobBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF1B6B38) : _kGreen,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'VIEW JOB',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}