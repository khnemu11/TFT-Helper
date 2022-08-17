import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'model/leage.dart';
import 'model/summoner.dart';
import 'package:fl_chart/fl_chart.dart';

enum ApplicationType {
  profileSearch,
  profileView,
}

class Application extends StatelessWidget {
   Application({
    required this.applicationState,
    required this.profileSearch,
    required this.profileView,
     required this.nickname
  });

  final ApplicationType applicationState;
  final String nickname;
  final void Function() profileSearch;
  final void Function(String nickname) profileView;
  final placementList = [];

  @override
  Widget build(BuildContext context) {
    final _searchController = TextEditingController();


    switch (applicationState) {
      case ApplicationType.profileSearch:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
           ClipOval(
                  child : Lottie.network(
                    'https://assets5.lottiefiles.com/packages/lf20_h59xofz0.json', width: 250,
                    height: 250,
                    fit: BoxFit.cover,),

                ),
            Container(
              child: Text("TFT HELPER",style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
              ),),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  width: 370,
                  child:  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '소환사 이름을 입력하세요'
                    ),
                  ),
                ),
                Container(
                  width: 370,
                  child:  InkWell(
                    child:Container(
                      alignment: Alignment.bottomRight,
                      child:  Icon(Icons.search,size: 40,),
                    ),
                    onTap: ()  {
                      print(_searchController.value.text);
                      profileView(_searchController.value.text);
                    },
                  ),
                ),
              ],
            )
          ]
        );
      case ApplicationType.profileView:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Center(
                child: FutureBuilder<Summoner>(
                  future: fetchSummoner(nickname),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                          children:[
                            SizedBox(
                              height: 30,
                            ),
                            FutureBuilder<League>(
                                future: fetchLeague(snapshot.data!.id),
                                builder: (context, snapshot2) {
                                  if (snapshot2.hasData) {
                                    return Column(
                                        children:[
                                          Container(
                                            child: Text("TFT HELPER",style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          ClipOval(
                                            child : Image.asset(
                                              'img/tier/'+snapshot2.data!.tier+'.png', width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,),

                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(snapshot.data!.name),
                                          Text("Lv. "+snapshot.data!.summonerLevel.toString()),
                                          Text(snapshot2.data!.tier + "  "+ snapshot2.data!.rank),
                                          Text("LP :  "+ snapshot2.data!.leaguePoints.toString()),
                                          Container(
                                            child: InkWell(
                                              child:Container(
                                                  alignment: Alignment.bottomRight,
                                                  child:  Icon(Icons.exit_to_app_rounded)
                                              ),
                                              onTap: ()  {
                                                profileSearch();
                                              },
                                            ),
                                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                          ),
                                        /*  FutureBuilder<void>(
                                              future: fetchMatch(snapshot.data!.puuid),
                                              builder: (context, snapshot3) {
                                                return Text("asd");
                                              }
                                              ),*/
                                          AspectRatio(
                                              aspectRatio: 1.5,
                                          child:PieChart(
                                            PieChartData(
                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                sectionsSpace: 0,
                                                centerSpaceRadius: 50,
                                                sections: showingSections(snapshot2.data!.wins,snapshot2.data!.losses)),
                                          ),
                                  ),

                                          Container(
                                              padding:EdgeInsets.fromLTRB(200, 0, 0, 0),
                                             child:Text("Win / Lose    :    " + snapshot2.data!.wins.toString() + " / " + snapshot2.data!.losses.toString()),

                                            ),
                                          Container(
                                              padding:EdgeInsets.fromLTRB(200, 10, 0, 0),
                                            child: Text("Total             :         "+ (snapshot2.data!.wins + snapshot2.data!.losses).toString())
                                          )
                                        ]
                                    );
                                  } else if (snapshot2.hasError) {
                                    return Column(
                                      children: [
                                      Text('${snapshot2.error}'),
                                        InkWell(
                                          child:Container(
                                              alignment: Alignment.bottomRight,
                                              child:  Icon(Icons.exit_to_app_rounded)
                                          ),
                                          onTap: ()  {
                                            profileSearch();
                                          },
                                        ),
                                      ],
                                    ) ;
                                  }
                                  return const CircularProgressIndicator();
                                },
                            ),
                  ]
              );
            } else if (snapshot.hasError) {

              return Column(
                children: [
              Text('${snapshot.error}'),
                  InkWell(
                    child:Container(
                        alignment: Alignment.bottomRight,
                        child:  Icon(Icons.exit_to_app_rounded)
                    ),
                    onTap: ()  {
                      profileSearch();
                    },
                  ),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        ),
       ),

            ]
        );
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }
   Future<Summoner> fetchSummoner(String nickname) async {
     final api_key="?api_key=RGAPI-9ec4d07e-d627-4e87-8095-d928e0bcd611";
     final api = "https://kr.api.riotgames.com/tft/summoner/v1/summoners/by-name/";

     final url=api+nickname+api_key;
     final response = await http.get(Uri.parse(url));

     if (response.statusCode == 200) {
       return Summoner.fromJson(jsonDecode(response.body));
     } else {
       throw Exception('Summoner Failed');
     }
   }

   Future<League> fetchLeague(String id) async {
     final api_key="?api_key=RGAPI-9ec4d07e-d627-4e87-8095-d928e0bcd611";
     final api = "https://kr.api.riotgames.com/tft/league/v1/entries/by-summoner/";
     final url=api+id+api_key;
     final response = await http.get(Uri.parse(url));

     if (response.statusCode == 200) {
       final List<dynamic> data = jsonDecode(response.body);

       return League.fromJson(data[0]);
     } else {
       throw Exception('League Fail');
     }
   }

   List<PieChartSectionData> showingSections(int wins, int losses) {
     return List.generate(2, (i) {
       final isTouched = i ;
       final fontSize = 16.0;
       final radius = 50.0;
       switch (i) {
         case 0:
           return PieChartSectionData(
             color: const Color(0xff0293ee),
             value: wins.toDouble(),
             title:  "Win\n"+((wins/(wins+losses))*100).toStringAsFixed(0)+"%",
             radius: radius,
             titleStyle: TextStyle(
                 fontSize: fontSize,
                 fontWeight: FontWeight.bold,
                 color: const Color(0xffffffff)),
           );
         case 1:
           return PieChartSectionData(
             color: Color(Colors.red.shade500.value),
             value: losses.toDouble(),
             title: "Loss\n"+((losses/(wins+losses))*100).toStringAsFixed(0)+"%",
             radius: radius,
             titleStyle: TextStyle(
                 fontSize: fontSize,
                 fontWeight: FontWeight.bold,
                 color: const Color(0xffffffff)),
           );
         default:
           throw Error();
       }
     });
   }
}
