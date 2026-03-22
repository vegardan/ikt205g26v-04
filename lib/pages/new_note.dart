import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/storage/note.dart';
import 'package:ikt205g26v_04/storage/note_service.dart';
import 'package:ikt205g26v_04/utils/notification_service.dart';
import 'package:ikt205g26v_04/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<StatefulWidget> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  File? _pickedImage;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      final file = File(image!.path);

      // file size guard
      if (await file.length() > 15 * 1024 * 1024) {
        SnackBarUtils.errorSnackBar(context, 'Image must be under 15MB');
        return;
      }

      // file extension guard
      bool allowedExtension = false;
      for (String extension in ['.jpg', '.jpeg', '.png', '.webp']) {
        if (file.path.endsWith(extension)) {
          allowedExtension = true;
        }
      }

      if (!allowedExtension) {
        SnackBarUtils.errorSnackBar(context, 'Image must be JPG, PNG, or WebP');
      }

      setState(() {
        _pickedImage = file;
      });

      SnackBarUtils.infoSnackBar(context, 'Image picked');
    } catch (e) {
      SnackBarUtils.errorSnackBar(context, 'Image pick failed');
    }
  }

  void _uploadImage(Note note) {
    if (_pickedImage == null) {
      return;
    }

    try {
      Supabase.instance.client.storage.from('note-images').upload(note.image, _pickedImage!, fileOptions: const FileOptions(upsert: false));
    } catch (e) {
      SnackBarUtils.errorSnackBar(context, 'Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 6, title: Text('New Note')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 12,
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Title required' : null,
                ),

                TextFormField(
                  controller: _textController,
                  maxLines: 20,
                  decoration: const InputDecoration(labelText: 'Text', border: OutlineInputBorder(), alignLabelWithHint: true),
                  validator: (value) => value == null || value.isEmpty ? 'Text required' : null,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        _pickImage(ImageSource.camera);
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Capture'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        _pickImage(ImageSource.gallery);
                      },
                      icon: Icon(Icons.image),
                      label: Text('Gallery'),
                    ),
                  ],
                ),

                if (_pickedImage != null)
                  Stack(
                    children: [
                      Image(image: FileImage(_pickedImage!)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _pickedImage = null;
                          });
                          SnackBarUtils.infoSnackBar(context, 'Image cleared');
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ],
                  ),

                if (_loading) CircularProgressIndicator(),

                if (!_loading)
                  FilledButton.icon(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      setState(() {
                        _loading = true;
                      });

                      try {
                        Note note = await NoteService().createNote(_titleController.text.trim(), _textController.text.trim());
                        _uploadImage(note);
                        // demo delay
                        await Future.delayed(const Duration(seconds: 2));

                        Navigator.of(context).pop();

                        SnackBarUtils.infoSnackBar(context, 'Note created');

                        await NotificationService.instance.showNoteCreatedNotification(note);
                      } catch (e) {
                        print(e);
                        SnackBarUtils.errorSnackBar(context, 'Failed to create note');
                      } finally {
                        setState(() {
                          _loading = false;
                        });
                      }
                    },
                    icon: Icon(Icons.save),
                    label: Text('Save'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
