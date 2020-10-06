import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../providers/theme_notifier.dart';
import '../routing/route_constant.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase _database = FirebaseDatabase.instance;
  String nodeName = "posts";
  List<Post> postsList = <Post>[];

  bool swithValue = false;

  @override
  void initState() {
    _database.reference().child(nodeName).onChildAdded.listen(_childAdded);
    _database.reference().child(nodeName).onChildRemoved.listen(_childRemoves);
    _database.reference().child(nodeName).onChildChanged.listen(_childChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    swithValue = themeChange.darkTheme;

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blog App",
        ),
      ),
      body: Container(
        // color: Colors.white,
        child: Column(
          children: <Widget>[
            Visibility(
              visible: postsList.isEmpty,
              child: Center(
                child: Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Visibility(
              visible: postsList.isNotEmpty,
              child: Flexible(
                child: FirebaseAnimatedList(
                    query: _database.reference().child('posts'),
                    itemBuilder: (_, DataSnapshot snap,
                        Animation<double> animation, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 5.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RouteConstant.VIEW_POST,
                                arguments: postsList[index]);
                          },
                          child: Card(
                              elevation: 4.0,
                              color: Colors.deepPurple,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.border_color,
                                          size: 18.0,
                                        ),
                                        SizedBox(width: 15,),
                                        Text(
                                          postsList[index].title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      postsList[index].body,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstant.ADD_POST);
        },
        child: Icon(
          Icons.edit,
        ),
        tooltip: "Add a post",
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Image.asset(
              'assets/blogging.png',
              fit: BoxFit.contain,
              height: height * 0.2,
            ),
            Ink(
              child: ListTile(
                title: Text("About",
                    style: TextStyle(
                      fontSize: 15.0,
                      // color: Colors.black,
                      fontWeight: FontWeight.w600,
                    )),
                trailing: Icon(
                  Icons.details,
                  color: Colors.blueAccent,
                ),
                onTap: () {
                  Navigator.pushNamed(context, RouteConstant.PROFILE);
                },
              ),
            ),
            Ink(
              child: ListTile(
                title: Text("Close",
                    style: TextStyle(
                      fontSize: 15.0,
                      // color: Colors.black,
                      fontWeight: FontWeight.w600,
                    )),
                trailing: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Ink(
              child: ListTile(
                title: Text("Dark Mode",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    )),
                trailing: Switch(
                  activeColor: Colors.green,
                  value: swithValue,
                  onChanged: (bool value) {
                    setState(() {
                      swithValue = !swithValue;
                      themeChange.darkTheme = swithValue;
                    });
                    //print("Dark Mode");
                  },
                ),
                onTap: () {
                  setState(() {
                    swithValue = !swithValue;
                    themeChange.darkTheme = swithValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _childAdded(Event event) {
    setState(() {
      postsList.add(Post.fromSnapshot(event.snapshot));
    });
  }

  void _childRemoves(Event event) {
    var deletedPost = postsList.singleWhere((post) {
      return post.key == event.snapshot.key;
    });

    setState(() {
      postsList.removeAt(postsList.indexOf(deletedPost));
    });
  }

  void _childChanged(Event event) {
    var changedPost = postsList.singleWhere((post) {
      return post.key == event.snapshot.key;
    });
    setState(() {
      postsList[postsList.indexOf(changedPost)] =
          Post.fromSnapshot(event.snapshot);
    });
  }
}
