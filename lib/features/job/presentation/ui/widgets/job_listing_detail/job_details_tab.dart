part of '../../pages/job_listing_detail.dart';

class _JobDetailsTab extends StatelessWidget {
  final JobPostModel job;
  const _JobDetailsTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(title: 'Job Information', child: _jobInfoContent()),
        SizedBox(height: 10.h),
        _SectionCard(title: 'Job Details', child: _jobDetailsContent()),
        SizedBox(height: 10.h),
        if (job.benefits.isNotEmpty) ...[
          _SectionCard(title: 'Benefits', child: _benefitsContent()),
          SizedBox(height: 10.h),
        ],
        _SectionCard(title: 'Application Details', child: _appDetailsContent()),
      ],
    );
  }

  Widget _jobInfoContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _row(
            _infoField('Job Title', job.title.en),
            _infoFieldRtl('المسمى الوظيفي', job.title.ar),
          ),
          const SizedBox(height: 12),
          _row(
            _infoField(
              'Department',
              job.department.isEmpty ? '—' : job.department,
            ),
            _infoField('Work Type', job.workType.label),
          ),
          const SizedBox(height: 12),
          _row(
            _infoField('Employment Type', job.employmentType.label),
            _infoField(
              'Employment Duration',
              job.employmentDurationText.isNotEmpty
                  ? '${job.employmentDurationText} ${job.employmentDurationType.label}'
                  : job.employmentDurationType.label,
            ),
          ),
          const SizedBox(height: 12),
          _row(
            _infoField('Experience Level', job.experienceLevel.label),
            _infoField(
              'Salary Range',
              job.salaryMax > 0
                  ? '${job.salaryMin.toInt()} – ${job.salaryMax.toInt()} ${job.salaryCurrency}'
                  : '—',
            ),
          ),
          const SizedBox(height: 12),
          _row(
            _infoField('Required Qualification', job.requiredQualification.en),
            _infoFieldRtl('المؤهلات المطلوبة', job.requiredQualification.ar),
          ),
          if (job.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _skillsRow(),
          ],
        ],
      ),
    );
  }

  Widget _jobDetailsContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _infoField(
            'About This Position',
            job.aboutThisPosition.en,
            multi: true,
          ),
          const SizedBox(height: 12),
          _infoField('Requirements', job.requirements.en, multi: true),
          const SizedBox(height: 12),
          _infoField('Preferred Skills', job.preferredSkills.en, multi: true),
        ],
      ),
    );
  }

  Widget _benefitsContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ...List.generate(job.benefits.length, (i) {
            final b = job.benefits[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoField('Benefit ${i + 1} Title', b.title.en),
                  const SizedBox(height: 6),
                  _infoField('Description', b.shortDescription.en, multi: true),
                  if (i < job.benefits.length - 1) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE8E8E8)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _appDetailsContent() {
    String fmtDate(DateTime? dt) {
      if (dt == null) return '—';
      const m = [
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
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _row(
            _infoField('Hiring Start Date', fmtDate(job.hiringStartDate)),
            _infoField('Hiring End Date', fmtDate(job.hiringEndDate)),
          ),
          const SizedBox(height: 12),
          _row(
            _infoField(
              'Max Applications',
              job.maxApplications > 0 ? job.maxApplications.toString() : '—',
            ),
            const SizedBox(),
          ),
          if (job.requiredDocuments.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: job.requiredDocuments
                  .map((d) => _chip('${d.name} (${d.docType.label})'))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(Widget left, Widget right) => Row(
    children: [
      Expanded(child: left),
      const SizedBox(width: 16),
      Expanded(child: right),
    ],
  );

  Widget _skillsRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Required Skills',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: job.requiredSkills.map((s) => _chip(s.name.en)).toList(),
      ),
    ],
  );

  Widget _infoField(String label, String value, {bool multi = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty) ...[
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
      ],
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value.isEmpty ? '—' : value,
          style: TextStyle(
            fontSize: 12,
            color: value.isEmpty
                ? const Color(0xFFAAAAAA)
                : const Color(0xFF333333),
          ),
          maxLines: multi ? null : 1,
          overflow: multi ? null : TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _infoFieldRtl(String label, String value) => Directionality(
    textDirection: TextDirection.rtl,
    child: _infoField(label, value),
  );

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF008037).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF008037).withValues(alpha: 0.3)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF008037),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  TAB 2 — DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
