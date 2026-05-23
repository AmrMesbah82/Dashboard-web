part of '../../pages/degital_services/services_digital_edit.dart';

class _JourneyGrid extends StatelessWidget {
  final List<JourneyItemModel> items;
  const _JourneyGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    // Break into rows of 4
    final List<List<JourneyItemModel>> rows = [];
    for (int i = 0; i < items.length; i += 4) {
      rows.add(items.skip(i).take(4).toList());
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row.map((item) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _JourneyMiniCard(item: item),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
