import 'package:flutter/material.dart';

import '../shared/header.dart';
import 'range_days_view.dart';

/// A scrollable grid of months to allow picking a day range.
class RangeDaysPicker extends StatefulWidget {
  RangeDaysPicker({
    super.key,
    required this.minDate,
    required this.maxDate,
    this.initialDate,
    this.currentDate,
    this.selectedStartDate,
    this.selectedEndDate,
    this.daysOfTheWeekTextStyle,
    this.enabledCellsTextStyle,
    this.enabledCellsDecoration = const BoxDecoration(),
    this.disabledCellsTextStyle,
    this.disabledCellsDecoration = const BoxDecoration(),
    this.currentDateTextStyle,
    this.currentDateDecoration,
    this.selectedCellsTextStyle,
    this.selectedCellsDecoration,
    this.singelSelectedCellTextStyle,
    this.singelSelectedCellDecoration,
    this.onLeadingDateTap,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.leadingDateTextStyle,
    this.slidersColor,
    this.slidersSize,
    this.highlightColor,
    this.splashColor,
    this.splashRadius,
    this.centerLeadingDate = false,
  }) {
    assert(!minDate.isAfter(maxDate), "minDate can't be after maxDate");

    assert(
      () {
        if (initialDate == null) return true;
        final init = DateTime(initialDate!.year, initialDate!.month, initialDate!.day);

        final min = DateTime(minDate.year, minDate.month, minDate.day);

        return init.isAfter(min) || init.isAtSameMomentAs(min);
      }(),
      'initialDate $initialDate must be on or after minDate $minDate.',
    );
    assert(
      () {
        if (initialDate == null) return true;
        final init = DateTime(initialDate!.year, initialDate!.month, initialDate!.day);

        final max = DateTime(maxDate.year, maxDate.month, maxDate.day);
        return init.isBefore(max) || init.isAtSameMomentAs(max);
      }(),
      'initialDate $initialDate must be on or before maxDate $maxDate.',
    );
  }

  /// The date which will be displayed on first opening.
  /// If not specified, the picker will default to `DateTime.now()` date.
  ///
  /// Note that only dates are considered. time fields are ignored.
  final DateTime? initialDate;

  /// The date to which the picker will consider as current date. e.g (today).
  /// If not specified, the picker will default to `DateTime.now()` date.
  ///
  /// Note that only dates are considered. time fields are ignored.
  final DateTime? currentDate;

  /// The currently selected start date.
  ///
  /// This date is highlighted in the picker.
  ///
  /// Note that only dates are considered. time fields are ignored.
  final DateTime? selectedStartDate;

  /// The currently selected end date.
  ///
  /// This date is highlighted in the picker.
  ///
  /// Note that only dates are considered. time fields are ignored.
  final DateTime? selectedEndDate;

  /// Called when the user picks a start date.
  final ValueChanged<DateTime>? onStartDateChanged;

  /// Called when the user picks an end date.
  final ValueChanged<DateTime>? onEndDateChanged;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [maxDate].
  ///
  /// Note that only dates are considered. time fields are ignored.
  final DateTime minDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [minDate].
  ///
  /// Note that only dates are considered. time fields are ignored.
  final DateTime maxDate;

  /// Called when the user tap on the leading date.
  final VoidCallback? onLeadingDateTap;

  /// The text style of the days of the week in the header.
  ///
  /// defaults to [TextTheme.titleSmall] with a [FontWeight.bold],
  /// a `14` font size, and a [ColorScheme.onSurface] with 30% opacity.
  final TextStyle? daysOfTheWeekTextStyle;

  /// The text style of cells which are selectable.
  ///
  /// defaults to [TextTheme.titleLarge] with a [FontWeight.normal]
  /// and [ColorScheme.onSurface] color.
  final TextStyle? enabledCellsTextStyle;

  /// The cell decoration of cells which are selectable.
  ///
  /// defaults to empty [BoxDecoration].
  final BoxDecoration enabledCellsDecoration;

  /// The text style of cells which are not selectable.
  ///
  /// defaults to [TextTheme.titleLarge] with a [FontWeight.normal]
  /// and [ColorScheme.onSurface] color with 30% opacity.
  final TextStyle? disabledCellsTextStyle;

  /// The cell decoration of cells which are not selectable.
  ///
  /// defaults to empty [BoxDecoration].
  final BoxDecoration disabledCellsDecoration;

  /// The text style of the current date.
  ///
  /// defaults to [TextTheme.titleLarge] with a [FontWeight.normal]
  /// and [ColorScheme.primary] color.
  final TextStyle? currentDateTextStyle;

  /// The cell decoration of the current date.
  ///
  /// defaults to circle stroke border with [ColorScheme.primary] color.
  final BoxDecoration? currentDateDecoration;

  final TextStyle? selectedCellsTextStyle;

  final BoxDecoration? selectedCellsDecoration;

  /// The text style of a single selected cell and the
  /// leading/trailing cell of a selected range.
  final TextStyle? singelSelectedCellTextStyle;

  /// The cell decoration of a single selected cell and the
  /// leading/trailing cell of a selected range.
  final BoxDecoration? singelSelectedCellDecoration;

  /// The text style of leading date showing in the header.
  ///
  /// defaults to `18px` with a [FontWeight.bold]
  /// and [ColorScheme.primary] color.
  final TextStyle? leadingDateTextStyle;

  /// The color of the page sliders.
  ///
  /// defaults to [ColorScheme.primary] color.
  final Color? slidersColor;

  /// The size of the page sliders.
  ///
  /// defaults to `20px`.
  final double? slidersSize;

  /// The splash color of the ink response.
  ///
  /// defaults to the color of [selectedCellDecoration] with 30% opacity,
  /// if [selectedCellDecoration] is null will fall back to
  /// [ColorScheme.onPrimary] with 30% opacity.
  final Color? splashColor;

  /// The highlight color of the ink response when pressed.
  ///
  /// defaults to [Theme.highlightColor].
  final Color? highlightColor;

  /// The radius of the ink splash.
  final double? splashRadius;

  /// Centring the leading date. e.g:
  ///
  /// <       December 2023      >
  ///
  final bool centerLeadingDate;

  @override
  State<RangeDaysPicker> createState() => __RangeDaysPickerState();
}

class __RangeDaysPickerState extends State<RangeDaysPicker> {
  DateTime? _displayedMonth;
  final GlobalKey _pageViewKey = GlobalKey();
  late final PageController _pageController;
  // Represents the maximum height for a calendar with 6 weeks.
  // In scenarios where a month starts on the last day of a week,
  // it may extend into the first day of the sixth week to
  // accommodate the full month.
  double maxHeight = 52 * 7;

  @override
  void initState() {
    _displayedMonth = DateUtils.dateOnly(widget.initialDate ?? DateTime.now());
    _pageController = PageController(
      initialPage: DateUtils.monthDelta(widget.minDate, _displayedMonth!),
    );

    super.initState();
  }

  @override
  void didUpdateWidget(covariant RangeDaysPicker oldWidget) {
    // there is no need to check for the displayed month because it changes via
    // page view and not the initial date.
    // but for makeing debuging easy, we will navigate to the initial date again
    // if it changes.
    if (oldWidget.initialDate != widget.initialDate) {
      _displayedMonth = DateUtils.dateOnly(widget.initialDate ?? DateTime.now());
      _pageController.jumpToPage(
        DateUtils.monthDelta(widget.minDate, _displayedMonth!),
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    //
    //! days of the week
    //
    //
    final TextStyle daysOfTheWeekTextStyle = widget.daysOfTheWeekTextStyle ??
        textTheme.titleSmall!.copyWith(
          color: colorScheme.onSurface.withOpacity(0.30),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        );

    //
    //! enabled
    //
    //

    final TextStyle enabledCellsTextStyle = widget.enabledCellsTextStyle ??
        textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        );

    final BoxDecoration enabledCellsDecoration = widget.enabledCellsDecoration;

    //
    //! disabled
    //
    //

    final TextStyle disabledCellsTextStyle = widget.disabledCellsTextStyle ??
        textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface.withOpacity(0.30),
        );

    final BoxDecoration disbaledCellsDecoration = widget.disabledCellsDecoration;

    //
    //! current
    //
    //
    final TextStyle currentDateTextStyle = widget.currentDateTextStyle ??
        textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.normal,
          color: colorScheme.primary,
        );

    final BoxDecoration currentDateDecoration = widget.currentDateDecoration ??
        BoxDecoration(
          border: Border.all(color: colorScheme.primary),
          shape: BoxShape.circle,
        );

    //
    //! selected.
    //
    //

    final TextStyle selectedCellsTextStyle = widget.selectedCellsTextStyle ??
        textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.normal,
          color: colorScheme.onPrimaryContainer,
        );

    final BoxDecoration selectedCellsDecoration = widget.selectedCellsDecoration ??
        BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.rectangle,
        );

    //
    //! singel

    final TextStyle singelSelectedCellTextStyle = widget.singelSelectedCellTextStyle ??
        textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.normal,
          color: colorScheme.onPrimary,
        );

    final BoxDecoration singelSelectedCellDecoration = widget.singelSelectedCellDecoration ??
        BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        );

    //
    //
    //
    //! header
    final leadingDateTextStyle = widget.leadingDateTextStyle ??
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        );

    final slidersColor = widget.slidersColor ?? colorScheme.primary;
    final slidersSize = widget.slidersSize ?? 20;

    //
    //! splash
    final splashColor = widget.splashColor ?? selectedCellsDecoration.color?.withOpacity(0.3) ?? colorScheme.primary.withOpacity(0.3);

    final highlightColor = widget.highlightColor ?? Theme.of(context).highlightColor;
    //
    //

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Header(
          centerLeadingDate: widget.centerLeadingDate,
          leadingDateTextStyle: leadingDateTextStyle,
          slidersColor: slidersColor,
          slidersSize: slidersSize,
          onDateTap: () => widget.onLeadingDateTap?.call(),
          displayedDate: MaterialLocalizations.of(context)
              .formatMonthYear(_displayedMonth!)
              .replaceAll('٩', '9')
              .replaceAll('٨', '8')
              .replaceAll('٧', '7')
              .replaceAll('٦', '6')
              .replaceAll('٥', '5')
              .replaceAll('٤', '4')
              .replaceAll('٣', '3')
              .replaceAll('٢', '2')
              .replaceAll('١', '1')
              .replaceAll('٠', '0'),
          onNextPage: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          onPreviousPage: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          key: ValueKey(maxHeight),
          height: maxHeight,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            key: _pageViewKey,
            controller: _pageController,
            itemCount: DateUtils.monthDelta(widget.minDate, widget.maxDate) + 1,
            onPageChanged: (monthPage) {
              final DateTime monthDate = DateUtils.addMonthsToMonthDate(widget.minDate, monthPage);

              setState(() {
                _displayedMonth = monthDate;
              });
            },
            itemBuilder: (context, index) {
              final DateTime month = DateUtils.addMonthsToMonthDate(widget.minDate, index);

              return RangeDaysView(
                key: ValueKey<DateTime>(month),
                currentDate: DateUtils.dateOnly(widget.currentDate ?? DateTime.now()),
                minDate: DateUtils.dateOnly(widget.minDate),
                maxDate: DateUtils.dateOnly(widget.maxDate),
                displayedMonth: month,
                selectedEndDate: widget.selectedEndDate == null ? null : DateUtils.dateOnly(widget.selectedEndDate!),
                selectedStartDate: widget.selectedStartDate == null ? null : DateUtils.dateOnly(widget.selectedStartDate!),
                daysOfTheWeekTextStyle: daysOfTheWeekTextStyle,
                enabledCellsTextStyle: enabledCellsTextStyle,
                enabledCellsDecoration: enabledCellsDecoration,
                disabledCellsTextStyle: disabledCellsTextStyle,
                disabledCellsDecoration: disbaledCellsDecoration,
                currentDateDecoration: currentDateDecoration,
                currentDateTextStyle: currentDateTextStyle,
                selectedCellsDecoration: selectedCellsDecoration,
                selectedCellsTextStyle: selectedCellsTextStyle,
                singelSelectedCellTextStyle: singelSelectedCellTextStyle,
                singelSelectedCellDecoration: singelSelectedCellDecoration,
                highlightColor: highlightColor,
                splashColor: splashColor,
                splashRadius: widget.splashRadius,
                onEndDateChanged: (value) => widget.onEndDateChanged?.call(value),
                onStartDateChanged: (value) => widget.onStartDateChanged?.call(value),
              );
            },
          ),
        ),
      ],
    );
  }
}
