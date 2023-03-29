import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sugam_krishi/custom/fab_bottom_app_bar.dart';
import 'package:sugam_krishi/screens/FeedPage.dart';
import 'package:sugam_krishi/screens/MarketplacePage.dart';
import 'package:sugam_krishi/screens/ProfilePage.dart';
import 'package:sugam_krishi/screens/UtilitiesPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedDrawerIndex = 0;
  List<MenuModel> bottomMenuItems = <MenuModel>[];

  _selectedTab(int pos) {
    setState(() {
      _onSelectItem(pos);
    });

    switch (pos) {
      case 0:
        return FeedPage();
      case 1:
        return MarketplacePage();
      case 2:
        return UtilitiesPage();
      case 3:
        return ProfilePage();
      default:
        return Text("Invalid screen requested");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  @override
  void initState() {
    super.initState();

    _selectedTab(_selectedDrawerIndex);
    bottomMenuItems.add(new MenuModel('Create a post',
        'share your thoughts with the community', Icons.colorize));
    bottomMenuItems.add(new MenuModel(
        'Ask a Question', 'Any doubts? As the community', Icons.info));
    bottomMenuItems.add(new MenuModel(
        'Start a Poll', 'Need the opiniun of the many', Icons.equalizer));
    bottomMenuItems.add(new MenuModel('Organise an Event',
        'Start a meet with people to share your joys', Icons.event));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedTab(_selectedDrawerIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'ChatBot',
        splashColor: Colors.teal,
        onPressed: _modalBottomSheetMenu,
        child: Center(child: Icon(FontAwesomeIcons.robot)),
        elevation: 4,
      ),
      bottomNavigationBar: FABBottomAppBar(
        color: Colors.grey[700]!,
        selectedColor: Theme.of(context).colorScheme.secondary,
        notchedShape: CircularNotchedRectangle(),
        iconSize: 20.0,
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(
            iconData: FontAwesomeIcons.home,
            text: 'Community',
            iconSize: 20,
          ),
          FABBottomAppBarItem(
              iconData: FontAwesomeIcons.store,
              text: 'Marketplace',
              iconSize: 20),
          FABBottomAppBarItem(
              iconData: Icons.agriculture, text: 'Utilities', iconSize: 24),
          FABBottomAppBarItem(
              iconData: Icons.person, text: 'Profile', iconSize: 24),
        ],
        backgroundColor: Colors.white,
        centerItemText: '',
      ),
    );
  }

  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 440.0,
            color: Color(0xFF737373),
            child: Column(
              children: <Widget>[
                Container(
                  height: 300.0,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: new BoxDecoration(
                      color: Colors.white, //Color(0xFF737373),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: ListView.builder(
                      itemCount: bottomMenuItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(30)),
                              color: Colors.teal[100],
                            ),
                            child: Icon(
                              bottomMenuItems[index].icon,
                              color: Colors.teal,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                          title: Text(
                            bottomMenuItems[index].title,
                            style: TextStyle(color: Colors.teal, fontSize: 18),
                          ),
                          subtitle: Text(bottomMenuItems[index].subtitle),
                          onTap: () {
                            Navigator.pop(context);
                            debugPrint(bottomMenuItems[index].title);
                          },
                        );
                      }),
                ),

                //SizedBox(height: 10),

                Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            size: 25, color: Colors.grey[900]))),
              ],
            ),
          );
        });
  }
}

class MenuModel {
  String title;
  String subtitle;
  IconData icon;

  MenuModel(this.title, this.subtitle, this.icon);
}