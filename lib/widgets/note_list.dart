import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/pages/details.dart';
import 'package:ikt205g26v_04/storage/note.dart';
import 'package:ikt205g26v_04/storage/note_service.dart';
import 'package:ikt205g26v_04/utils/snackbar_utils.dart';

class NoteListWidget extends StatefulWidget {
  const NoteListWidget({super.key});

  @override
  State<NoteListWidget> createState() => _NoteListWidgetState();
}

class _NoteListWidgetState extends State<NoteListWidget> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    _notesFuture = NoteService().getNotes();
  }

  void refresh() {
    setState(() {
      _loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: _notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load notes: ${snapshot.error}'));
        }

        final notes = snapshot.data ?? const <Note>[];

        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet.'));
        }

        return RefreshIndicator(
          onRefresh: () async => refresh(),
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: ValueKey('note-$index'),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) {
                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete note?'),
                      content: Text('Delete "${note.title}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await NoteService().deleteNote(note.id);

                  SnackBarUtils.infoSnackBar(context, 'Note deleted');

                  refresh();
                },
                child: ListTile(
                  title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(note.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailsPage(note)));

                    setState(() {});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
