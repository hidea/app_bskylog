import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

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
                            onPressed: () => textEditingController.clear(),
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
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dropdownYear(),
            const SizedBox(width: 8),
            _dropdownMonth(),
            const SizedBox(width: 8),
            _dropdownDay(),
          ],
        ),
      ],
    );
  }

  Widget _dropdownYear() {
    final years = [null, 2023, 2024];
    return DropdownButton<int?>(
      value: context.watch<Model>().searchYear,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(height: 2, color: Colors.black),
      onChanged: (int? value) => context.read<Model>().setSearchYear(value),
      items: years.map<DropdownMenuItem<int?>>((int? value) {
        return DropdownMenuItem<int?>(
          value: value,
          child: Text(value == null ? 'year' : '$value'),
        );
      }).toList(),
    );
  }

  Widget _dropdownMonth() {
    final year = context.watch<Model>().searchYear;
    if (year == null) {
      return const SizedBox();
    }

    final month = [null, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    return DropdownButton<int?>(
      value: context.watch<Model>().searchMonth,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(height: 2, color: Colors.black),
      onChanged: (int? value) => context.read<Model>().setSearchMonth(value),
      items: month.map<DropdownMenuItem<int?>>((int? value) {
        return DropdownMenuItem<int?>(
          value: value,
          child: Text(value == null ? 'month' : '$value'),
        );
      }).toList(),
    );
  }

  Widget _dropdownDay() {
    final month = context.watch<Model>().searchMonth;
    if (month == null) {
      return const SizedBox();
    }

    final daysInMonth = DateTime(
      context.watch<Model>().searchYear!,
      context.watch<Model>().searchMonth! + 1,
      0,
    ).day;
    final List<int?> days = [null, for (int i = 1; i <= daysInMonth; i++) i];

    return DropdownButton<int?>(
      value: context.watch<Model>().searchDay,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(height: 2, color: Colors.black),
      onChanged: (int? value) => context.read<Model>().setSearchDay(value),
      items: days.map<DropdownMenuItem<int?>>((int? value) {
        return DropdownMenuItem<int?>(
          value: value,
          child: Text(value == null ? 'day' : '$value'),
        );
      }).toList(),
    );
  }
}
