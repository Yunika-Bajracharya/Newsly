import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:flutter/services.dart';
// import 'dart:convert';
import 'news_detailed.dart';
import 'dart:async' show Future;
import 'models/1.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 1;

  List<Widget> _widgetOptions = <Widget>[
    Text('Summary'),
    Text('Home'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Padding(
          padding: EdgeInsets.fromLTRB(0, 300, 0, 300),
          child: Text('Newsly',
              style: TextStyle(
                fontFamily: 'Kalam',
                fontSize: 35,
                color: Colors.white,
              )),
        )),
        // toolbarHeight: 90,
        // backgroundColor: Colors.grey[300],
        bottom: const TabBar(
            isScrollable: true,
            padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BubbleTabIndicator(
              indicatorHeight: 25.0,
              indicatorColor: Color.fromARGB(255, 255, 255, 255),
              tabBarIndicatorSize: TabBarIndicatorSize.tab,
              // Other flags
              // indicatorRadius: 1,
              // insets: EdgeInsets.all(1),
              // padding: EdgeInsets.all(10)
            ),
            tabs: [
              Tab(text: "All News"),
              Tab(text: "Popular"),
              Tab(text: "Politics"),
              Tab(text: "Tech"),
              Tab(text: "Sports"),
              Tab(text: "Entertainment"),
              Tab(text: "World"),
              Tab(text: "Business"),
              Tab(text: "Health"),
              Tab(text: "Literature"),
            ]),
      ),
      body: TabBarView(
        children: [
          ElevatedCard(category: 'all'),
          ElevatedCard(category: 'popular'),
          ElevatedCard(category: 'politics'),
          ElevatedCard(category: 'tech'),
          ElevatedCard(category: 'sports'),
          ElevatedCard(category: 'entertainment'),
          ElevatedCard(category: 'world'),
          ElevatedCard(category: 'business'),
          ElevatedCard(category: 'health'),
          ElevatedCard(category: 'literature'),
        ],
      ),
    );
  }
}

class NewsLoading {
  Future<List<News>> loadNews() async {
    var url = Uri.parse('https://newsly.asaurav.com.np/api/news/');
    var response = await http.get(url);
    // var jsonString = response.body;
    var jsonString = await rootBundle.loadString('assets/1.json');

    final jsonResponse = json.decode(jsonString);
    List<News> newsList = [];
    for (var news in jsonResponse) {
      News newsObj = News.fromJson(news);
      List<String> categoriesList = newsObj.categories.split(" ");
      newsObj.categoriesList = categoriesList;
      newsList.add(newsObj);
    }
    return newsList;
  }
}

class ElevatedCard extends StatefulWidget {
  String category = "all";
  ElevatedCard({super.key, required String category}) {
    this.category = category;
  }

  @override
  State<ElevatedCard> createState() => _ElevatedCardState();
}

class _ElevatedCardState extends State<ElevatedCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: NewsLoading().loadNews(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //initialize newslist
            List<News>? newsList = snapshot.data;
            List<News>? newsListFiltered = snapshot.data
                ?.where((itm) =>
                    itm.categoriesList.contains(widget.category) ||
                    widget.category == 'all')
                .toList();

            return Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: newsListFiltered!.length,
                    itemBuilder: (context, index) {
                      News news = newsListFiltered[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NewsDetailedView(news: news)));
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 5),
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  //return news.title
                                  title: Text(
                                    news.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(news.author),
                                ),
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: Image.network(news.imagePath,
                                                fit: BoxFit.cover),
                                          )),
                                      const SizedBox(height: 20),
                                      Text(
                                          '${news.description.characters.take(300)}...')
                                    ])),
                              ],
                            ),
                          ),
                        ),
                      );
                    }));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
