import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DataProvider>(context, listen: false);
      provider.fetchData().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Two Tabs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'API'),
              Tab(text: 'Other'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ApiTab(), OtherTab()],
        ),
      ),
    );
  }
}

class ApiTab extends StatelessWidget {
  const ApiTab({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: provider.data.length,
      itemBuilder: (_, i) {
        final item = provider.data[i];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text(item['id'].toString()),
        );
      },
    );
  }
}

class OtherTab extends StatelessWidget {
  const OtherTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("This is the Other Tab"));
  }
}

class DataProvider with ChangeNotifier {
  final List<dynamic> _data = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    if (_hasFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse('https://dummyjson.com/recipes'));
      if (res.statusCode == 200) {
        _data.addAll(json.decode(res.body)['recipes']);
        _hasFetched = true;
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
