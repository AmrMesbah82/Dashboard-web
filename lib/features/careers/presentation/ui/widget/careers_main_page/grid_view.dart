part of '../../pages/careers_main_page.dart';

class _GridView extends StatelessWidget {
  final List<InternModel> interns;
  final InternCubit       cubit;
  const _GridView({required this.interns, required this.cubit});

  @override
  Widget build(BuildContext context) {
    const int cols = 3;
    final rows = <Widget>[];

    for (int i = 0; i < interns.length; i += cols) {
      final rowItems = <Widget>[];
      for (int j = i; j < i + cols; j++) {
        if (j < interns.length) {
          rowItems.add(Expanded(child: _InternCard(intern: interns[j], cubit: cubit)));
        } else {
          rowItems.add(const Expanded(child: SizedBox()));
        }
        if (j < i + cols - 1) rowItems.add(SizedBox(width: 14.w));
      }
      rows.add(IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: rowItems)));
      if (i + cols < interns.length) rows.add(SizedBox(height: 14.h));
    }

    return Column(children: rows);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLE VIEW  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
