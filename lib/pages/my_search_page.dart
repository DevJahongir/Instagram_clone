import 'package:flutter/material.dart';
import 'package:instaclone/services/db_service.dart';

import '../model/member_model.dart';

class MySearchPage extends StatefulWidget {
  const MySearchPage({super.key});

  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  bool isLoading = false;
  var searchController = TextEditingController();
  List<Member> items = [];

  _apiSearchMembers(String keyword) async {
    var members = await DbService.searchMembers(keyword);

    setState(() {
      items = members;
    });
  }

  _apiUnFollowMember(Member someone)async{
    setState(() {
      isLoading = true;
    });
    await DbService.unfollowMember(someone);
    setState(() {
      someone.followed = false;
      isLoading = false;
    });

    DbService.removePostsFromMyFeed(someone);
  }

  _apiFollowMember(Member someone)async{
    setState(() {
      isLoading = true;
    });

    await DbService.followMember(someone);
    setState(() {
      someone.followed = true;
      isLoading = false;
    });

    DbService.storePostsToMyFeed(someone);

    // sendNotificationToFollowedMember(someone);
  }

  @override
  void initState() {
    super.initState();
    _apiSearchMembers("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Search",
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  // #search_member
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: 15, color: Colors.grey),
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          )),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        return _itemOfMember(items[index]);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _itemOfMember(Member member) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                width: 1.5,
                color: Color.fromRGBO(193, 53, 132, 1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: member.img_url.isEmpty
                  ? const Image(
                      image: AssetImage("assets/images/ic_person.png"),
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      member.img_url,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullname,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                member.email,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    if (member.followed) {
                      _apiUnFollowMember(member);
                    } else {
                      _apiFollowMember(member);
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: Center(
                      child:
                          member.followed ? Text("Following") : Text("Follow"),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
