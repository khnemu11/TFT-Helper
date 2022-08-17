import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:shrine/model/baseItem.dart';
import 'package:shrine/model/champion.dart';
import 'package:shrine/model/finalItem.dart';
import 'package:shrine/profile.dart';

import 'BaseItemdetail.dart';
import 'FinalItemdetail.dart';
import 'Vedio.dart';
import 'applicationstate.dart';
import 'detail.dart';
import 'model/class.dart';
import 'model/combination.dart';
//https://console.firebase.google.com/u/0/project/lastproject-d2e02/overview
//라이엇 api는 유효 api key 기간이 개발 용으론 24시간 이므로 주의해야한다.
//유튜브 api 또한 하루 로딩 가능 영상 개수가 제한되어 잇으므로 주의해야한다.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileState()),
          ],
          child:const MyApp(),
      ),
  );
}

class ProfileState extends ChangeNotifier {
  ApplicationType _applicationState = ApplicationType.profileSearch;
  ApplicationType get applicationType => _applicationState;

  String _nickname="";
  String get nickname => _nickname;


  void profileSearch() {
    _applicationState = ApplicationType.profileSearch;
    notifyListeners();
  }
  void profileView(String name) {
    _applicationState = ApplicationType.profileView;
    _nickname = name;
    print("main nickname :  " +_nickname);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'TFT Helper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final tabs = ['현재 유닛', '추천 조합', '현재 아이템', '조합 아이탬'];
  final List<BaseItem> baseItemList = [];
  final List<Champion> championList = [];
  final List<FinalItem> finalItemList = [];
  final List<FinalItem> canFinalItemList = [];
  final List<Combination> combinationList = [];
  bool loadChampionFinish = false;
  final List<Class> classList = [];

  void _incrementCounter(List<BaseItem> baseItemList, int index) {
    int childIndex;
    int exits = 1;
    setState(() {
      baseItemList[index].count++;
      for (var item in finalItemList) {
        if (item.child.contains(baseItemList[index].name)) {
          print(item.name + " item detect " + baseItemList[index].name);
          childIndex = item.child.indexOf(baseItemList[index].name);
          item.childCount[childIndex]++;
          print(item.name + " " + item.child[childIndex] + " " +
              item.childCount[childIndex].toString());
          if (item.childCount[childIndex] >= item.childMaxCount[childIndex]) {
            print(baseItemList[index].name + "은 조건 만족 in " + item.name);
            for (int i = 0; i < item.child.length; i++) {
              if (item.childCount[i] < item.childMaxCount[i]) {
                exits = 0;
              }
            }
            if (exits == 1 && item.exist == 0) {
              item.exist = 1;
              canFinalItemList.add(item);
              print("add new final item!");
            }
          }
        }
        exits = 1;
      }
    });
  }

  void _decrementCounter(List<BaseItem> baseItemList, int index) {
    int childIndex;
    int exits = 1;
    List<FinalItem> toRemove = [];
    setState(() {
      if (baseItemList[index].count > 0) {
        baseItemList[index].count--;
        for (var item in finalItemList) {
          if (item.child.contains(baseItemList[index].name)) {
            childIndex = item.child.indexOf(baseItemList[index].name);
            item.childCount[childIndex]--;
            if (item.exist == 1 &&
                item.childCount[childIndex] < item.childMaxCount[childIndex]) {
              item.exist = 0;
              toRemove.add(item);
            }
          }
        }
      }
      for (var remove in toRemove) {
        for (var item in canFinalItemList) {
          if (item.name == remove.name) {
            canFinalItemList.remove(item);
            break;
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (baseItemList.isEmpty) loadItem(baseItemList);
    if (championList.isEmpty) {
      loadChampion(championList);
    }
    if (finalItemList.isEmpty) loadFinalItemList(finalItemList);
    if (combinationList.isEmpty) loadCombination(combinationList);
    if (classList.isEmpty) loadClass(classList);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
          bottom: TabBar(
            tabs: tabs.map((String tab) {
              return Tab(text: tab);
            }).toList(),
            isScrollable: true,
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search,
                semanticLabel: 'profile',
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: tabs.map((String tab) {
            if (tab == '현재 아이템' && baseItemList.isEmpty) {
              return const CircularProgressIndicator();
            }
            if (tab == '현재 유닛' && loadChampionFinish == false) {
              print("championList.length");
              print(championList.length);
              return const CircularProgressIndicator();
            }
            if (tab == '추천 조합' && combinationList.isEmpty) {
              return const CircularProgressIndicator();
            }
            if (tab == '조합 아이탬' && canFinalItemList.isEmpty) {
              return Column(
                children: const [
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        height: 40.0,
                        width: 40.0,
                      )
                  ),
                ],
              );
            }
            if (tab == '현재 아이템' && baseItemList.isNotEmpty) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: baseItemList.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                          children: [
                          const SizedBox(height: 8.0),
                            const ListTile(
                              trailing: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: SizedBox(height: 30.0,
                                  width: 65,
                                  child: Text("개수", style: TextStyle(
                                      fontSize: 14
                                  ),
                                  ),
                                ),
                              ),
                              title: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: SizedBox(height: 30.0,
                                      width: 40,
                                      child: Text("아이템", style: TextStyle(
                                                            fontSize: 16
                                      ),)
                    )),
                              leading: Padding(
                                padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                                child: SizedBox(height: 30.0,
                                    width: 100,
                                    child: Text("이름", style: TextStyle(
                        fontSize: 16
                                    ))),
                              ),),
                            const SizedBox(height: 8.0),
                            ListTile(
                              leading: AspectRatio(
                                aspectRatio: 3 / 2,
                                child: baseItemList[index].url == ""
                                    ? CircularProgressIndicator()
                                    : FlatButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            BaseItemDetailPage(
                                              item: baseItemList[index],
                                              baseItemList: baseItemList,
                                              finalItemList: finalItemList,
                                              championList: championList,
                                            )),);
                                    },
                                    child: Image.network(
                                        baseItemList[index].url)),
                              ),
                              title: Text(baseItemList[index].name),
                              trailing: Wrap(
                                spacing: 10, // space between two icons
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      _decrementCounter(baseItemList, index);
                                    },
                                  ),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 10.0, 0.0, 0.0),
                                      child: Text(
                                        baseItemList[index].count.toString(),
                                        style: const TextStyle(
                                          fontSize: 22,
                                        ),)
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _incrementCounter(baseItemList, index);
                                    },
                                  ), // icon-2
                                ],
                              ),
                            ),
                            const Divider(
                              height: 23,
                              thickness: 2,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ]);

                    }
                    return Column(
                        children: [
                          const SizedBox(height: 8.0),
                          ListTile(
                            leading: AspectRatio(
                              aspectRatio: 3 / 2,
                              child: baseItemList[index].url == ""
                                  ? CircularProgressIndicator()
                                  : FlatButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          BaseItemDetailPage(
                                            item: baseItemList[index],
                                            baseItemList: baseItemList,
                                            finalItemList: finalItemList,
                                            championList: championList,
                                          )),);
                                  },
                                  child: Image.network(
                                      baseItemList[index].url)),
                            ),
                            title: Text(baseItemList[index].name),
                            trailing: Wrap(
                              spacing: 10, // space between two icons
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    _decrementCounter(baseItemList, index);
                                  },
                                ),
                                Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 0.0),
                                    child: Text(
                                      baseItemList[index].count.toString(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                      ),)
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _incrementCounter(baseItemList, index);
                                  },
                                ), // icon-2
                              ],
                            ),
                          ),
                          const Divider(
                            height: 23,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ]
                    );
                  });
            }
            if (tab == '현재 유닛' && championList.isNotEmpty) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: championList.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                          children: [
                            const SizedBox(height: 8.0),
                            const ListTile(
                              trailing: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: SizedBox(height: 30.0,
                                  width: 25,
                                  child: Text("유닛 체크", style: TextStyle(
                                      fontSize: 14
                                  ),
                                  ),
                                ),
                              ),
                              title: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: SizedBox(height: 30.0,
                                      width: 40,
                                      child: Text("이름", style: TextStyle(
                                          fontSize: 16
                                      ),)
                                  )),
                              leading: Padding(
                                padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                                child: SizedBox(height: 30.0,
                                    width: 100,
                                    child: Text("챔피언", style: TextStyle(
                                        fontSize: 16
                                    ))),
                              ),),
                            Container(
                              padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                              child: Row(
                                children: [
                                  Icon(Icons.monetization_on_rounded,
                                      color: Colors.amber),
                                  Text("  "+championList[index + 1].cost.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 2,
                            ),
                            const SizedBox(height: 4.0),
                            Visibility(
                                visible: championList[index].name == "none"
                                    ? false
                                    : true,
                                child: ListTile(
                                  leading: FlatButton(
                                    onPressed: () {
                                      print(championList[index].name +
                                          "'s attrivute length : " +
                                          championList[index].attribute.length
                                              .toString());
                                      for (int i = 0; i <
                                          championList[index].attribute
                                              .length; i++) {
                                        print(championList[index].attribute[i]);
                                      }
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPage(champion: Champion(
                                                    range: championList[index]
                                                        .range,
                                                    item: championList[index]
                                                        .item,
                                                    mana: championList[index]
                                                        .mana,
                                                    count: championList[index]
                                                        .count,
                                                    url: championList[index]
                                                        .url,
                                                    skillName: championList[index]
                                                        .skillName,
                                                    name: championList[index]
                                                        .name,
                                                    description: championList[index]
                                                        .description,
                                                    skillType: championList[index]
                                                        .skillType,
                                                    attribute: championList[index]
                                                        .attribute,
                                                    cost: championList[index]
                                                        .cost,
                                                    skillUrl: championList[index]
                                                        .skillUrl,
                                                  ),
                                                      item: finalItemList,
                                                      classList: classList)));
                                    },
                                    child: Hero(
                                      tag: championList[index].name,
                                      child: AspectRatio(
                                        aspectRatio: 3 / 2,
                                        child: championList[index].url == "" ?
                                        CircularProgressIndicator()
                                            : Image.network(
                                            championList[index].url),
                                      ),
                                    ),
                                  ),

                                  title: Text(championList[index].name),
                                  trailing: Wrap(
                                    spacing: 10, // space between two icons
                                    children: <Widget>[
                                      IconButton(
                                        icon: championList[index].count == 0
                                            ? const Icon(
                                            Icons.check_box_outline_blank)
                                            :
                                        const Icon(Icons.check_box),
                                        onPressed: () {
                                          if (championList[index].count == 0) {
                                            championList[index].count = 1;

                                            for (int i = 0; i <
                                                combinationList.length; i++) {
                                              if (combinationList[i].child
                                                  .contains(
                                                  championList[index].name)) {
                                                combinationList[i].restCount--;
                                              }
                                            }

                                            combinationList.sort((a, b) =>
                                                a.restCount.compareTo(
                                                    b.restCount));

                                          }
                                          else {
                                            championList[index].count = 0;

                                            for (int i = 0; i <
                                                combinationList.length; i++) {
                                              if (combinationList[i].child
                                                  .contains(
                                                  championList[index].name)) {
                                                combinationList[i].restCount++;
                                              }
                                            }

                                            combinationList.sort((a, b) =>
                                                a.restCount.compareTo(
                                                    b.restCount));

                                          }
                                          setState(() {
                                            combinationList;
                                          });
                                        },
                                      ), // icon-2
                                    ],
                                  ),
                                )),
                          ]
                      );
                    }
                    else {
                      return Visibility(
                        visible: championList[index].name == "none"
                            ? false
                            : true,
                        child: Column(
                            children: [
                              const SizedBox(height: 5.0),
                              index != championList.length - 1 &&
                                  championList[index].cost !=
                                      championList[index + 1].cost ?
                              Container(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Icon(Icons.monetization_on_rounded,
                                        color: Colors.amber),
                                    Text(
                                        "  "+championList[index + 1].cost.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ],
                                ),
                              ) :
                              ListTile(
                                leading: FlatButton(
                                  onPressed: () {
                                    print(championList[index].name +
                                        "'s attrivute length : " +
                                        championList[index].attribute.length
                                            .toString());
                                    for (int i = 0; i <
                                        championList[index].attribute
                                            .length; i++) {
                                      print(championList[index].attribute[i]);
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            DetailPage(champion: Champion(
                                              range: championList[index].range,
                                              item: championList[index].item,
                                              mana: championList[index].mana,
                                              count: championList[index].count,
                                              url: championList[index].url,
                                              skillName: championList[index]
                                                  .skillName,
                                              name: championList[index].name,
                                              description: championList[index]
                                                  .description,
                                              skillType: championList[index]
                                                  .skillType,
                                              attribute: championList[index]
                                                  .attribute,
                                              cost: championList[index].cost,
                                              skillUrl: championList[index]
                                                  .skillUrl,
                                            ),
                                                item: finalItemList,
                                                classList: classList)));
                                  },
                                  child: Hero(
                                    tag: championList[index].name,
                                    child: AspectRatio(
                                      aspectRatio: 3 / 2,
                                      child: championList[index].url == "" ?
                                      CircularProgressIndicator()
                                          : Image.network(
                                          championList[index].url),
                                    ),
                                  ),
                                ),

                                title: Text(championList[index].name),
                                trailing: Wrap(
                                  spacing: 10, // space between two icons
                                  children: <Widget>[
                                    IconButton(
                                      icon: championList[index].count == 0
                                          ? const Icon(
                                          Icons.check_box_outline_blank)
                                          :
                                      const Icon(Icons.check_box),
                                      onPressed: () {
                                        if (championList[index].count == 0) {
                                          championList[index].count = 1;

                                          for (int i = 0; i <
                                              combinationList.length; i++) {
                                            if (combinationList[i].child
                                                .contains(
                                                championList[index].name)) {
                                              combinationList[i].restCount--;
                                            }
                                          }

                                          combinationList.sort((a, b) =>
                                              a.restCount.compareTo(
                                                  b.restCount));
                                          print("========");
                                          print("현재 조합 리스트");
                                          for (var team in combinationList) {
                                            print(team.name);
                                            print(team.restCount);
                                          }
                                        }
                                        else {
                                          championList[index].count = 0;

                                          for (int i = 0; i <
                                              combinationList.length; i++) {
                                            if (combinationList[i].child
                                                .contains(
                                                championList[index].name)) {
                                              combinationList[i].restCount++;
                                            }
                                          }

                                          combinationList.sort((a, b) =>
                                              a.restCount.compareTo(
                                                  b.restCount));
                                          print("========");
                                          print("현재 조합 리스트");
                                          for (var team in combinationList) {
                                            print(team.name);
                                            print(team.restCount);
                                          }
                                        }
                                        setState(() {
                                          combinationList;
                                        });
                                      },
                                    ), // icon-2
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 23,
                                thickness: 2,
                                indent: 10,
                                endIndent: 10,
                              ),
                            ]
                        ),
                      );
                    }
                  });
            }
            if (tab == '조합 아이탬' && canFinalItemList.isNotEmpty) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: canFinalItemList.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                          children: [
                          const SizedBox(height: 8.0),
                    const ListTile(
                    trailing: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: SizedBox(height: 30.0,
                    width: 65,
                    child: Text("이름", style: TextStyle(
                    fontSize: 14
                    ),
                    ),
                    ),
                    ),
                    title: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: SizedBox(height: 30.0,
                    width: 40,
                    child: Text("조합식", style: TextStyle(
                    fontSize: 16
                    ),)
                    )),
                    leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: SizedBox(height: 30.0,
                    width: 100,
                    child: Text("이미지", style: TextStyle(
                    fontSize: 16
                    ))),
                    ),),
                    const SizedBox(height: 8.0),
                            const SizedBox(height: 8.0),
                            ListTile(
                              leading: canFinalItemList[index].url.isEmpty
                                  ? CircularProgressIndicator()
                                  : FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        FinalItemDetailPage(
                                          item: canFinalItemList[index],
                                          baseItemList: baseItemList,
                                          finalItemList: finalItemList,
                                          championList: championList,
                                        )),);
                                }, child: Image.network(
                                canFinalItemList[index].url, width: 60,
                                height: 60,),),

                              title: Wrap(
                                spacing: 7, // space between two icons
                                children: <Widget>[
                                  const Icon(Icons.forward),
                                  Image.network(
                                    baseItemList[baseItemList.indexWhere(
                                            (item) =>
                                        item.name ==
                                            canFinalItemList[index].child[0])
                                    ].url, width: 35, height: 35,),
                                  const Icon(Icons.add),
                                  canFinalItemList[index].child.length == 1
                                      ? Image.network(
                                    baseItemList[baseItemList.indexWhere(
                                            (item) =>
                                        item.name ==
                                            canFinalItemList[index].child[0])]
                                        .url, width: 35, height: 35,)
                                      : Image.network(
                                    baseItemList[baseItemList.indexWhere(
                                            (item) =>
                                        item.name ==
                                            canFinalItemList[index].child[1])]
                                        .url, width: 35, height: 35,)
                                ],
                              ),
                              trailing: SizedBox(height: 30.0,
                                  width: 80,
                                  child: Text(canFinalItemList[index].name,
                                    style: TextStyle(
                                        fontSize: 13
                                    ),)),
                            ),
                            const Divider(
                              height: 23,
                              thickness: 2,
                              indent: 10,
                              endIndent: 10,
                            ),
                    ]);}

                    return Column(
                        children: [
                          const SizedBox(height: 8.0),
                          ListTile(
                            leading: canFinalItemList[index].url.isEmpty
                                ? CircularProgressIndicator()
                                : FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      FinalItemDetailPage(
                                        item: canFinalItemList[index],
                                        baseItemList: baseItemList,
                                        finalItemList: finalItemList,
                                        championList: championList,
                                      )),);
                              }, child: Image.network(
                              canFinalItemList[index].url, width: 60,
                              height: 60,),),

                            title: Wrap(
                              spacing: 7, // space between two icons
                              children: <Widget>[
                                const Icon(Icons.forward),
                                Image.network(
                                  baseItemList[baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[0])
                                  ].url, width: 35, height: 35,),
                                const Icon(Icons.add),
                                canFinalItemList[index].child.length == 1
                                    ? Image.network(
                                  baseItemList[baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[0])]
                                      .url, width: 35, height: 35,)
                                    : Image.network(
                                  baseItemList[baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[1])]
                                      .url, width: 35, height: 35,)
                              ],
                            ),
                            trailing: SizedBox(height: 30.0,
                                width: 80,
                                child: Text(canFinalItemList[index].name,
                                  style: TextStyle(
                                      fontSize: 13
                                  ),)),
                          ),
                          const Divider(
                            height: 23,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ]
                    );
                  }
              );
            }
            if (tab == '추천 조합' && combinationList.isNotEmpty) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: combinationList.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                          children: [
                            const ListTile(
                              trailing: SizedBox(height: 30.0,
                                width: 25,
                                child: Text("남은 유닛", style: TextStyle(
                                    fontSize: 14
                                ),),
                              ),
                              title: SizedBox(height: 30.0,
                                  width: 100,
                                  child: Text("챔피언", style: TextStyle(
                                      fontSize: 13
                                  ),)),
                              leading: SizedBox(height: 30.0,
                                  width: 100,
                                  child: Text("이름")),
                            ),
                            const SizedBox(height: 8.0),
                            ListTile(
                              leading: SizedBox(height: 30.0,
                                  width: 100,
                                  child: Text(combinationList[index].name)),
                              title: Wrap(
                                spacing: 10, // space between two icons
                                children: <Widget>[
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[0])
                                  ].url == "" ? Text(
                                      combinationList[index].child[0]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[0])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[0])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[0])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[1])
                                  ].url == "" ? Text(
                                      combinationList[index].child[1]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[1])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[1])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[1])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[2])
                                  ].url == "" ? Text(
                                      combinationList[index].child[2]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[2])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[2])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[2])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[3])
                                  ].url == "" ? Text(
                                      combinationList[index].child[3]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[3])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[3])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[3])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[4])
                                  ].url == "" ? Text(
                                      combinationList[index].child[4]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[4])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[4])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[4])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[5])
                                  ].url == "" ? Text(
                                      combinationList[index].child[5]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[5])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[5])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[5])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[6])
                                  ].url == "" ? Text(
                                      combinationList[index].child[6]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[6])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[6])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[6])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[7])
                                  ].url == "" ? Text(
                                      combinationList[index].child[7]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[7])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[7])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[7])
                                      ].url, width: 40, height: 40)),
                                ],
                              ),
                              trailing: SizedBox(height: 30.0,
                                width: 15,
                                child: Text(combinationList[index].restCount
                                    .toString()),
                              ),
                            ),
                            const Divider(
                              height: 23,
                              thickness: 2,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ]
                      );
                    }
                    else {
                      return Column(
                          children: [
                            const SizedBox(height: 8.0),
                            ListTile(
                              leading: SizedBox(height: 30.0,
                                  width: 100,
                                  child: Text(combinationList[index].name)),
                              title: Wrap(
                                spacing: 10, // space between two icons
                                children: <Widget>[
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[0])
                                  ].url == "" ? Text(
                                      combinationList[index].child[0]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[0])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[0])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[0])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[1])
                                  ].url == "" ? Text(
                                      combinationList[index].child[1]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[1])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[1])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[1])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[2])
                                  ].url == "" ? Text(
                                      combinationList[index].child[2]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[2])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[2])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[2])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[3])
                                  ].url == "" ? Text(
                                      combinationList[index].child[3]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[3])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[3])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[3])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[4])
                                  ].url == "" ? Text(
                                      combinationList[index].child[4]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[4])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[4])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[4])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[5])
                                  ].url == "" ? Text(
                                      combinationList[index].child[5]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[5])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[5])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[5])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[6])
                                  ].url == "" ? Text(
                                      combinationList[index].child[6]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[6])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[6])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[6])
                                      ].url, width: 40, height: 40)),
                                  championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[7])
                                  ].url == "" ? Text(
                                      combinationList[index].child[7]) :

                                  ( championList[championList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          combinationList[index].child[7])
                                  ].count==0 ?   Container(
                                    foregroundDecoration: BoxDecoration(
                                      color: Colors.grey,
                                      backgroundBlendMode: BlendMode.saturation,
                                    ),
                                    child: Image
                                        .network(
                                        championList[championList.indexWhere(
                                                (item) =>
                                            item.name ==
                                                combinationList[index].child[7])
                                        ].url, width: 40, height: 40),
                                  ) : Image
                                      .network(
                                      championList[championList.indexWhere(
                                              (item) =>
                                          item.name ==
                                              combinationList[index].child[7])
                                      ].url, width: 40, height: 40)),
                                ],
                              ),
                              trailing: SizedBox(height: 30.0,
                                width: 15,
                                child: Text(combinationList[index].restCount
                                    .toString()),
                              ),
                            ),
                            const Divider(
                              height: 23,
                              thickness: 2,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ]
                      );
                    }
                  }
              );
            }
            else {
              return Text(tab);
            }
          }).toList(),
        ),

        drawer: Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,),
                    child: Text('Pages',
                      style: TextStyle(color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 5.5,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                    leading: const Icon(Icons.home, color: Colors.deepPurple,),
                    title: const Text('Home',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                    leading: const Icon(Icons.ondemand_video_rounded, color: Colors.deepPurple,),
                    title: const Text('Video Data',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VedioPage()),);
                    },
                  ),
                ]
            )
        ),
      ),
    );
  }

  Future<String> itemUrl(String name, List<BaseItem> baseItemList) async {
    print("item name in url");
    print(name);
    String downloadURL = await firebase_storage.FirebaseStorage.instance.
    ref('baseItem/' + name + '.png').
    getDownloadURL();

    for (var item in baseItemList) {
      if (item.name == name) {
        item.url = downloadURL;
      }
    }

    return downloadURL;
  }

  Future<String> skillUrl(String name, List<Champion> championList) async {
    print("skill name in url");
    print(name);
    String downloadURL = await firebase_storage.FirebaseStorage.instance.
    ref('skill/' + name + '.png').
    getDownloadURL();

    for (var item in championList) {
      if (item.skillName == name) {
        item.skillUrl = downloadURL;
      }
    }
    return downloadURL;
  }

  Future<String> championUrl(String name, List<Champion> championList) async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('champion/' + name + '.png')
        .getDownloadURL();
    // Within your widgets:

    for (var item in championList) {
      if (item.name == name) {
        item.url = downloadURL;
      }
    }
    return downloadURL;
  }

  Future<String> classUrl(String name, List<Class> classList) async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('class/' + name + '.png')
        .getDownloadURL();
    // Within your widgets:

    for (var item in classList) {
      if (item.name == name) {
        item.url = downloadURL;
      }
    }
    return downloadURL;
  }

  Future<void> loadClass(List<Class> classList) async {
    classList.clear();
    await for (var snapshot in FirebaseFirestore.instance.collection("class")
        .snapshots()) {
      for (var item in snapshot.docs) {
        print("name");
        print(item.get("name"));

        classList.add(Class(url: '', name: item.get("name")));

        classUrl(item.get("name"), classList);

        print("next");
      }
      print("finish class load");
    }
    setState(() {
      classList;
    });
  }

  Future<String> finalItemUrl(String name,
      List<FinalItem> finalItemList) async {
    print("fianl name: " + name);
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('finalWeapon/' + name + '.png')
        .getDownloadURL();
    // Within your widgets:

    for (var item in finalItemList) {
      if (item.name == name) {
        item.url = downloadURL;
      }
    }
    return downloadURL;
  }

  Future<void> loadItem(List<BaseItem> baseItemList) async {
    baseItemList.clear();
    await for (var snapshot in FirebaseFirestore.instance.collection("baseitem")
        .snapshots()) {
      print(snapshot.docs[0]['name']);
      print(snapshot.docs[1]['name']);
      for (var item in snapshot.docs) {
        print("name");
        print(item.get("name"));
        print(item.get("description"));
        baseItemList.add(BaseItem(name: item.get("name"),
            description: item.get("description"),
            count: 0, url: ''));

        itemUrl(item.get("name"), baseItemList);
        print("next");
      }
      print("finish load");
    }
    setState(() {
      baseItemList;
    });
  }

  Future<void> loadChampion(List<Champion> championList) async {
    championList.clear();

    await for (var snapshot in FirebaseFirestore.instance.collection(
        "champion6").snapshots()) {
      print(snapshot.docs[0]['name']);
      print(snapshot.docs[1]['name']);
      for (var champion in snapshot.docs) {
        List<String> item = [];
        List<String> attribute = [];
        print("name");
        print(champion.get("name"));

        item.add(champion.get("item1"));
        item.add(champion.get("item2"));
        item.add(champion.get("item3"));

        attribute.add(champion.get("attribute1"));
        if (champion.get("attribute2") != null) {
          attribute.add(champion.get("attribute2"));
        }
        if (champion.get("attribute3") != null) {
          attribute.add(champion.get("attribute3"));
        }

        if (champion.get("name") == "none") {
          championList.add(Champion(name: "none",
            count: 0,
            cost: 0,
            skillType: '',
            attribute: [],
            skillName: '',
            description: '',
            url: '',
            mana: '',
            range: 0,
            item: [],
            skillUrl: '',
          ));
        }
        else {
          championList.add(Champion(name: champion.get("name"),
              count: 0,
              cost: champion.get("cost"),
              description: champion.get("description"),
              url: '',
              item: item,
              skillType: champion.get("skillType"),
              range: champion.get("range"),
              mana: champion.get("mana"),
              skillName: champion.get("skillName"),
              attribute: attribute,
              skillUrl: ''));

          skillUrl(champion.get("skillName"), championList);
        }

        championUrl(champion.get("name"), championList);


        print("next");
      }
      print("finish load");

      setState(() {
        print("set champion");
        loadChampionFinish = true;
        championList.sort((a, b) =>
            a.cost.compareTo(b.cost));

        championList;
      });
    }
  }

  Future<void> loadFinalItemList(List<FinalItem> finalItemList) async {
    FinalItem _finalitem = FinalItem(name: "",
        child: [],
        description: "",
        childCount: [],
        exist: 0,
        childMaxCount: [],
        url: '');

    finalItemList.clear();

    await for (var snapshot in FirebaseFirestore.instance.collection(
        "finalItem").snapshots()) {
      for (var item in snapshot.docs) {
        print("name");
        print(item.get("name"));
        _finalitem.name = item.get("name");
        _finalitem.description = item.get("description");
        loadFinalItemChild(_finalitem);
        finalItemUrl(_finalitem.name, finalItemList);
        finalItemList.add(_finalitem);
        _finalitem = FinalItem(name: "",
            child: [],
            description: "",
            childCount: [],
            exist: 0,
            childMaxCount: [],
            url: '');
      }
      print("finish final load");

      setState(() {
        finalItemList;
      });
    }
  }

  Future<void> loadFinalItemChild(FinalItem finalItem) async {
    print("start loadFinalItemChild of " + finalItem.name);

    await for (var snapshot in FirebaseFirestore.instance.collection(
        "finalItem").doc(finalItem.name).collection("child").snapshots()) {
      for (var item in snapshot.docs) {
        print("sub name");
        print(item.get("name"));
        print("count");
        print(item.get("count"));
        finalItem.child.add(item.get("name"));
        finalItem.childCount.add(0);
        finalItem.childMaxCount.add(item.get("count"));
      }
      print("finish final load");
    }
  }

  Future<void> loadCombination(List <Combination> combinationList) async {
    Combination _combination = Combination(
        name: '', child: [], restCount: 8, complete: 0);
    print("start loadCombination");
    combinationList.clear();

    await for (var snapshot in FirebaseFirestore.instance.collection(
        "combination6").snapshots()) {
      for (var item in snapshot.docs) {
        print("combination debug");
        _combination.name = item.get("name");
        _combination.child.add(item.get("child1"));
        _combination.child.add(item.get("child2"));
        _combination.child.add(item.get("child3"));
        _combination.child.add(item.get("child4"));
        _combination.child.add(item.get("child5"));
        _combination.child.add(item.get("child6"));
        _combination.child.add(item.get("child7"));
        _combination.child.add(item.get("child8"));

        for (int i = 0; i < 8; i++) {
          if (_combination.child[i] == 'none') {
            _combination.restCount--;
          }
        }

        combinationList.add(_combination);
        _combination =
            Combination(name: '', child: [], restCount: 8, complete: 0);
      }
      print("finish final load");

      setState(() {
        combinationList;
      });
    }
  }
}





