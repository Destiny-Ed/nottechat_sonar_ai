import 'package:flutter/material.dart';

class SearchIcon extends StatefulWidget {
  final Function(String)? onChanged;
  const SearchIcon({super.key, required this.onChanged});

  @override
  _SearchIconState createState() => _SearchIconState();
}

class _SearchIconState extends State<SearchIcon> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.textTheme.bodyMedium!.color!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // spacing: 5,
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                decoration: InputDecoration(
                  hintText: 'Search Chat',
                  hintStyle: theme.textTheme.bodySmall,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      widget.onChanged!("");
                    },
                    child: Icon(Icons.clear, color: theme.textTheme.bodySmall!.color),
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.textTheme.bodyMedium!.color!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.textTheme.bodyMedium!.color!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: widget.onChanged,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(Icons.search, color: theme.textTheme.bodySmall!.color),
            ),
          ],
        ),
      ),
    );
  }
}
