import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_social/utils/time.dart';
import 'package:the_social/widgets/comment.dart';
import 'package:the_social/widgets/comment_button.dart';
import 'package:the_social/widgets/like_button.dart';

class PostTile extends StatefulWidget {
  final String message;
  final String author;
  final String postId;
  final List<String> likes;

  const PostTile({
    super.key,
    required this.message,
    required this.author,
    required this.postId,
    required this.likes,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final commentController = TextEditingController();

  bool isLiked = false;
  bool showComments = false;
  int noOfComments = 0;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef = FirebaseFirestore.instance
        .collection('social_posts')
        .doc(widget.postId);

    if (isLiked) {
      postRef.update({
        "likes": FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postRef.update({
        "likes": FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  void addComment(String text) {
    FirebaseFirestore.instance
        .collection("social_posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
      "text": text,
      "by": currentUser.email,
      "time": DateTime.now(),
    });
  }

  void showComment() {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text(
              "Add comment",
              style: TextStyle(color: Colors.yellow),
            ),
            backgroundColor: Colors.grey[900],
            content: TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.yellow,
                  ),
                ),
              ),
              controller: commentController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  commentController.clear();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  addComment(commentController.text);
                  Navigator.pop(context);
                  commentController.clear();
                },
                child: const Text(
                  "Post",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )),
    );
  }

  void deletePost() async {
    final allComments = await FirebaseFirestore.instance
        .collection("social_posts")
        .doc(widget.postId)
        .collection("comments")
        .get();

    for (var doc in allComments.docs) {
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance
        .collection("social_posts")
        .doc(widget.postId)
        .delete();
  }

  Widget deleteBackground({
    required bool isDismissable,
    bool isRight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDismissable ? Colors.red : Colors.grey[100],
      ),
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(
        top: 25,
        left: 25,
        right: 25,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: Icon(
        Icons.delete,
        color: isDismissable ? Colors.white : Colors.grey[100],
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDismissable = widget.author == currentUser.email;

    return Dismissible(
      confirmDismiss: (direction) async {
        return isDismissable;
      },
      onDismissed: (direction) async {
        deletePost();
        return;
      },
      background: deleteBackground(
        isDismissable: isDismissable,
      ),
      secondaryBackground: deleteBackground(
        isDismissable: isDismissable,
        isRight: true,
      ),
      key: Key(widget.postId),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.author,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Divider(
              color: Colors.grey[200],
            ),

            // buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Like
                Row(
                  children: [
                    LikeButton(
                      isLiked: isLiked,
                      onTap: toggleLike,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.likes.length.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  width: 20,
                ),

                // comments
                Row(
                  children: [
                    CommentButton(
                      onTap: showComment,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("social_posts")
                            .doc(widget.postId)
                            .collection("comments")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();

                          return Text(
                            snapshot.data!.docs.length.toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          );
                        }),
                  ],
                ),

                const SizedBox(
                  width: 20,
                ),

                // toggle view
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showComments = !showComments;
                    });
                  },
                  child: Icon(
                    showComments ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                )
              ],
            ),

            //comments
            Visibility(
              visible: showComments,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("social_posts")
                        .doc(widget.postId)
                        .collection("comments")
                        .orderBy("time", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.yellow,
                          ),
                        );
                      }

                      return SizedBox(
                        height: snapshot.data!.docs.isEmpty ? 0 : 160,
                        child: ListView(
                          children: snapshot.data!.docs.map((doc) {
                            final comment = doc.data() as Map<String, dynamic>;

                            return Comment(
                              text: comment["text"],
                              user: comment["by"],
                              time: formatTime(comment["time"]),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
