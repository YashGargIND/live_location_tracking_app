// ignore_for_file: unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final List<String> _usernames = <String>[];
  final List<String> _selectedusernames = <String>[];
  final Map<String, bool> _selectedusernamesbool = <String, bool>{};
  bool _isSearching = false;
  late TextEditingController _searchQuery;
  late String searchQuery = 'bhoomi';
  static final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: _isSearching ? const BackButton() : null,
          title: _isSearching ? _buildSearchField() : _buildTitle(context),
          actions: _buildActions(),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: _usernames
                            .map((e) => _builtchip(e, Colors.pink))
                            .toList()
                            .cast<Widget>()))),
            Divider(thickness: 1.0),
            SizedBox(height: 100.0,
              child: ListView.builder(
                  itemCount: _usernames.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        selectedTileColor: Colors.grey[300],
                     hoverColor: Colors.grey[300],
                     leading: Icon(Icons.person),
                        tileColor: Colors.white,
                        trailing: GestureDetector(onTap: (){
                          setState(() {
                        if(!_selectedusernames.contains(_usernames[index])){
                        _selectedusernames.insert(_selectedusernames.length,_usernames[index]);
                        }
                        else{
                          _deleteselected(_usernames[index]);
                        }
                        });
                        },
                        child: (!_selectedusernames.contains(_usernames[index])) ? Icon(Icons.check,) : Icon(Icons.clear,)),
                        title:Text("${_usernames[index]}"),
                      onTap: (){setState(() {
                        if(!_selectedusernames.contains(_usernames[index])){
                        _selectedusernames.insert(_selectedusernames.length,_usernames[index]);
                        }
                        else{
                          ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('${_usernames[index]} is already selected '),));
                        }

                      });
                      }
                      ),
                    );
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){},
          child: Icon(Icons.check),),
        
        );
  }

  List<Widget>? _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            // print('closed searchbox');
            setState(() {
              _searchQuery.clear();
              updateSearchQuery('Search Query');
            });
          },
          icon: Icon(Icons.clear),
        )
      ];
    }
    return <Widget>[
      IconButton(
        onPressed: _startSearch,
        icon: Icon(Icons.search),
      )
    ];
  }

  Widget _buildSearchField() {
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.black54,
          )),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: updateSearchQuery,
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    // print(searchQuery);
    int i = 0;
    _usernames.clear();
    FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo : newQuery)
        .where('name', isLessThanOrEqualTo :  newQuery+ '\uf8ff')
        .get()
        .then((snapshot) {
          setState(() {
            print(snapshot.docs.length);
            snapshot.docs.forEach((element) {
        print(element['name'] + "in snapshot");
        if (element['uid'] != _uid) {
          if (!_usernames.contains(element['name'])) {
            _usernames.insert(i, element['name']);
            if (_selectedusernames.contains(element['name'])) {
              _selectedusernamesbool.update(element['name'], (value) => true,
                  ifAbsent: () => true);
            } else {
              _selectedusernamesbool.update(element['name'], (value) => false,
                  ifAbsent: () => false);
            }
          }
        }
        i++;
      }
           );   });}
      );
  }

    // print('Search Query is ' + searchQuery);
  // }

  Widget _buildTitle(BuildContext context) {
    return new InkWell(
      onTap: () => scaffoldKey.currentState?.openDrawer(),

      // print('Tapping');

      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Add Members'),
          ]),
    );
  }

  void _startSearch() {
    // print("open search box");
    ModalRoute.of(context)!
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    setState(() {
      _searchQuery.clear();
      updateSearchQuery('Search Query');
    });
    setState(() {
      _isSearching = false;
    });
  }


Widget _builtchip(String Label, Color color) {
  return Chip(
    labelPadding: EdgeInsets.all(2.0),
    avatar: CircleAvatar(
      backgroundColor: Colors.black,
      child: Text(Label[0].toUpperCase()),
    ),
    label: Text(
      Label,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    deleteIcon: Icon(
      Icons.close,
    ),
    onDeleted: () => _deleteselected(Label),
    backgroundColor: color,
    elevation: 6.0,
    padding: EdgeInsets.all(8.0),
  );
  
}
void _deleteselected(String label) {
  setState(
          () {
        _selectedusernames.removeAt(_selectedusernames.indexOf(label));
      },
    );
}
}
