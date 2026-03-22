import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/pages/details.dart';
import 'package:ikt205g26v_04/storage/note.dart';
import 'package:ikt205g26v_04/storage/note_service.dart';
import 'package:ikt205g26v_04/utils/snackbar_utils.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NoteListWidget extends StatefulWidget {
  const NoteListWidget({super.key});

  @override
  State<NoteListWidget> createState() => _NoteListWidgetState();
}

class _NoteListWidgetState extends State<NoteListWidget> {
  late final PagingController<int, Note> _pagingController;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, Note>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) {
          return null;
        }

        return state.items?.length ?? 0;
      },
      fetchPage: (pageKey) {
        return NoteService().getNotes(from: pageKey);
      },
    );
  }

  Future<void> _refresh() async {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(_refresh),
      child: PagingListener<int, Note>(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedListView<int, Note>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<Note>(
            firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            firstPageErrorIndicatorBuilder: (_) => Center(child: Text('Failed to load notes: ${state.error}')),
            noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('No notes yet.')),
            itemBuilder: (context, note, index) {
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

                  _pagingController.refresh();
                },
                child: ListTile(
                  title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(note.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailsPage(note)));
                    _pagingController.refresh();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
