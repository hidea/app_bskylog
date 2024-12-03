import 'package:bskylog/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'define.dart';
import 'model.dart';

class SearchField extends StatefulWidget {
  const SearchField(
      {super.key, required this.visible, required this.onVisible});

  final bool visible;
  final Function(bool) onVisible;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _editController = TextEditingController();
  //TextEditingValue? _lastValue;

  @override
  void initState() {
    super.initState();

    final model = context.read<Model>();
    model.addListener(() {
      if (_editController.text != model.searchKeyword) {
        _editController.text = model.searchKeyword ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _editController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter a search term',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _editController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear',
                            iconSize: 16.0,
                            onPressed: () =>
                                context.read<Model>().setSearchKeyword(''),
                          )
                        : null,
                  ),
                  onSubmitted: (value) =>
                      context.read<Model>().setSearchKeyword(value),
                  onChanged: _onChanged,
                ),
              ),
            ),
            IconButton.filled(
              icon: Icon(Symbols.regular_expression),
              tooltip: 'Regex search',
              isSelected: context.watch<Model>().regExpSearch,
              onPressed: () => context.read<Model>().toggleRegExpSearch(),
            ),
            if (isDesktop)
              IconButton(
                icon: widget.visible
                    ? Icon(Icons.arrow_circle_right_outlined)
                    : Badge(
                        isLabelVisible: VisibleType.values.any((visibleType) =>
                            context.watch<Model>().visible(visibleType) !=
                            VisibleMode.show),
                        label: Text('✓'),
                        child: Icon(Icons.manage_search)),
                tooltip:
                    widget.visible ? 'Close Filter Menu' : 'Open Filter Menu',
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)))),
                onPressed: () => widget.onVisible(!widget.visible),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buttonPrev(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (context.watch<Model>().searchYear != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SizedBox(
                    height: 16.0,
                    width: 16.0,
                    child: IconButton.outlined(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear range',
                      iconSize: 12.0,
                      padding: EdgeInsets.zero,
                      onPressed: () => context.read<Model>().clearSearchRange(),
                    ),
                  ),
                ),
              if (context.watch<Model>().searchYear != null)
                Row(children: [
                  Text('${context.watch<Model>().searchYear}'),
                  if (context.watch<Model>().searchMonth != null)
                    Text('.${context.watch<Model>().searchMonth}'),
                  if (context.watch<Model>().searchDay != null)
                    Text('.${context.watch<Model>().searchDay}'),
                  const SizedBox(width: 8),
                ]),
              StreamBuilder<int?>(
                stream: context.watch<Model>().filterSearchWatchCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      print('filterSearchWatchCount error: ${snapshot.error}');
                    }
                    return const Text('0 posts');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('...');
                  } else if (snapshot.connectionState ==
                          ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Text('${snapshot.data.toString()} posts');
                    } else {
                      return const Text('0 posts');
                    }
                  } else {
                    return const Text('...');
                  }
                },
              )
            ]),
            _buttonNext(),
          ],
        ),
      ],
    );
  }

  Widget _buttonPrev() {
    return rdIconButton(
      icon: const Icon(Icons.navigate_before),
      label: 'prev',
      onPressed: context.watch<Model>().canPrevSearch
          ? () => context.read<Model>().prevSearch()
          : null,
    );
  }

  Widget _buttonNext() {
    return rdIconButton(
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.navigate_next),
      label: 'next',
      onPressed: context.watch<Model>().canNextSearch
          ? () => context.read<Model>().nextSearch()
          : null,
    );
  }

  void _onChanged(String value) {
    // Workaround for problem japanese IME
    /*
    final lastValue = _lastValue;
    _lastValue = _editController.value;
    if (lastValue != null) {
      if (lastValue.text != _editController.value.text &&
          lastValue.composing.isValid &&
          !_editController.value.composing.isValid) {
        final offset = lastValue.composing.end;
        _editController.text = lastValue.text;
        _editController.selection =
            TextSelection(baseOffset: offset, extentOffset: offset);
      }
    }
    */
  }
}
