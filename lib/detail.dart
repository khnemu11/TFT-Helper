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
import 'package:shrine/model/finalItem.dart';
import 'model/champion.dart';
import 'model/class.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.champion, required this.item, required this.classList}) : super(key: key);

  final Champion champion;
  final List<FinalItem> item;
  final List<Class> classList;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  @override
  Widget build(BuildContext context) {
    List<FinalItem> recommandItem=[];
    List<Class> champClass=[];
    int length = 1;
    for(var item in widget.champion.item){
      for(var finalItem in widget.item){
        if(item == finalItem.name){
          recommandItem.add(finalItem);
        }
      }
    }
    for(var item in widget.champion.attribute){
      for(var cClass in widget.classList){
        if(item == cClass.name){
          champClass.add(cClass);
        }
      }
    }
      print("length in detil : "+widget.champion.attribute.length.toString());
      return MaterialApp(
      title: 'Champion Detail',
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
          title: const Text('Champion Detail'),
        ),
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                    leading: Hero(
                      tag: widget.champion.name,
                      child: widget.champion.url == "" ? Text(widget.champion.name+".img"): Image.network(widget.champion.url),
                    ),
                    title: Text(widget.champion.name),
                    subtitle: Text("cost : " + widget.champion.cost.toString() + " / range : " + widget.champion.range.toString())),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.champion.attribute.length,
                    itemExtent: 45,
                    itemBuilder: (context2, k) {
                      return  ListTile(
                        leading: champClass[k].url == "" ? Text(widget.champion.attribute[k]+".img"): Image.network(champClass[k].url),
                        title: Text(widget.champion.attribute[k]),
                      );
                    }),
                const SizedBox(
                  height: 30,
                ),
                ListTile(
                    leading: widget.champion.skillUrl=="" ? Text(widget.champion.skillName+".img") : Image.network(widget.champion.skillUrl),
                    title: Text(widget.champion.skillName),
                    subtitle: Text(widget.champion.skillType+" / mana : "+widget.champion.mana)),
                ListTile(
                  title: Text(widget.champion.description),
                ),
                const ListTile(
                  title: Text("Recommand Item",style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    recommandItem[0].url == "" ? Text(widget.champion.item[0]+".img"):Image.network(recommandItem[0].url),
                    recommandItem[1].url == "" ? Text(widget.champion.item[1]+".img"):Image.network(recommandItem[1].url),
                    recommandItem[2].url == "" ? Text(widget.champion.item[2]+".img"):Image.network(recommandItem[2].url),
                  ],
                ),
                 const SizedBox(
                  height: 30,
                ),
              ],
            );
          },
        )
      ),
    );
  }
}
