import 'package:flutter/material.dart';
import 'browse_posts_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

class Post {
  final String title;
  final String price;
  final String description;
  final List<String> imagePaths;

  Post({
    required this.title,
    required this.price,
    required this.description,
    required this.imagePaths,
  });
}

// 模拟数据库
// List<Post> globalPosts = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Authentication
  await FirebaseAuth.instance.signInAnonymously();

  runApp(const HyperGarageSaleApp());
}

class HyperGarageSaleApp extends StatelessWidget {
  const HyperGarageSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperGarageSale',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BrowsePostsPage(),
    );
  }
}
