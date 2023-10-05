import 'package:ecommerce/userScreen/delivery_status_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeliveryPage extends StatefulWidget {
  final int initialTabIndex;

  const DeliveryPage({super.key, required this.initialTabIndex});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String userUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this, initialIndex: widget.initialTabIndex);
    fetchUserUid();
  }

  Future<void> fetchUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userUid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Delivery'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To Pay'),
            Tab(text: 'To Ship'),
            Tab(text: 'To Receive'),
            Tab(text: 'Complete'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DeliveryStatusPage(
            title: 'To Pay',
            userUid: userUid,
          ),
          DeliveryStatusPage(
            title: 'To Ship',
            userUid: userUid,
          ),
          DeliveryStatusPage(
            title: 'To Receive',
            userUid: userUid,
          ),
          DeliveryStatusPage(
            title: 'Complete',
            userUid: userUid,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
