import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade100,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slash',
      home: NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];
  int selectedIndex = 0;

  void selectItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void updateNoteList(Note updatedNote) {
    setState(() {
      // Find the index of the updated note in the list and replace it with the updated note
      int index = notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        notes[index] = updatedNote;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 16, top: 5),
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/logo.jpg'),
            ),
          ),
        ),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      // Handle left menu icon tap
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.list),
                    onPressed: () {
                      // Handle right menu icon tap
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.account_circle),
                    onPressed: () {
                      // Handle right menu icon tap
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FullEntryScreen(note: notes[index])),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notes[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          if (notes[index].image.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.file(
                                File(notes[index].image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          Text(
                            notes[index].content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen(onUpdate: (Note ) {  }, note: null,)),
          ).then((value) {
            if (value != null) {
              setState(() {
                notes.add(value);
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade50,
        child: Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNavItem(0, Icons.photo_library, 'Library'),
              buildNavItem(1, Icons.favorite, 'For You'),
              buildNavItem(2, Icons.perm_media, 'Album'),
              buildNavItem(3, Icons.search, 'Search'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        selectItem(index);
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Note {
  String id;
  String title;
  String content;
  String image;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
  });
}

class FullEntryScreen extends StatelessWidget {
  final Note note;
  final Function updateNoteList;

  FullEntryScreen({required this.note,required this.updateNoteList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNoteScreen(note: note, onUpdate: updateNoteList),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.image.isNotEmpty)
          AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(
                    File(note.image),
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16.0),
              Text(
                note.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(height: 8.0),
              Text(
                note.content,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  final Note? note; // Declare the note parameter
  final Function(Note) onUpdate;

  AddNoteScreen({required this.note, required this.onUpdate});
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  File? imageFile;
  String? imageName;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with existing note data if available
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');

    // Set the image file and image name if available
    if (widget.note?.image != null) {
      imageFile = File(widget.note!.image);
      imageName = widget.note!.image.split('/').last;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        return;
      }
    }

    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        imageName = imageFile!.path.split('/').last; // Get the file name
      }
    });
  }

  void saveNote() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
    } else {
      // Create an updated note object with the new information
      Note updatedNote = Note(
        id: widget.note!.id, // Use the existing note's ID
        title: titleController.text,
        content: contentController.text,
        image: widget.note!.image, // Keep the existing image for now
      );

      // Call the onUpdate callback to update the note in the list
      widget.onUpdate(updatedNote);

      // Navigate back to the NoteListScreen
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageName != null)
              Text(
                imageName!,
                style: TextStyle(fontSize: 16.0),
              ),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Upload Image'),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 16.0),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: saveNote,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

