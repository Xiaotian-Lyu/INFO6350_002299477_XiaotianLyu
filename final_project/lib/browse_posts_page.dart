import 'package:flutter/material.dart';
import 'new_post_page.dart';
import 'main.dart';
import 'post_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BrowsePostsPage extends StatefulWidget {
  const BrowsePostsPage({super.key});

  @override
  State<BrowsePostsPage> createState() => _BrowsePostsPageState();
}

class _BrowsePostsPageState extends State<BrowsePostsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // 每次进入页面刷新一下
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Posts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final title = post['title'];
              final price = post['price'];
              final description = post['description'];
              final imageUrls = List<String>.from(post['images']);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text('Price: \$$price\n$description'),
                  leading:
                      imageUrls.isNotEmpty
                          ? Image.network(
                            imageUrls[0],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image_not_supported),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PostDetailPage(
                              title: title,
                              price: price,
                              description: description,
                              imagePaths: imageUrls,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostPage()),
          );
          setState(() {}); // 回来时刷新列表
        },
        tooltip: 'Create New Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
