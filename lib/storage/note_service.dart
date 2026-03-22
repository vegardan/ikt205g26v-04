import 'package:ikt205g26v_04/storage/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  final supabase = Supabase.instance.client;

  factory NoteService() => _instance;

  NoteService._internal();

  Future<List<Note>> getNotes() async {
    final data = await supabase.from('notes').select().order('updated_at', ascending: false);

    return (data as List).map((json) => Note.fromJson(json)).toList();
  }

  Future<Note> createNote(String title, String text) async {
    final user = supabase.auth.currentUser!;

    final response = await supabase.from('notes').insert({'title': title, 'text': text, 'user_id': user.id}).select().single();

    return Note.fromJson(response);
  }

  Future<void> updateNote(int id, String title, String text) async {
    await supabase.from('notes').update({'title': title, 'text': text}).eq('id', id);
  }

  Future<void> deleteNote(int id) async {
    await supabase.from('notes').delete().eq('id', id);
  }
}
