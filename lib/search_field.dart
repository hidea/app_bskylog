import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

final isDesktop = (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

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
  TextEditingValue? _lastValue;

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
                    suffixIcon: _editController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _editController.clear();
                              context.read<Model>().setSearchKeyword('');
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) =>
                      context.read<Model>().setSearchKeyword(value),
                  onChanged: _onChanged,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () =>
                  context.read<Model>().setSearchKeyword(_editController.text),
            ),
            if (isDesktop) const SizedBox(width: 8),
            if (isDesktop)
              IconButton(
                icon: Icon(widget.visible
                    ? Icons.arrow_circle_right_outlined
                    : Icons.manage_search),
                tooltip: widget.visible ? 'Close submenu' : 'Open submenu',
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
                      icon: Icon(Icons.close),
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
                  const Text('-'),
                  const SizedBox(width: 8),
                ]),
              StreamBuilder<int?>(
                stream: context.watch<Model>().filterSearchWatchCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('...');
                  } else if (snapshot.connectionState ==
                          ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return const Text('0 posts');
                    } else if (snapshot.hasData) {
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
    return TextButton.icon(
      icon: const Icon(Icons.navigate_before),
      label: const Text('prev'),
      onPressed: context.watch<Model>().canPrevSearch
          ? () => context.read<Model>().prevSearch()
          : null,
    );
  }

  Widget _buttonNext() {
    return TextButton.icon(
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.navigate_next),
      label: const Text('next'),
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
