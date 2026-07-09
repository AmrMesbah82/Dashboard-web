part of '../../pages/contact_us_edit.dart';

class _SocialLinkDropdown extends StatelessWidget {
  final List<SocialLinkModel> footerLinks;
  /// The currently selected index into [footerLinks], or null if nothing chosen.
  final int?                  selectedIndex;
  final ValueChanged<int?>    onChanged;
  final bool                  submitted;

  const _SocialLinkDropdown({
    required this.footerLinks,
    required this.selectedIndex,
    required this.onChanged,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError =
        submitted && (selectedIndex == null);

    // ── Loading state ──────────────────────────────────────────────────────
    if (footerLinks.isEmpty) {
      return Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color:        const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14.w, height: 14.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2, color: ColorPick.primary,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Loading footer social links...',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   12.sp,
                color:      Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // ── Build items — VALUE IS ALWAYS THE INDEX (unique by definition) ──────
    final items = footerLinks.asMap().entries.map((entry) {
      final index  = entry.key;
      final link   = entry.value;
      final hasUrl = link.url.isNotEmpty;

      return DropdownMenuItem<int>(
        value:   index,        // ← always unique
        enabled: hasUrl,       // disabled when no URL
        child: Row(
          children: [
            // Icon preview box
            Container(
              width:  36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color:        hasUrl
                    ? const Color(0xFFE8F5EE)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6.r),

              ),
              child: Center(
                child: link.iconUrl.isNotEmpty
                    ? NetworkImageView(
                  url:    link.iconUrl,
                  width:  20.w, height: 20.w, fit: BoxFit.contain,
                )
                    : Icon(
                  Icons.link, size: 16.sp,
                  color: hasUrl ? ColorPick.primary : Colors.grey.shade400,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            // URL text
            Expanded(
              child: Text(
                hasUrl
                    ? _truncateUrl(link.url)
                    : 'Social ${index + 1} — no URL set',
                overflow:  TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   12.sp,
                  color:      hasUrl ? Colors.black87 : Colors.grey.shade400,
                  fontStyle:  hasUrl ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
            // "No URL" badge for disabled items
            if (!hasUrl)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color:        Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'No URL',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   10.sp,
                    color:      Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();

    // ── Selected item display (shown in the closed dropdown) ───────────────
    // Flutter calls selectedItemBuilder[selectedIndex] to render the closed
    // state — so every entry must show the SELECTED link, not its own link.
    final selectedLink = selectedIndex != null &&
        selectedIndex! < footerLinks.length
        ? footerLinks[selectedIndex!]
        : null;

    Widget _selectedDisplay() {
      if (selectedLink == null) {
        return Row(
          children: [
            Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400),
            SizedBox(width: 8.w),
            Text(
              'Select a social link from footer',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   12.sp,
                color:      Colors.grey.shade400,
              ),
            ),
          ],
        );
      }
      return Row(
        children: [
          if (selectedLink.iconUrl.isNotEmpty)
            NetworkImageView(
              url: selectedLink.iconUrl,
              width: 18.w, height: 18.w, fit: BoxFit.contain,
            )
          else
            Icon(Icons.link, size: 16.sp, color: ColorPick.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              selectedLink.url.isNotEmpty
                  ? _truncateUrl(selectedLink.url)
                  : 'Social ${selectedIndex! + 1}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   12.sp,
                color:      Colors.black87,
              ),
            ),
          ),
        ],
      );
    }

    // One identical widget per item — Flutter picks by index, all show the same selected state
    final selectedItemWidgets =
    List.generate(footerLinks.length, (_) => _selectedDisplay());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),

          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value:      selectedIndex,   // int? — always unique
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.sp, color: Colors.grey.shade600,
              ),
              hint: Row(
                children: [
                  Icon(Icons.link, size: 16.sp, color: Colors.grey.shade400),
                  SizedBox(width: 8.w),
                  Text(
                    'Select a social link from footer',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   12.sp,
                      color:      Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              selectedItemBuilder: (_) => selectedItemWidgets,
              items:     items,
              onChanged: (idx) {
                if (idx == null) return;
                // Extra guard: don't allow selecting a link with no URL
                if (footerLinks[idx].url.isEmpty) return;
                onChanged(idx);
              },
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            'Please select a social link',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   11.sp,
              color:      ColorPick.red,
            ),
          ),
        ],
      ],
    );
  }

  String _truncateUrl(String url) {
    final clean = url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    return clean.length > 38 ? '${clean.substring(0, 38)}…' : clean;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════════════
