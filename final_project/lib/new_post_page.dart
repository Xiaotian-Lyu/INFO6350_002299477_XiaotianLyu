import 'package:flutter/material.dart';
import 'main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPostPage extends StatefulWidget {
  final String? postId;
  final String? initialTitle;
  final String? initialPrice;
  final String? initialDescription;
  final List<String>? initialImageUrls;

  const NewPostPage({
    super.key,
    this.postId,
    this.initialTitle,
    this.initialPrice,
    this.initialDescription,
    this.initialImageUrls,
  });

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<XFile> _newImages = [];
  final List<String> _imageUrls = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _priceController.text = widget.initialPrice ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    if (widget.initialImageUrls != null) {
      _imageUrls.addAll(widget.initialImageUrls!);
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (_imageUrls.length + _newImages.length >= 4) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _newImages.add(image));
  }

  Future<void> _pickImageFromGallery() async {
    if (_imageUrls.length + _newImages.length >= 4) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _newImages.add(image));
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || price.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      List<String> allImages = List.from(_imageUrls); // old images

      for (var image in _newImages) {
        final file = File(image.path);
        if (await file.exists() && await file.length() > 0) {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final ref = FirebaseStorage.instance.ref().child(
            'post_images/$fileName.jpg',
          );
          final snapshot = await ref.putFile(file);
          final url = await snapshot.ref.getDownloadURL();
          allImages.add(url);
        }
      }

      final data = {
        'title': title,
        'price': price,
        'description': description,
        'images': allImages,
        'createdAt': Timestamp.now(),
        'uid': FirebaseAuth.instance.currentUser?.uid,
      };

      if (widget.postId == null) {
        await FirebaseFirestore.instance.collection('posts').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update(data);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post saved!')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postId == null ? 'Create New Post' : 'Edit Post'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitPost,
            tooltip: 'Submit Post',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Old images from URL
                    ..._imageUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // New images from picker
                    ..._newImages.map(
                      (img) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(
                          File(img.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                ],
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
