import 'package:ecommerce/screens/product_panel.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> searchRecords = [];

  void _clearSearchRecords() {
    setState(() {
      searchRecords.clear();
    });
  }

  void _performSearch() {
    String query = _searchController.text;

    // Perform the search operation here
    // You can use the query to search for results and display them on a new screen
    // In this example, we are just adding the search query to the list of search records

    setState(() {
      searchRecords.insert(0, query);
    });

    // Navigate to the search results screen passing the search query
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPanelScreen(query: query),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Retrieve the search query if available
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _searchController.text =
          ModalRoute.of(context)?.settings.arguments as String? ?? '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter search query',
              suffixIcon: ElevatedButton(
                onPressed: _performSearch,
                child: const Text('Search'),
              ),
            ),
            onSubmitted: (_) {
              _performSearch();
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearSearchRecords,
            child: const Text('Clear Search Records'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Past Search Records:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchRecords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchRecords[index]),
                  onTap: () {
                    // Perform the search again when a past search record is tapped
                    _searchController.text = searchRecords[index];
                    _performSearch();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
