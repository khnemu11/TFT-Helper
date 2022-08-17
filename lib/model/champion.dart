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


import 'package:cloud_firestore/cloud_firestore.dart';

class Champion {
   Champion({
     required this.name,
     required this.cost,
     required this.count,
     required this.description,
     required this.url,
     required this.item,
     required this.attribute,
     required this.mana,
     required this.range,
     required this.skillName,
     required this.skillType,
     required this.skillUrl
  });

   String name;
   int cost;
   int count;
   String description;
   String url;
   List<String> attribute;
   List <String> item;
   String mana;
   int range;
   String skillName;
   String skillType;
   String skillUrl;
}
