import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/pages/new_note.dart';
import 'package:ikt205g26v_04/pages/signup.dart';
import 'package:ikt205g26v_04/widgets/note_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Key _listKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        title: Text('CloudNotes - Jobb Notater'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                Supabase.instance.client.auth.signOut();

                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignupPage()));
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: NoteListWidget(key: _listKey),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New note',
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewNotePage()));
          setState(() {
            _listKey = UniqueKey();
          });
        },
        child: Icon(Icons.note_add),
      ),
    );
  }
}
