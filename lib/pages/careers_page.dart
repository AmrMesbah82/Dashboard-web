// ******************* FILE INFO *******************
// File Name: careers_page.dart
// Created by: Amr Mesbah
// UPDATED: backgroundColor now dynamic from CMS branding.backgroundColor ✅
// Updated: Full AR/EN bilingual support added to all static data.
//          isRtl passed through entire widget tree.
//          Directionality wrapper applied at Scaffold level.
//          All static strings use _t(en, ar, isRtl) helper.
// FIX: secondaryColor from branding applied to tab icon boxes and team card icon boxes.
// UPDATED: Deep-link support — reads ?tab=<key> from GoRouter query params
//          and auto-selects the correct tab on load.
// UPDATED: Careers overview description + action button label now read from
//          CareersCmsCubit (Firebase) instead of hardcoded strings.
//          Career statistics (title + shortDescription) now read from Firebase.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:web_app_admin/controller/career/careers_cms_cubit.dart';
import 'package:web_app_admin/controller/career/careers_cms_state.dart';
import 'package:web_app_admin/controller/home_cubit.dart';
import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/controller/lang_state.dart';
import 'package:web_app_admin/model/careers_cms_model.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import '../theme/appcolors.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';

// ── Bilingual helper ──────────────────────────────────────────────────────────
String _t(String en, String ar, bool isRtl) => isRtl ? ar : en;

// ── Fallback colors ───────────────────────────────────────────────────────────
const Color _kFallbackPrimary   = Color(0xFF2D8C4E);
const Color _kFallbackSecondary = Color(0xFFE8F5EE);
const Color _kDivider           = Color(0xFFDDE8DD);

Color _parseColor(String hex, {Color fallback = _kFallbackPrimary}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ── Breakpoints ───────────────────────────────────────────────────────────────
class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

// ── Content width + hPad ─────────────────────────────────────────────────────
double _desktopContentW() => (248.w * 4) + (8.w * 3);
double _desktopHPad(double screenW) =>
    ((screenW - _desktopContentW()) / 2).clamp(16.0, double.infinity);
double _tabletHPad() => 16.w;

// ── Deep-link tab resolution ──────────────────────────────────────────────────
int _resolveTabParam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'why-join-our-team': return 0;
    case 'interns':           return 1;
    case 'our-team':          return 2;
    default:                  return 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class _RevealCoordinator extends InheritedWidget {
  final _RevealCoordinatorState state;
  const _RevealCoordinator({required this.state, required super.child});
  static _RevealCoordinatorState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RevealCoordinator>()?.state;
  @override
  bool updateShouldNotify(_RevealCoordinator old) => false;
}

class _RevealCoordinatorWidget extends StatefulWidget {
  final Widget child;
  const _RevealCoordinatorWidget({required this.child});
  @override
  State<_RevealCoordinatorWidget> createState() => _RevealCoordinatorState();
}

class _RevealCoordinatorState extends State<_RevealCoordinatorWidget> {
  final List<_RevealState> _items = [];

  void register(_RevealState item) {
    _items.add(item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) item.onScroll();
      });
    });
  }

  void unregister(_RevealState item) => _items.remove(item);

  void notifyScroll() {
    for (final item in List.of(_items)) item.onScroll();
  }

  @override
  Widget build(BuildContext context) => _RevealCoordinator(
    state: this,
    child: NotificationListener<ScrollNotification>(
      onNotification: (_) {
        notifyScroll();
        return false;
      },
      child: widget.child,
    ),
  );
}

class _Reveal extends StatefulWidget {
  final Widget          child;
  final Duration        delay;
  final Duration        duration;
  final _SlideDirection direction;

  const _Reveal({
    required this.child,
    this.delay     = Duration.zero,
    this.duration  = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  late final Animation<Offset>   _slide;
  bool _triggered = false;

  _RevealCoordinatorState? _coordinator;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop    => const Offset(0, -0.18),
      _SlideDirection.fromLeft   => const Offset(-0.18, 0),
      _SlideDirection.fromRight  => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () => _checkAndTrigger());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        widget.delay + const Duration(milliseconds: 120),
            () => _checkAndTrigger(),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = _RevealCoordinator.of(context);
    _coordinator?.register(this);
  }

  @override
  void dispose() {
    _coordinator?.unregister(this);
    _coordinator = null;
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos     = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH - 40) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATIC DATA MODELS (unchanged — not CMS managed)
// ═══════════════════════════════════════════════════════════════════════════════

class _WhyJoinItem {
  final String svgPath;
  final String textEn;
  final String textAr;
  const _WhyJoinItem({
    required this.svgPath,
    required this.textEn,
    required this.textAr,
  });
  String text(bool isRtl) => isRtl ? textAr : textEn;
}

const List<_WhyJoinItem> _whyJoinItems = [
  _WhyJoinItem(
    svgPath: 'assets/images/careers/careers_one.svg',
    textEn: 'At Bayanatz, we place sustainability and corporate social responsibility at the heart of our mission. We are dedicated to driving positive change and building a future that is both ethical and environmentally responsible. By working with us, you\'ll be part of a purpose-driven organization where your efforts contribute to meaningful, lasting impact.',
    textAr: 'في بيانات، نضع الاستدامة والمسؤولية الاجتماعية للشركات في صميم مهمتنا. نحن ملتزمون بإحداث تغيير إيجابي وبناء مستقبل أخلاقي ومسؤول بيئيًا. بالعمل معنا، ستكون جزءًا من مؤسسة ذات هدف حقيقي تسهم فيها جهودك في أثر ملموس ودائم.',
  ),
  _WhyJoinItem(
    svgPath: 'assets/images/careers/careers_two.svg',
    textEn: 'At Bayanatz, we cultivate a collaborative and supportive work environment where teamwork is at the core of everything we do. You\'ll join a team of passionate professionals who learn from one another, work toward common goals, and celebrate success together. Here, every achievement is a shared victory.',
    textAr: 'في بيانات، نرسّخ بيئة عمل تعاونية وداعمة يقوم فيها العمل الجماعي في قلب كل ما نفعله. ستنضم إلى فريق من المحترفين المتحمسين الذين يتعلمون من بعضهم ويعملون نحو أهداف مشتركة ويحتفلون بالنجاح معًا. هنا، كل إنجاز هو انتصار مشترك.',
  ),
  _WhyJoinItem(
    svgPath: 'assets/images/careers/careers_three.svg',
    textEn: 'At Bayanatz, continuous learning and professional growth are fundamental to our culture. We offer a wide range of opportunities—including structured training programs, mentorship, and access to cutting-edge tools and technologies—to help our team stay ahead in a fast-evolving digital landscape. Build a fulfilling, future-ready career with us.',
    textAr: 'في بيانات، التعلم المستمر والنمو المهني ركيزتان أساسيتان في ثقافتنا. نقدم طيفًا واسعًا من الفرص—بما فيها برامج تدريبية منظمة، وإرشاد مهني، والوصول إلى أحدث الأدوات والتقنيات—لمساعدة فريقنا على البقاء في طليعة المشهد الرقمي المتسارع. ابنِ معنا مسيرة مهنية مُجزية جاهزة للمستقبل.',
  ),
  _WhyJoinItem(
    svgPath: 'assets/images/careers/careeres_four.svg',
    textEn: 'At Bayanatz, we value open communication, transparency, and a positive work environment. Our leadership is approachable and supportive—welcoming feedback, encouraging fresh ideas, and fostering a culture built on trust, mutual respect, and continuous improvement.',
    textAr: 'في بيانات، نُقدّر التواصل المفتوح والشفافية وبيئة العمل الإيجابية. قيادتنا متاحة وداعمة—ترحب بالملاحظات، وتشجع الأفكار الجديدة، وتُرسّخ ثقافة مبنية على الثقة والاحترام المتبادل والتحسين المستمر.',
  ),
  _WhyJoinItem(
    svgPath: 'assets/images/careers/careers_five.svg',
    textEn: 'At Bayanatz, we operate with a strong sense of purpose and a clear vision for the future. By joining our team, you\'ll contribute to meaningful work that creates lasting value for our customers, empowers our partners, and positively impacts the communities we serve.',
    textAr: 'في بيانات، نعمل بإحساس قوي بالهدف ورؤية واضحة للمستقبل. بانضمامك إلى فريقنا، ستُسهم في عمل هادف يخلق قيمة دائمة لعملائنا، ويُمكّن شركاءنا، ويُؤثر إيجابيًا في المجتمعات التي نخدمها.',
  ),
];

class _InternData {
  final String nameEn;
  final String nameAr;
  final String degreeEn;
  final String degreeAr;
  final String joinDateEn;
  final String joinDateAr;
  final String learnedEn;
  final String learnedAr;
  final List<String> tags;

  const _InternData({
    required this.nameEn,
    required this.nameAr,
    required this.degreeEn,
    required this.degreeAr,
    required this.joinDateEn,
    required this.joinDateAr,
    required this.learnedEn,
    required this.learnedAr,
    required this.tags,
  });

  String name(bool isRtl)     => isRtl ? nameAr     : nameEn;
  String degree(bool isRtl)   => isRtl ? degreeAr   : degreeEn;
  String joinDate(bool isRtl) => isRtl ? joinDateAr : joinDateEn;
  String learned(bool isRtl)  => isRtl ? learnedAr  : learnedEn;
}

const List<_InternData> _interns = [
  _InternData(nameEn: 'Amro Handousa', nameAr: 'عمرو حندوسة', degreeEn: 'Bachelor of Design (B.Des)', degreeAr: 'بكالوريوس التصميم', joinDateEn: 'Joined as Intern: 28 Nov 2025', joinDateAr: 'التحق كمتدرب: 28 نوف 2025', learnedEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business', learnedAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', tags: ['UI', 'UX']),
  _InternData(nameEn: 'Amro Handousa', nameAr: 'عمرو حندوسة', degreeEn: 'Bachelor of Design (B.Des)', degreeAr: 'بكالوريوس التصميم', joinDateEn: 'Joined as Intern: 28 Nov 2025', joinDateAr: 'التحق كمتدرب: 28 نوف 2025', learnedEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business', learnedAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', tags: ['UI', 'UX']),
  _InternData(nameEn: 'Amro Handousa', nameAr: 'عمرو حندوسة', degreeEn: 'Bachelor of Design (B.Des)', degreeAr: 'بكالوريوس التصميم', joinDateEn: 'Joined as Intern: 28 Nov 2025', joinDateAr: 'التحق كمتدرب: 28 نوف 2025', learnedEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business', learnedAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', tags: ['UI', 'UX']),
  _InternData(nameEn: 'Amro Handousa', nameAr: 'عمرو حندوسة', degreeEn: 'Bachelor of Design (B.Des)', degreeAr: 'بكالوريوس التصميم', joinDateEn: 'Joined as Intern: 28 Nov 2025', joinDateAr: 'التحق كمتدرب: 28 نوف 2025', learnedEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business', learnedAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', tags: ['UI', 'UX']),
  _InternData(nameEn: 'Amro Handousa', nameAr: 'عمرو حندوسة', degreeEn: 'Bachelor of Design (B.Des)', degreeAr: 'بكالوريوس التصميم', joinDateEn: 'Joined as Intern: 28 Nov 2025', joinDateAr: 'التحق كمتدرب: 28 نوف 2025', learnedEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business', learnedAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', tags: ['UI', 'UX']),
  _InternData(nameEn: 'Amro Handousa', nameAr: 'عمرو حندوسة', degreeEn: 'Bachelor of Design (B.Des)', degreeAr: 'بكالوريوس التصميم', joinDateEn: 'Joined as Intern: 28 Nov 2025', joinDateAr: 'التحق كمتدرب: 28 نوف 2025', learnedEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business', learnedAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', tags: ['UI', 'UX']),
];

class _TeamData {
  final String svgPath;
  final String nameEn;
  final String nameAr;
  final String descEn;
  final String descAr;
  final List<String> deliverablesEn;
  final List<String> deliverablesAr;

  const _TeamData({
    required this.svgPath,
    required this.nameEn,
    required this.nameAr,
    required this.descEn,
    required this.descAr,
    required this.deliverablesEn,
    required this.deliverablesAr,
  });

  String name(bool isRtl)               => isRtl ? nameAr : nameEn;
  String desc(bool isRtl)               => isRtl ? descAr : descEn;
  List<String> deliverables(bool isRtl) => isRtl ? deliverablesAr : deliverablesEn;
}

const List<_TeamData> _teams = [
  _TeamData(svgPath: 'assets/images/careers/Strategy & Planning Team.svg', nameEn: 'Strategy & Planning Team', nameAr: 'فريق الاستراتيجية والتخطيط', descEn: 'Conduct market analysis, establish KPIs, and set timelines for deliverables. Ensure every project is mapped to measurable business outcomes.', descAr: 'إجراء تحليل السوق، وتحديد مؤشرات الأداء الرئيسية، ووضع جداول زمنية للمخرجات. ضمان ربط كل مشروع بنتائج أعمال قابلة للقياس.', deliverablesEn: ['Strategic plans', 'performance dashboards', 'client-aligned roadmaps', 'KPI frameworks', 'market analysis', 'business outcomes', 'transformation plans'], deliverablesAr: ['خطط استراتيجية', 'لوحات الأداء', 'خرائط طريق للعملاء', 'أطر مؤشرات الأداء', 'تحليل السوق', 'نتائج الأعمال', 'خطط التحول']),
  _TeamData(svgPath: 'assets/images/careers/Technology & Development Team.svg', nameEn: 'Technology & Development Team', nameAr: 'فريق التقنية والتطوير', descEn: 'Apply agile methodologies for rapid development, continuous testing, and iterative improvements. Emphasize scalability, security, and future-readiness of solutions.', descAr: 'تطبيق المنهجيات الرشيقة للتطوير السريع والاختبار المستمر والتحسينات التكرارية. التركيز على قابلية التوسع والأمان وجاهزية الحلول للمستقبل.', deliverablesEn: ['Software platforms', 'integrations', 'system upgrades', 'technology frameworks', 'agile solutions', 'security protocols', 'scalable systems'], deliverablesAr: ['منصات البرمجيات', 'التكاملات', 'ترقيات الأنظمة', 'أطر التقنية', 'حلول رشيقة', 'بروتوكولات الأمان', 'أنظمة قابلة للتوسع']),
  _TeamData(svgPath: 'assets/images/careers/Data & Analytics Team.svg', nameEn: 'Data & Analytics Team', nameAr: 'فريق البيانات والتحليلات', descEn: 'Leverage advanced analytics, BI tools, and AI models to provide predictive and prescriptive intelligence. Ensure data governance and accuracy across projects.', descAr: 'الاستفادة من التحليلات المتقدمة وأدوات ذكاء الأعمال ونماذج الذكاء الاصطناعي لتقديم ذكاء تنبؤي وتوجيهي. ضمان حوكمة البيانات ودقتها عبر المشاريع.', deliverablesEn: ['Dashboards', 'reports', 'data models', 'insights', 'BI tools', 'AI models', 'analytics platforms'], deliverablesAr: ['لوحات البيانات', 'التقارير', 'نماذج البيانات', 'الرؤى', 'أدوات ذكاء الأعمال', 'نماذج الذكاء الاصطناعي', 'منصات التحليل']),
  _TeamData(svgPath: 'assets/images/careers/Client Engagement & Success Team.svg', nameEn: 'Client Engagement & Success Team', nameAr: 'فريق تفاعل العملاء ونجاحهم', descEn: 'Maintain continuous feedback loops, monitor adoption rates, and resolve client concerns proactively. Focus on long-term partnerships.', descAr: 'الحفاظ على حلقات التغذية الراجعة المستمرة، ومراقبة معدلات التبني، وحل مخاوف العملاء بصورة استباقية. التركيز على الشراكات طويلة الأمد.', deliverablesEn: ['Client reports', 'adoption metrics', 'feedback sessions', 'case studies', 'engagement plans', 'support docs', 'success metrics'], deliverablesAr: ['تقارير العملاء', 'مقاييس التبني', 'جلسات التغذية الراجعة', 'دراسات الحالة', 'خطط التفاعل', 'وثائق الدعم', 'مقاييس النجاح']),
  _TeamData(svgPath: 'assets/images/careers/ Innovation & Research Team.svg', nameEn: 'Innovation & Research Team', nameAr: 'فريق الابتكار والبحث', descEn: 'Conduct research, pilot new technologies, and recommend innovative solutions that give clients a competitive edge.', descAr: 'إجراء الأبحاث، واختبار التقنيات الجديدة، واقتراح حلول مبتكرة تمنح العملاء ميزة تنافسية.', deliverablesEn: ['Research papers', 'innovation proposals', 'prototypes', 'proof-of-concepts', 'pilot programs', 'tech assessments', 'R&D insights'], deliverablesAr: ['أوراق بحثية', 'مقترحات الابتكار', 'نماذج أولية', 'إثباتات المفهوم', 'برامج تجريبية', 'تقييمات تقنية', 'رؤى البحث والتطوير']),
  _TeamData(svgPath: 'assets/images/careers/Creative Design Team.svg', nameEn: 'Creative Design Team', nameAr: 'فريق التصميم الإبداعي', descEn: 'We bring ideas to life through intuitive interfaces and brand-consistent visuals. Every design is built around the user, ensuring simplicity, elegance, and impact.', descAr: 'نُحيي الأفكار من خلال واجهات سهلة الاستخدام وعناصر بصرية متسقة مع الهوية البصرية. كل تصميم مبني حول المستخدم لضمان البساطة والأناقة والتأثير.', deliverablesEn: ['UI/UX designs', 'design systems', 'prototypes', 'brand guidelines', 'visual assets', 'style guides', 'user interfaces'], deliverablesAr: ['تصاميم واجهات المستخدم', 'أنظمة التصميم', 'نماذج أولية', 'إرشادات العلامة التجارية', 'الأصول البصرية', 'أدلة الأسلوب', 'واجهات المستخدم']),
];

class _TabItem {
  final String labelEn;
  final String labelAr;
  final String icon;
  const _TabItem({required this.labelEn, required this.labelAr, required this.icon});
  String label(bool isRtl) => isRtl ? labelAr : labelEn;
}

const List<_TabItem> _tabs = [
  _TabItem(labelEn: 'Why Join Our Team', labelAr: 'لماذا تنضم إلى فريقنا', icon: 'assets/images/careers/Why Join Our Team.svg'),
  _TabItem(labelEn: 'Our Interns',       labelAr: 'متدربونا',               icon: 'assets/images/careers/Our Interns.svg'),
  _TabItem(labelEn: 'Our Team',          labelAr: 'فريقنا',                 icon: 'assets/images/careers/Our Team.svg'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PULSE LOADER  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color   backgroundColor;
  const _SvgPulseLoader({this.logoUrl, required this.backgroundColor});

  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SvgPulseLoader old) {
    super.didUpdateWidget(old);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null) {
      setState(() => _resolvedUrl = widget.logoUrl);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null) {
      return Scaffold(
          backgroundColor: widget.backgroundColor,
          body: const SizedBox.shrink());
    }
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SvgPicture.network(
            _resolvedUrl!,
            width:  36.w,
            height: 36.w,
            fit:    BoxFit.contain,
            placeholderBuilder: (_) => SizedBox(width: 36.w, height: 36.w),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class CareersPage extends StatefulWidget {
  const CareersPage({super.key});

  @override
  State<CareersPage> createState() => _CareersPageState();
}

class _CareersPageState extends State<CareersPage> {
  bool _showLoader  = true;
  int  _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
      // ← load careers CMS data
      context.read<CareersCmsCubit>().load();
      _readTabParam();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readTabParam();
  }

  void _readTabParam() {
    if (!mounted) return;
    try {
      final uri      = GoRouterState.of(context).uri;
      final tabParam = uri.queryParameters['tab'];
      final resolved = (tabParam != null && tabParam.isNotEmpty)
          ? _resolveTabParam(tabParam)
          : 0;
      if (_selectedTab != resolved) {
        setState(() => _selectedTab = resolved);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCmsCubit, HomeCmsState>(
      listener: (context, state) {
        if (state is HomeCmsLoaded || state is HomeCmsSaved) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() => _showLoader = false);
          });
        }
        if (state is HomeCmsError && state.lastData == null) {
          setState(() => _showLoader = false);
        }
      },
      builder: (context, homeState) {
        final String logoUrl = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };

        final Color primary = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(data.branding.primaryColor),
          HomeCmsSaved(:final data)  => _parseColor(data.branding.primaryColor),
          _ => _kFallbackPrimary,
        };

        final Color secondary = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(data.branding.secondaryColor, fallback: _kFallbackSecondary),
          HomeCmsSaved(:final data)  => _parseColor(data.branding.secondaryColor, fallback: _kFallbackSecondary),
          _ => _kFallbackSecondary,
        };

        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(data.branding.backgroundColor, fallback: AppColors.background),
          HomeCmsSaved(:final data)  => _parseColor(data.branding.backgroundColor, fallback: AppColors.background),
          _ => AppColors.background,
        };

        if (_showLoader) {
          return _SvgPulseLoader(
            logoUrl:         logoUrl.isEmpty ? null : logoUrl,
            backgroundColor: _parseColor(
              context.read<HomeCmsCubit>().current.branding.backgroundColor, // ← backgroundColor
              fallback: AppColors.background,
            ),
          );
        }

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool   isRtl   = langState.isArabic;
            final double screenW = MediaQuery.of(context).size.width;
            final bool   isMobile = screenW < _BP.mobile;

            // ── Read careers CMS data ──────────────────────────────────────
            return BlocBuilder<CareersCmsCubit, CareersCmsState>(
              builder: (context, careersState) {
                final CareersCmsModel careersData =
                    context.read<CareersCmsCubit>().current;

                return Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Scaffold(
                    backgroundColor: backgroundColor,
                    body: Stack(
                      children: [
                        _RevealCoordinatorWidget(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 80.h),
                                isMobile
                                    ? _MobileBody(
                                  selectedTab:  _selectedTab,
                                  onTabChange:  (i) => setState(() => _selectedTab = i),
                                  primary:      primary,
                                  secondary:    secondary,
                                  isRtl:        isRtl,
                                  careersData:  careersData,
                                )
                                    : _DesktopBody(
                                  selectedTab:  _selectedTab,
                                  onTabChange:  (i) => setState(() => _selectedTab = i),
                                  primary:      primary,
                                  secondary:    secondary,
                                  isRtl:        isRtl,
                                  careersData:  careersData,
                                ),
                                _Reveal(
                                  delay:     const Duration(milliseconds: 100),
                                  direction: _SlideDirection.fromBottom,
                                  duration:  const Duration(milliseconds: 600),
                                  child: const AppFooter(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0, left: 0, right: 0,
                          child: Material(
                            color:     backgroundColor,
                            elevation: 0,
                            child: AppNavbar(currentRoute: '/careers'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileBody extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final Color primary;
  final Color secondary;
  final bool  isRtl;
  final CareersCmsModel careersData; // ← NEW
  const _MobileBody({
    required this.selectedTab,
    required this.onTabChange,
    required this.primary,
    required this.secondary,
    required this.isRtl,
    required this.careersData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 22.h),
          _Reveal(
            delay:     const Duration(milliseconds: 60),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Text(
              _t('Careers', 'الوظائف', isRtl),
              style: StyleText.fontSize28Weight600.copyWith(
                  fontSize: 28.sp, color: primary),
            ),
          ),
          SizedBox(height: 14.h),
          _Reveal(
            delay:     const Duration(milliseconds: 100),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            // ── Overview description from Firebase ────────────────────────
            child: _MobileHeaderCard(
              primary:     primary,
              isRtl:       isRtl,
              description: isRtl
                  ? careersData.overview.description.ar
                  : careersData.overview.description.en,
              btnLabel:    isRtl
                  ? careersData.overview.actionButtonLabel.ar
                  : careersData.overview.actionButtonLabel.en,
            ),
          ),
          SizedBox(height: 16.h),
          _Reveal(
            delay:     const Duration(milliseconds: 140),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            // ── Statistics from Firebase ──────────────────────────────────
            child: _MobileStatsSection(
              primary:    primary,
              isRtl:      isRtl,
              statistics: careersData.statistics,
            ),
          ),
          SizedBox(height: 20.h),
          _Reveal(
            delay:     const Duration(milliseconds: 170),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 600),
            child: _MobileTabBar(
              selectedTab: selectedTab,
              onTabChange: onTabChange,
              primary:     primary,
              secondary:   secondary,
              isRtl:       isRtl,
            ),
          ),
          SizedBox(height: 16.h),
          _buildMobileTabContent(selectedTab, primary, secondary, isRtl),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildMobileTabContent(int tab, Color primary, Color secondary, bool isRtl) {
    switch (tab) {
      case 0:  return _MobileWhyJoinTab(primary: primary, isRtl: isRtl);
      case 1:  return _MobileInternsTab(primary: primary, isRtl: isRtl);
      case 2:  return _MobileOurTeamTab(primary: primary, secondary: secondary, isRtl: isRtl);
      default: return _MobileWhyJoinTab(primary: primary, isRtl: isRtl);
    }
  }
}

// ── Mobile header card — now receives Firebase description ────────────────────
class _MobileHeaderCard extends StatelessWidget {
  final Color  primary;
  final bool   isRtl;
  final String description; // ← from Firebase
  final String btnLabel;    // ← from Firebase
  const _MobileHeaderCard({
    required this.primary,
    required this.isRtl,
    required this.description,
    required this.btnLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Join a Team That Drives Innovation and Values You',
                'انضم إلى فريق يقود الابتكار ويُقدّرك', isRtl),
            style: StyleText.fontSize14Weight600
                .copyWith(fontSize: 13.sp, color: Colors.black87),
          ),
          SizedBox(height: 8.h),
          // ── Firebase description ─────────────────────────────────────────
          if (description.isNotEmpty)
            Text(
              description,
              style: StyleText.fontSize13Weight400
                  .copyWith(fontSize: 11.sp, height: 1.65, color: Colors.black87),
            ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('Join Bayanatz—where your future begins',
                    'انضم إلى بيانات—حيث يبدأ مستقبلك', isRtl),
                style: StyleText.fontSize12Weight400
                    .copyWith(fontSize: 10.sp, color: Colors.black54),
              ),
              // ── Firebase action button label ─────────────────────────────
              if (btnLabel.isNotEmpty)
                GestureDetector(
                  onTap: () => context.go('/jobs'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      btnLabel,
                      style: StyleText.fontSize12Weight600.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileBullet extends StatelessWidget {
  final String text;
  const _MobileBullet(this.text);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(top: 5.h, right: 5.w),
        child: CircleAvatar(radius: 3.r, backgroundColor: Colors.black87),
      ),
      Expanded(child: _MobilePlain(text)),
    ],
  );
}

class _MobilePlain extends StatelessWidget {
  final String text;
  const _MobilePlain(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: StyleText.fontSize13Weight400
        .copyWith(fontSize: 11.sp, height: 1.65, color: Colors.black87),
  );
}

// ── Mobile stats — now receives Firebase statistics list ──────────────────────
class _MobileStatsSection extends StatelessWidget {
  final Color                primary;
  final bool                 isRtl;
  final List<CareerStatItem> statistics; // ← from Firebase
  const _MobileStatsSection({
    required this.primary,
    required this.isRtl,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r)),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statistics
            .map((s) => Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRtl ? s.title.ar : s.title.en,
                style: StyleText.fontSize28Weight600.copyWith(
                    fontSize:   24.sp,
                    fontWeight: FontWeight.w700,
                    color:      primary),
              ),
              SizedBox(height: 3.h),
              Text(
                isRtl
                    ? s.shortDescription.ar
                    : s.shortDescription.en,
                style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 13.sp,
                    height:   1.5,
                    color:    Colors.black54),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }
}

class _MobileTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final Color primary;
  final Color secondary;
  final bool  isRtl;
  const _MobileTabBar({
    required this.selectedTab,
    required this.onTabChange,
    required this.primary,
    required this.secondary,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final double boxSize = 48.w;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final bool selected = selectedTab == i;
          return GestureDetector(
            onTap: () => onTabChange(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin:  EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: boxSize, height: boxSize,
                  decoration: BoxDecoration(
                    color: selected ? primary : secondary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      _tabs[i].icon,
                      width: 26.sp, height: 26.sp,
                      colorFilter: ColorFilter.mode(
                        selected ? Colors.white : primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  _tabs[i].label(isRtl),
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize:   16.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color:      selected ? primary : Colors.black54,
                  ),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

class _MobileWhyJoinTab extends StatelessWidget {
  final Color primary;
  final bool  isRtl;
  const _MobileWhyJoinTab({required this.primary, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_whyJoinItems.length, (i) {
        final item = _whyJoinItems[i];
        return _Reveal(
          delay:     Duration(milliseconds: 60 + i * 80),
          direction: i.isEven ? _SlideDirection.fromLeft : _SlideDirection.fromRight,
          duration:  const Duration(milliseconds: 650),
          child: Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(children: [
              SvgPicture.asset(item.svgPath,
                  width: 160.w, height: 140.h, fit: BoxFit.contain),
              SizedBox(height: 12.h),
              Text(item.text(isRtl),
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize15Weight400.copyWith(
                      fontSize: 11.sp, height: 1.7, color: Colors.black45)),
            ]),
          ),
        );
      }),
    );
  }
}

class _MobileInternsTab extends StatelessWidget {
  final Color primary;
  final bool  isRtl;
  const _MobileInternsTab({required this.primary, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_interns.length, (i) {
        return _Reveal(
          delay:     Duration(milliseconds: 60 + i * 70),
          direction: _SlideDirection.fromBottom,
          duration:  const Duration(milliseconds: 650),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _MobileInternCard(
                data: _interns[i], primary: primary, isRtl: isRtl),
          ),
        );
      }),
    );
  }
}

class _MobileInternCard extends StatelessWidget {
  final _InternData data;
  final Color       primary;
  final bool        isRtl;
  const _MobileInternCard(
      {required this.data, required this.primary, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56.w, height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary, width: 1.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/careers/person.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(data.name(isRtl),
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight500.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                SizedBox(height: 3.h),
                Text(data.degree(isRtl),
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize10Weight400.copyWith(
                        fontSize: 9.sp,
                        color: Colors.black45,
                        height: 1.3)),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 3.w, runSpacing: 3.h,
                  alignment: WrapAlignment.center,
                  children: data.tags
                      .map((tag) => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(4.r)),
                    child: Text(tag,
                        style: StyleText.fontSize10Weight700
                            .copyWith(fontSize: 9.sp)),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.joinDate(isRtl),
                    style: StyleText.fontSize11Weight400.copyWith(
                        fontSize: 9.sp, color: Colors.black45)),
                SizedBox(height: 8.h),
                Text(_t('What Have I Learned', 'ماذا تعلمت', isRtl),
                    style: StyleText.fontSize13Weight600.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                SizedBox(height: 6.h),
                Text(data.learned(isRtl),
                    style: StyleText.fontSize12Weight400.copyWith(
                        fontSize: 10.sp,
                        height: 1.6,
                        color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileOurTeamTab extends StatefulWidget {
  final Color primary;
  final Color secondary;
  final bool  isRtl;
  const _MobileOurTeamTab(
      {required this.primary, required this.secondary, required this.isRtl});

  @override
  State<_MobileOurTeamTab> createState() => _MobileOurTeamTabState();
}

class _MobileOurTeamTabState extends State<_MobileOurTeamTab> {
  int? _selectedTeamIndex;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final bool       hasMore   = _teams.length > 4;
    final List<_TeamData> displayed =
    (_showAll || !hasMore) ? _teams : _teams.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Reveal(
          delay:     const Duration(milliseconds: 60),
          direction: _SlideDirection.fromLeft,
          duration:  const Duration(milliseconds: 600),
          child: Row(children: [
            Expanded(child: Container()),
            SizedBox(width: 20.sp),
            Expanded(
              flex: 3,
              child: Row(children: [
                RichText(text: TextSpan(children: [
                  TextSpan(
                    text: _t('Meet Our Teams', 'تعرّف على فرقنا', widget.isRtl),
                    style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ])),
                const Spacer(),
                if (hasMore)
                  GestureDetector(
                    onTap: () => setState(() => _showAll = !_showAll),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                          color: widget.primary,
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Row(children: [
                        Text(
                          _showAll
                              ? _t('Show Less', 'عرض أقل',  widget.isRtl)
                              : _t('See All',   'عرض الكل', widget.isRtl),
                          style: StyleText.fontSize12Weight600.copyWith(
                              fontSize:   11.sp,
                              fontWeight: FontWeight.w600,
                              color:      Colors.white),
                        ),
                        SizedBox(width: 3.w),
                        AnimatedRotation(
                          turns:    _showAll ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 13.sp),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
        SizedBox(height: 14.h),
        ...displayed.asMap().entries.map((e) => _Reveal(
          delay:     Duration(milliseconds: 80 + e.key * 70),
          direction: _SlideDirection.fromBottom,
          duration:  const Duration(milliseconds: 650),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _MobileTeamCard(
              data:       e.value,
              primary:    widget.primary,
              secondary:  widget.secondary,
              isRtl:      widget.isRtl,
              isExpanded: _selectedTeamIndex == e.key,
              onTap: () => setState(() {
                _selectedTeamIndex =
                _selectedTeamIndex == e.key ? null : e.key;
              }),
            ),
          ),
        )),
      ],
    );
  }
}

class _MobileTeamCard extends StatelessWidget {
  final _TeamData    data;
  final Color        primary;
  final Color        secondary;
  final bool         isRtl;
  final bool         isExpanded;
  final VoidCallback onTap;
  const _MobileTeamCard({
    required this.data,
    required this.primary,
    required this.secondary,
    required this.isRtl,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60.w, height: 60.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r), color: secondary),
            child: Center(
              child: SvgPicture.asset(data.svgPath,
                  width: 32.w, height: 32.w, fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn)),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: primary, borderRadius: BorderRadius.circular(6.r)),
            child: Text(data.name(isRtl),
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight600.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          SizedBox(height: 10.h),
          Text(data.desc(isRtl),
              textAlign: TextAlign.center,
              style: StyleText.fontSize12Weight400.copyWith(
                  fontSize: 10.sp,
                  height: 1.6,
                  color: AppColors.secondaryText.withOpacity(.7))),
          SizedBox(height: 10.h),
          _DeliverableButtons(
            deliverables: data.deliverables(isRtl),
            primary:      primary,
            isRtl:        isRtl,
            isExpanded:   isExpanded,
            onTap:        onTap,
          ),
        ],
      ),
    );
  }
}

class _DeliverableButtons extends StatefulWidget {
  final List<String> deliverables;
  final Color        primary;
  final bool         isRtl;
  final bool         isExpanded;
  final VoidCallback onTap;

  const _DeliverableButtons({
    required this.deliverables,
    required this.primary,
    required this.isRtl,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_DeliverableButtons> createState() => _DeliverableButtonsState();
}

class _DeliverableButtonsState extends State<_DeliverableButtons> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.w, runSpacing: 6.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _t('Deliverables:', 'المخرجات:', widget.isRtl),
              style: StyleText.fontSize12Weight600.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            ...List.generate(widget.deliverables.length, (index) {
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedIndex =
                  _selectedIndex == index ? null : index;
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6.r)),
                  child: Text(widget.deliverables[index],
                      style: StyleText.fontSize11Weight400.copyWith(
                          fontSize: 9.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400)),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopBody extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final Color primary;
  final Color secondary;
  final bool  isRtl;
  final CareersCmsModel careersData; // ← NEW
  const _DesktopBody({
    required this.selectedTab,
    required this.onTabChange,
    required this.primary,
    required this.secondary,
    required this.isRtl,
    required this.careersData,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final bool   isTablet = screenW < _BP.tablet;
    final double hPad     = isTablet ? _tabletHPad() : _desktopHPad(screenW);

    final double topSpace    = isTablet ? 28.h  : 36.h;
    final double titleFz     = isTablet ? 30.sp : 40.sp;
    final double sectionGap  = isTablet ? 18.h  : 24.h;
    final double bottomSpace = isTablet ? 40.h  : 56.h;
    final double cardPad     = isTablet ? 18.w  : 24.w;
    final double headerFz    = isTablet ? 12.sp : 14.sp;
    final double plainFz     = isTablet ? 11.sp : 13.sp;
    final double statValFz   = isTablet ? 20.sp : 24.sp;
    final double statDescFz  = isTablet ? 9.sp  : 10.sp;
    final double tabFz       = isTablet ? 11.sp : 13.sp;
    final double tabIconSz   = isTablet ? 16.sp : 18.sp;
    final double tabIconBox  = isTablet ? 32.w  : 36.w;

    // ── Resolve CMS strings ────────────────────────────────────────────────
    final String overviewDesc =
    isRtl ? careersData.overview.description.ar
        : careersData.overview.description.en;
    final String btnLabel =
    isRtl ? careersData.overview.actionButtonLabel.ar
        : careersData.overview.actionButtonLabel.en;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpace),

          _Reveal(
            delay:     const Duration(milliseconds: 60),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Text(
              _t('Careers', 'الوظائف', isRtl),
              style: StyleText.fontSize45Weight600.copyWith(
                  fontSize: titleFz, fontWeight: FontWeight.w700, color: primary),
            ),
          ),
          SizedBox(height: sectionGap),

          // ── Overview card — Firebase description ───────────────────────
          _Reveal(
            delay:     const Duration(milliseconds: 110),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: Container(
              padding: EdgeInsets.all(cardPad),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Join a Team That Drives Innovation and Values You',
                        'انضم إلى فريق يقود الابتكار ويُقدّرك', isRtl),
                    style: StyleText.fontSize12Weight600.copyWith(
                        fontSize: headerFz,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 10.h),
                  // ── Firebase description ─────────────────────────────────
                  if (overviewDesc.isNotEmpty)
                    _PlainText(overviewDesc, fontSize: plainFz),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _t('Join Bayanatz—where your future begins',
                            'انضم إلى بيانات—حيث يبدأ مستقبلك', isRtl),
                        style: StyleText.fontSize15Weight400.copyWith(
                            fontSize: plainFz, color: Colors.black54),
                      ),
                      // ── Firebase action button ───────────────────────────
                      if (btnLabel.isNotEmpty)
                        _ApplyNowBtnDesktop(
                          label:    btnLabel,
                          primary:  primary,
                          isTablet: isTablet,
                          isRtl:    isRtl,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sectionGap),

          // ── Statistics row — Firebase statistics ───────────────────────
          if (careersData.statistics.isNotEmpty)
            _Reveal(
              delay:     const Duration(milliseconds: 150),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 650),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: cardPad,
                    vertical:   isTablet ? 14.h : 18.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: careersData.statistics
                      .map((s) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRtl ? s.title.ar : s.title.en,
                            maxLines: 1,
                            style: StyleText.fontSize28Weight600.copyWith(
                                fontSize:   statValFz,
                                fontWeight: FontWeight.w700,
                                color:      primary),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            isRtl
                                ? s.shortDescription.ar
                                : s.shortDescription.en,
                            style: StyleText.fontSize10Weight400.copyWith(
                                fontSize: statDescFz,
                                height:   1.5,
                                color:    Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          SizedBox(height: sectionGap),

          // ── Tab Bar ────────────────────────────────────────────────────
          _Reveal(
            delay:     const Duration(milliseconds: 180),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tabs.length, (i) {
                final bool selected = selectedTab == i;
                return GestureDetector(
                  onTap: () => onTabChange(i),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin:  EdgeInsets.symmetric(horizontal: 6.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected ? primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: tabIconBox, height: tabIconBox,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: selected ? primary : secondary,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              _tabs[i].icon,
                              width: tabIconSz, height: tabIconSz,
                              fit: BoxFit.scaleDown,
                              colorFilter: ColorFilter.mode(
                                selected ? Colors.white : primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _tabs[i].label(isRtl),
                          style: StyleText.fontSize14Weight400.copyWith(
                            fontSize:   tabFz,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected ? primary : Colors.black54,
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: sectionGap),

          _buildDesktopTabContent(
              selectedTab, primary, secondary, isTablet, isRtl),

          SizedBox(height: bottomSpace),
        ],
      ),
    );
  }

  Widget _buildDesktopTabContent(
      int tab, Color primary, Color secondary, bool isTablet, bool isRtl) {
    switch (tab) {
      case 0:  return _DesktopWhyJoinTab(primary: primary, isTablet: isTablet, isRtl: isRtl);
      case 1:  return _DesktopInternsTab(primary: primary, isTablet: isTablet, isRtl: isRtl);
      case 2:  return _DesktopOurTeamTab(primary: primary, secondary: secondary, isTablet: isTablet, isRtl: isRtl);
      default: return _DesktopWhyJoinTab(primary: primary, isTablet: isTablet, isRtl: isRtl);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP TAB WIDGETS  (unchanged — not CMS managed)
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopWhyJoinTab extends StatelessWidget {
  final Color primary;
  final bool  isTablet;
  final bool  isRtl;
  const _DesktopWhyJoinTab(
      {required this.primary, this.isTablet = false, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final double svgW   = isTablet ? 160.w : 200.w;
    final double svgH   = isTablet ? 140.h : 170.h;
    final double gap    = isTablet ? 20.w  : 28.w;
    final double textFz = isTablet ? 13.sp : 15.sp;
    final double rowGap = isTablet ? 18.h  : 22.h;

    return Column(
      children: List.generate(_whyJoinItems.length, (i) {
        final item    = _whyJoinItems[i];
        final imgLeft = i.isOdd;
        return _Reveal(
          delay:     Duration(milliseconds: 60 + i * 80),
          direction: imgLeft
              ? _SlideDirection.fromRight
              : _SlideDirection.fromLeft,
          duration: const Duration(milliseconds: 700),
          child: Padding(
            padding: EdgeInsets.only(bottom: rowGap),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: imgLeft
                    ? [
                  SizedBox(
                      width: svgW,
                      child: Center(
                          child: SvgPicture.asset(item.svgPath,
                              width: svgW,
                              height: svgH,
                              fit: BoxFit.contain))),
                  SizedBox(width: gap),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item.text(isRtl),
                              style: StyleText.fontSize16Weight400.copyWith(
                                  fontSize: textFz,
                                  height: 1.7,
                                  color: Colors.black45)))),
                ]
                    : [
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item.text(isRtl),
                              style: StyleText.fontSize16Weight400.copyWith(
                                  fontSize: textFz,
                                  height: 1.7,
                                  color: Colors.black45)))),
                  SizedBox(width: gap),
                  SizedBox(
                      width: svgW,
                      child: Center(
                          child: SvgPicture.asset(item.svgPath,
                              width: svgW,
                              height: svgH,
                              fit: BoxFit.contain))),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DesktopInternsTab extends StatelessWidget {
  final Color primary;
  final bool  isTablet;
  final bool  isRtl;
  const _DesktopInternsTab(
      {required this.primary, this.isTablet = false, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double hPad    = isTablet ? _tabletHPad() : _desktopHPad(screenW);
    final double totalW  = screenW - hPad * 2;
    final int    cols    = isTablet ? 2 : 3;
    final double cardW   = (totalW - 14.w * (cols - 1)) / cols;

    final List<Widget> rows = [];
    for (int i = 0; i < _interns.length; i += cols) {
      final int          rowIndex    = i ~/ cols;
      final List<Widget> rowChildren = [];
      for (int j = i; j < i + cols; j++) {
        if (j < _interns.length) {
          rowChildren.add(_DesktopInternCard(
              data:     _interns[j],
              width:    cardW,
              primary:  primary,
              isTablet: isTablet,
              isRtl:    isRtl));
        } else {
          rowChildren.add(SizedBox(width: cardW));
        }
        if (j < i + cols - 1) rowChildren.add(SizedBox(width: 14.w));
      }
      rows.add(_Reveal(
        delay:     Duration(milliseconds: 60 + rowIndex * 80),
        direction: _SlideDirection.fromBottom,
        duration:  const Duration(milliseconds: 650),
        child: IntrinsicHeight(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowChildren)),
      ));
      if (i + cols < _interns.length) rows.add(SizedBox(height: 14.h));
    }
    return Column(children: rows);
  }
}

class _DesktopInternCard extends StatelessWidget {
  final _InternData data;
  final double      width;
  final Color       primary;
  final bool        isTablet;
  final bool        isRtl;
  const _DesktopInternCard({
    required this.data,
    required this.width,
    required this.primary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSz = isTablet ? 70.w  : 84.w;
    final double leftColW = isTablet ? 110.w : 130.w;
    final double nameFz   = isTablet ? 11.sp : 13.sp;
    final double degFz    = isTablet ? 9.sp  : 10.sp;
    final double joinFz   = isTablet ? 9.sp  : 10.sp;
    final double titleFz  = isTablet ? 12.sp : 14.sp;
    final double bodyFz   = isTablet ? 10.sp : 12.sp;
    final double cardPad  = isTablet ? 14.w  : 18.w;

    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftColW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: avatarSz, height: avatarSz,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primary, width: 1.5),
                      image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/careers/person.png'),
                          fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(data.name(isRtl),
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize14Weight700.copyWith(
                          fontSize: nameFz, color: Colors.black87)),
                  SizedBox(height: 3.h),
                  Text(data.degree(isRtl),
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize10Weight400.copyWith(
                          fontSize: degFz,
                          color: Colors.black45,
                          height: 1.4)),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 5.w, runSpacing: 3.h,
                    alignment: WrapAlignment.center,
                    children: data.tags
                        .map((tag) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(5.r)),
                      child: Text(tag,
                          style: StyleText.fontSize11Weight600.copyWith(
                              fontSize:   degFz,
                              fontWeight: FontWeight.w600,
                              color:      Colors.white)),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.joinDate(isRtl),
                      style: StyleText.fontSize11Weight400.copyWith(
                          fontSize: joinFz, color: Colors.black45)),
                  SizedBox(height: 22.h),
                  Text(_t('What Have I Learned', 'ماذا تعلمت', isRtl),
                      style: StyleText.fontSize16Weight700.copyWith(
                          fontSize: titleFz, color: Colors.black87)),
                  SizedBox(height: 10.h),
                  Text(data.learned(isRtl),
                      style: StyleText.fontSize14Weight400.copyWith(
                          fontSize: bodyFz,
                          height: 1.6,
                          color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopOurTeamTab extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final bool  isTablet;
  final bool  isRtl;
  const _DesktopOurTeamTab({
    required this.primary,
    required this.secondary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double hPad    = isTablet ? _tabletHPad() : _desktopHPad(screenW);
    final double totalW  = screenW - hPad * 2;
    final double cardW   = (totalW - 14.w * 2) / 3;
    final double meetFz  = isTablet ? 16.sp : 20.sp;

    final List<Widget> rows = [];
    for (int i = 0; i < _teams.length; i += 3) {
      final int          rowIndex    = i ~/ 3;
      final List<Widget> rowChildren = [];
      for (int j = i; j < i + 3; j++) {
        if (j < _teams.length) {
          rowChildren.add(_DesktopTeamCard(
              data:      _teams[j],
              width:     cardW,
              primary:   primary,
              secondary: secondary,
              isTablet:  isTablet,
              isRtl:     isRtl));
        } else {
          rowChildren.add(SizedBox(width: cardW));
        }
        if (j < i + 2) rowChildren.add(SizedBox(width: 14.w));
      }
      rows.add(_Reveal(
        delay:     Duration(milliseconds: 80 + rowIndex * 80),
        direction: _SlideDirection.fromBottom,
        duration:  const Duration(milliseconds: 650),
        child: IntrinsicHeight(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowChildren)),
      ));
      if (i + 3 < _teams.length) rows.add(SizedBox(height: 14.h));
    }

    return Column(children: [
      _Reveal(
        delay:     const Duration(milliseconds: 60),
        direction: _SlideDirection.fromLeft,
        duration:  const Duration(milliseconds: 600),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(text: TextSpan(children: [
              TextSpan(
                text: _t('Meet Our Teams', 'تعرّف على فرقنا', isRtl),
                style: StyleText.fontSize24Weight600.copyWith(
                    fontSize:   meetFz,
                    fontWeight: FontWeight.w600,
                    color:      Colors.black87),
              ),
            ])),
          ],
        ),
      ),
      SizedBox(height: 18.h),
      ...rows,
    ]);
  }
}

class _DesktopTeamCard extends StatefulWidget {
  final _TeamData data;
  final double    width;
  final Color     primary;
  final Color     secondary;
  final bool      isTablet;
  final bool      isRtl;

  const _DesktopTeamCard({
    required this.data,
    required this.width,
    required this.primary,
    required this.secondary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  State<_DesktopTeamCard> createState() => _DesktopTeamCardState();
}

class _DesktopTeamCardState extends State<_DesktopTeamCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final double iconBoxSz = widget.isTablet ? 60.w  : 72.w;
    final double iconSz    = widget.isTablet ? 30.w  : 36.w;
    final double nameFz    = widget.isTablet ? 10.sp : 11.sp;
    final double descFz    = widget.isTablet ? 9.sp  : 10.sp;
    final double cardPad   = widget.isTablet ? 14.w  : 18.w;

    return SizedBox(
      width: widget.width,
      child: Container(
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: iconBoxSz, height: iconBoxSz,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: widget.secondary),
              child: Center(
                child: SvgPicture.asset(widget.data.svgPath,
                    width: iconSz, height: iconSz, fit: BoxFit.contain,
                    colorFilter:
                    ColorFilter.mode(widget.primary, BlendMode.srcIn)),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                  color: widget.primary,
                  borderRadius: BorderRadius.circular(6.r)),
              child: Text(widget.data.name(widget.isRtl),
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight600.copyWith(
                      fontSize:   nameFz,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white)),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.data.desc(widget.isRtl),
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight400.copyWith(
                          fontSize: descFz,
                          height: 1.6,
                          color: AppColors.secondaryText.withOpacity(.7))),
                  SizedBox(height: 12.h),
                  _DesktopDeliverableButtons(
                    deliverables:  widget.data.deliverables(widget.isRtl),
                    primary:       widget.primary,
                    isRtl:         widget.isRtl,
                    fontSize:      descFz,
                    selectedIndex: _selectedIndex,
                    onSelectIndex: (index) => setState(() {
                      _selectedIndex =
                      _selectedIndex == index ? null : index;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopDeliverableButtons extends StatelessWidget {
  final List<String>      deliverables;
  final Color             primary;
  final bool              isRtl;
  final double            fontSize;
  final int?              selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const _DesktopDeliverableButtons({
    required this.deliverables,
    required this.primary,
    required this.isRtl,
    required this.fontSize,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w, runSpacing: 6.h,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _t('Deliverables:', 'المخرجات:', isRtl),
          style: StyleText.fontSize11Weight600.copyWith(
              fontSize:   fontSize,
              fontWeight: FontWeight.w700,
              color:      Colors.black87),
        ),
        ...List.generate(deliverables.length, (index) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelectIndex(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6.r)),
                child: Text(deliverables[index],
                    style: StyleText.fontSize11Weight400.copyWith(
                        fontSize:   fontSize,
                        color:      Colors.black54,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Desktop helper text widgets ─────────────────────────────────────────────

class _BulletText extends StatelessWidget {
  final String text;
  final double fontSize;
  const _BulletText(this.text, {this.fontSize = 13});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(top: 5.h, right: 7.w),
        child: Container(
          width: 5.w, height: 5.w,
          decoration: const BoxDecoration(
              color: Colors.black87, shape: BoxShape.circle),
        ),
      ),
      Expanded(child: _PlainText(text, fontSize: fontSize)),
    ],
  );
}

class _PlainText extends StatelessWidget {
  final String text;
  final double fontSize;
  const _PlainText(this.text, {this.fontSize = 13});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: StyleText.fontSize15Weight400.copyWith(
        fontSize: fontSize, height: 1.65, color: Colors.black87),
  );
}

// ── Desktop Apply Now button — now receives label from Firebase ───────────────
class _ApplyNowBtnDesktop extends StatefulWidget {
  final String label;   // ← from Firebase
  final Color  primary;
  final bool   isTablet;
  final bool   isRtl;
  const _ApplyNowBtnDesktop({
    required this.label,
    required this.primary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  State<_ApplyNowBtnDesktop> createState() => _ApplyNowBtnDesktopState();
}

class _ApplyNowBtnDesktopState extends State<_ApplyNowBtnDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:  SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit:  (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: () => context.go('/jobs'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 18.w : 22.w,
            vertical:   widget.isTablet ? 8.h  : 9.h),
        decoration: BoxDecoration(
          color: _hovered
              ? Color.alphaBlend(
              Colors.black.withOpacity(0.15), widget.primary)
              : widget.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          widget.label, // ← Firebase label
          style: StyleText.fontSize14Weight600.copyWith(
              fontSize:   widget.isTablet ? 11.sp : 13.sp,
              fontWeight: FontWeight.w600,
              color:      Colors.white),
        ),
      ),
    ),
  );
}