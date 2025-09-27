import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({
    super.key,
    required this.searchController,
    required this.onChanged,
  });
  final TextEditingController searchController;
  final Function(String) onChanged;

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.searchController,
      onChanged: (value) {
        widget.onChanged(value);
      },
      decoration: InputDecoration(
        hintText: 'Enter Product Name',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: widget.searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: 20,
                  color: Color.fromARGB(255, 180, 14, 14),
                ),
                onPressed: () => widget.searchController.clear(),
              )
            : const SizedBox.shrink(),
        filled: true,
        fillColor: const Color.fromARGB(255, 245, 244, 244),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 192, 191, 191),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
