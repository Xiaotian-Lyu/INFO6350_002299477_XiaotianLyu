import 'package:flutter/material.dart';
import 'main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<XFile> _images = [];

  Future<void> _pickImage() async {
    if (_images.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 4 images allowed.')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _submitPost() async {
    String title = _titleController.text.trim();
    String price = _priceController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isEmpty || price.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      List<String> imageUrls = [];

      for (var image in _images) {
        try {
          File file = File(image.path);

          if (await file.exists()) {
            int fileSize = await file.length();
            print('文件存在，路径是：${image.path}');
            print('文件大小：$fileSize 字节');

            if (fileSize == 0) {
              print('文件是空的！');
              continue;
            }

            String fileName = DateTime.now().millisecondsSinceEpoch.toString();
            Reference ref = FirebaseStorage.instance.ref().child(
              'post_images/$fileName.jpg',
            );

            UploadTask uploadTask = ref.putFile(file);
            TaskSnapshot snapshot = await uploadTask;

            if (snapshot.state == TaskState.success) {
              String downloadUrl = await snapshot.ref.getDownloadURL();
              imageUrls.add(downloadUrl);
              print("上传成功: $downloadUrl");
            } else {
              print("上传状态异常: ${snapshot.state}");
            }
          } else {
            print('找不到文件：${image.path}');
          }
        } catch (e) {
          print("上传失败: $e");
        }
      }

      // 在写入前打印图片链接
      print('尝试写入 Firestore 的图片链接：$imageUrls');

      try {
        await FirebaseFirestore.instance.collection('posts').add({
          'title': title,
          'price': price,
          'description': description,
          'images': imageUrls,
          'createdAt': Timestamp.now(),
        });

        print('Firestore 写入成功！');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Firestore 写入失败: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Firestore error: $e')));
      }
    } catch (e) {
      print("总体错误: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitPost,
            tooltip: 'Submit Post',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              const Text(
                'Photos (max 4):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        File(_images[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submitPost, child: const Text('Post')),
            ],
          ),
        ),
      ),
    );
  }
}
