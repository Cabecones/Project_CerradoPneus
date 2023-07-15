import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final Function(String) onSearch;

  SearchBox({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
