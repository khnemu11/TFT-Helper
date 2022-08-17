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
import 'model/champion.dart';

class FinalItemDetailPage extends StatefulWidget {
  const FinalItemDetailPage({Key? key, required this.finalItemList, required this.baseItemList, required this.item, required this.championList}) : super(key: key);

  final FinalItem item;
  final List<FinalItem> finalItemList;
  final List<BaseItem> baseItemList;
  final List<Champion> championList;

  @override
  State<FinalItemDetailPage> createState() => _FinalItemDetailPageState();
}

class _FinalItemDetailPageState extends State<FinalItemDetailPage> {

  @override
  Widget build(BuildContext context) {
      final List<Champion> recomandChamp=[];

      for(int i=0;i<widget.championList.length;i++){
        if(widget.championList[i].item.contains(widget.item.name)){
          recomandChamp.add(widget.championList[i]);
          if(recomandChamp.length>4)  break;
        }
      }
      while(recomandChamp.length<5){
        recomandChamp.add(widget.championList[widget.championList.indexWhere(
                (champion) =>
            champion.name ==
                "none")]);
      }

      return MaterialApp(
      title: 'Final Item Detail',
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
          title: const Text('Final Item Detail'),
        ),
        body: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 1,
                    itemBuilder: (BuildContext context, int index){
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
                            leading: widget.item.url == ""
                                ? CircularProgressIndicator()
                                : Image.network(
                              widget.item.url, width: 60,
                              height: 60,),
                            title: Wrap(
                              spacing: 7, // space between two icons
                              children: <Widget>[
                                const Icon(Icons.forward),
                                Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          widget.item.child[0])
                                  ].url, width: 50, height: 50,),
                                const Icon(Icons.add),
                                widget.item.child.length == 1
                                    ? Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          widget.item.child[0])]
                                      .url, width: 50, height: 50,)
                                    : Image.network(
                                  widget.baseItemList[widget.baseItemList.indexWhere(
                                          (item) =>
                                      item.name ==
                                          widget.item.child[1])]
                                      .url, width: 50, height: 50,)
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const ListTile(
                            title: Text("Recommand Champion",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          Wrap(
                           spacing: 15,
                            children: [
                                Container(
                                  child: Image.network(recomandChamp[0].url,width: 60,height:60),
                                ),
                              Container(
                                child: Image.network(recomandChamp[1].url,width: 60,height:60),
                              ),
                              Container(
                                child: Image.network(recomandChamp[2].url,width: 60,height:60),
                              ),
                              Container(
                                child: Image.network(recomandChamp[3].url,width: 60,height:60),
                              ),
                              Container(
                                child: Image.network(recomandChamp[4].url,width: 60,height:60),
                              ),
                            ],
                          )
                        ],
                      );
                    },
            ),
        ),
    );
  }
}
