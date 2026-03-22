import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/storage/note.dart';
import 'package:ikt205g26v_04/storage/note_service.dart';
import 'package:ikt205g26v_04/utils/snackbar_utils.dart';

class EditNotePage extends StatefulWidget {
  final Note note;

  const EditNotePage(this.note, {super.key});

  @override
  State<StatefulWidget> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.note.title;
    _textController.text = widget.note.text;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 6, title: Text('Edit Note')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _textController,
                  maxLines: 20,
                  decoration: const InputDecoration(labelText: 'Text', border: OutlineInputBorder(), alignLabelWithHint: true),
                  validator: (value) => value == null || value.isEmpty ? 'Text required' : null,
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    await NoteService().updateNote(widget.note.id, _titleController.text, _textController.text);

                    widget.note.title = _titleController.text;
                    widget.note.text = _textController.text;

                    Navigator.of(context).pop(true);

                    SnackBarUtils.infoSnackBar(context, 'Note updated');
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
