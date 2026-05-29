import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/app_colors.dart';
import '../../utils/color_extensions.dart';
import '../../l10n/generated/l10n.dart';
import '../../utils/responsive_layout.dart';

class SearchableDropdownDialog<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final String Function(T) getLabel;
  final bool Function(T, String)? filterFunction;
  final BuildContext parentContext;
  final Color? activeColor;
  final Gradient? activeGradient;

  const SearchableDropdownDialog({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.getLabel,
    required this.filterFunction,
    required this.parentContext,
    this.activeColor,
    this.activeGradient,
  });

  @override
  State<SearchableDropdownDialog<T>> createState() =>
      _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T>
    extends State<SearchableDropdownDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.filterFunction != null) {
            return widget.filterFunction!(item, query);
          }
          final label = widget.getLabel(item).toLowerCase();
          return label.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? AppColors.primary;
    final gradient = widget.activeGradient ?? AppColors.primaryGradient;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.of(widget.parentContext).please_select,
                          style: TextStyle(
                            fontSize: context.adaptiveFont(16.sp),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: context.adaptiveFont(13.sp)),
                    decoration: InputDecoration(
                      hintText: S.of(widget.parentContext).search,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        S.of(widget.parentContext).no_data,
                        style: TextStyle(
                          fontSize: context.adaptiveFont(13.sp),
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.selectedValue == item;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(color: color, width: 1.5)
                                : Border.all(color: AppColors.border, width: 1),
                            borderRadius: BorderRadius.circular(12.r),
                            color: isSelected
                                ? color.withOpacityCompat(0.05)
                                : Colors.white,
                          ),
                          child: ListTile(
                            selected: isSelected,
                            title: Text(
                              widget.getLabel(item),
                              style: TextStyle(
                                fontSize: context.adaptiveFont(13.sp),
                                color: isSelected
                                    ? color
                                    : AppColors.primaryText,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: color,
                                    size: context.adaptiveIcon(18.sp),
                                  )
                                : null,
                            onTap: () {
                              Navigator.of(context).pop(item);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
