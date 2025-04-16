import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'new_post_page.dart';
import 'post_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowsePostsPage extends StatefulWidget {
  const BrowsePostsPage({super.key});

  @override
  State<BrowsePostsPage> createState() => _BrowsePostsPageState();
}

class _BrowsePostsPageState extends State<BrowsePostsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // 每次进入页面刷新列表
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Posts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
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
              final postUid = post['uid'] ?? ''; // 防止 null 报错

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
                  trailing:
                      postUid == currentUid
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => NewPostPage(
                                            postId: post.id,
                                            initialTitle: title,
                                            initialPrice: price,
                                            initialDescription: description,
                                            initialImageUrls: imageUrls,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete Post',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Delete Post'),
                                          content: const Text(
                                            'Are you sure you want to delete this post?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true) {
                                    await post.reference.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Post deleted'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                          : null,
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
          setState(() {}); // 返回后刷新列表
        },
        tooltip: 'Create New Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
