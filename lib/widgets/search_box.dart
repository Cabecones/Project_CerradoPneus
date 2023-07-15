import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final Function(String) onSearch;

  SearchBox({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () => _showSearchDialog(context),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchTerm = '';

        return AlertDialog(
          title: Text('Pesquisar'),
          content: TextField(
            onChanged: (value) {
              searchTerm = value;
            },
            decoration: InputDecoration(hintText: 'Digite o termo de pesquisa'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onSearch(searchTerm);
                Navigator.of(context).pop();
              },
              child: Text('Pesquisar'),
            ),
          ],
        );
      },
    );
  }
}
