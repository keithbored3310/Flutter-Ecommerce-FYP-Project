import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/product_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchRecords = [];

  Future<void> _refreshData() async {
    _loadSearchRecords();
  }

  void _clearSearchRecords() async {
    setState(() {
      searchRecords.clear();
    });

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('searchRecords')
        .where('userId', isEqualTo: userId)
        .get();

    List<QueryDocumentSnapshot> docsToDelete = [];
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      docsToDelete.add(doc);
    }

    for (QueryDocumentSnapshot doc in docsToDelete) {
      await doc.reference.delete();
    }
  }

  void _performSearch() async {
    String query = _searchController.text;

    if (query.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await FirebaseFirestore.instance.collection('searchRecords').add({
        'userId': userId,
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _searchController.clear();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductPanelScreen(query: query),
        ),
      );

      _loadSearchRecords();
    }
  }

  void _loadSearchRecords() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('searchRecords')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    List<String> loadedSearchRecords =
        snapshot.docs.map((doc) => doc['query'] as String).toList();

    setState(() {
      searchRecords = loadedSearchRecords;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';

    _loadSearchRecords();
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter search keywords',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _clearSearchRecords,
                  child: const Text('Clear Search Records'),
                ),
              ],
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
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          searchRecords[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          _searchController.text = searchRecords[index];
                          _performSearch();
                        },
                      ),
                      const Divider(
                        thickness: 2.0,
                        color: Colors.black,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
