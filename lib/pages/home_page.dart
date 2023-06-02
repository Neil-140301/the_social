import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_social/pages/profile_page.dart';
import 'package:the_social/widgets/drawer.dart';
import 'package:the_social/widgets/text_input.dart';
import 'package:the_social/widgets/wall_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final textController = TextEditingController();

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("social_posts").add({
        "message": textController.text,
        "author_email": currentUser.email,
        "timestamp": Timestamp.now(),
        "likes": [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  void goToProfile() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'The Social',
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.yellow,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      drawer: MyDrawer(
        onLogout: signOut,
        onProfileTap: goToProfile,
      ),
      body: Center(
        child: Column(
          children: [
            // the wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("social_posts")
                    .orderBy("timestamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          return PostTile(
                            message: post["message"],
                            author: post["author_email"],
                            likes: List<String>.from(post["likes"] ?? []),
                            postId: post.id,
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            // post message
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: "Write something to social..",
                      obscureText: false,
                    ),
                  ),

                  // post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(
                      Icons.arrow_circle_up,
                    ),
                  )
                ],
              ),
            ),

            // Logged in as
            Text(
              "Logged in as: ${currentUser.email}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
