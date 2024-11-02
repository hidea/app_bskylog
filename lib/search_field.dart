import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final textEditingController =
        TextEditingController(text: context.watch<Model>().searchKeyword);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter a search term',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              textEditingController.clear();
                              context.read<Model>().setSearchKeyword('');
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) =>
                      context.read<Model>().setSearchKeyword(value),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context
                  .read<Model>()
                  .setSearchKeyword(textEditingController.text),
            ),
            const SizedBox(width: 8),
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
}
