// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:shrine/model/baseItem.dart';
import 'package:shrine/model/finalItem.dart';
import 'FinalItemdetail.dart';
import 'model/champion.dart';


import 'model/class.dart';

class BaseItemDetailPage extends StatefulWidget {
  const BaseItemDetailPage({Key? key, required this.finalItemList, required this.baseItemList, required this.item, required this.championList}) : super(key: key);

  final BaseItem item;
  final List<FinalItem> finalItemList;
  final List<BaseItem> baseItemList;
  final List<Champion> championList;

  @override
  State<BaseItemDetailPage> createState() => _BaseItemDetailPageState();
}

class _BaseItemDetailPageState extends State<BaseItemDetailPage> {

  @override
  Widget build(BuildContext context) {
      final List<FinalItem> canFinalItemList=[];

      for(int i=0;i<widget.finalItemList.length;i++){
        if(widget.finalItemList[i].child.contains(widget.item.name)){
          canFinalItemList.add(widget.finalItemList[i]);
        }
      }

      return MaterialApp(
      title: 'Base Item Detail',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text('Base Item Detail'),
        ),
        body: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 9,
                    itemBuilder: (BuildContext context, int index){
                    if(index==0){
                      return Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          ListTile(
                              leading: widget.item.url == "" ? Text(widget.item.name+".img"): Image.network(widget.item.url),
                              title: Text(widget.item.name)),
                          ListTile(
                            title: Text(widget.item.description),
                          ),
                          const ListTile(
                            title: Text("Combination Recipe",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          ),
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
                                        baseItemList: widget.baseItemList,
                                        finalItemList: widget.finalItemList,
                                        championList: widget.championList,
                                      )),);
                              }, child:   Image.network(
                              canFinalItemList[index].url, width: 60,
                              height: 60,),),
                            title: Wrap(
                              spacing: 7, // space between two icons
                              children: <Widget>[
                                const Icon(Icons.forward),
                                Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[0])
                                  ].url, width: 35, height: 35,),
                                const Icon(Icons.add),
                                canFinalItemList[index].child.length == 1
                                    ? Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[0])]
                                      .url, width: 35, height: 35,)
                                    : Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
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

                        ],
                      );
                    }
                    else{
                      return Column(
                        children: [
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
                                        baseItemList: widget.baseItemList,
                                        finalItemList: widget.finalItemList,
                                        championList: widget.championList,
                                      )),);
                              }, child:   Image.network(
                              canFinalItemList[index].url, width: 60,
                              height: 60,),),
                            title: Wrap(
                              spacing: 7, // space between two icons
                              children: <Widget>[
                                const Icon(Icons.forward),
                                Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[0])
                                  ].url, width: 35, height: 35,),
                                const Icon(Icons.add),
                                canFinalItemList[index].child.length == 1
                                    ? Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          canFinalItemList[index].child[0])]
                                      .url, width: 35, height: 35,)
                                    : Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
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
                        ],
                      );
                    }
                    },
            ),
        ),
    );
  }
}
