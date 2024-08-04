import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodfolio/loginpage.dart';
import 'package:foodfolio/detail.dart';
import 'package:foodfolio/addfood.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class FoodItem {
  final String name;
  final String? imageUrl;
  final int id;

  FoodItem({required this.name, this.imageUrl, required this.id});
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;
  List<String> imageUrls = [
    'assets/images/slideimg1.jpg',
    'assets/images/slideimg2.png',
  ];
  List<FoodItem> foodItems = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/api/foods/'));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> apiFoodItems =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        setState(() {
          foodItems = apiFoodItems.map((item) {
            String imageUrl = "assets/${item['image']}";
            /* print('Image URL: $imageUrl'); */
            return FoodItem(
              name: item['name'],
              imageUrl: imageUrl,
              id: item['food_id'],
            );
          }).toList();
        });
      } else {
        print("Failed to fetch food items from API");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

    List<FoodItem> _filterFoodItems(String query) {
    return foodItems.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Stack(
          children: <Widget>[
            Text(
              'FoodFolio',
              style: TextStyle(
                fontFamily: 'Madimi',
                fontSize: 40,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.5
                  ..color = Colors.black,
              ),
            ),
            const Text(
              'FoodFolio',
              style: TextStyle(
                fontFamily: 'Madimi',
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences sp = await SharedPreferences.getInstance();
              sp.setBool('isLogin', false);
              print("Successfully Log out");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.4,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          height: screenHeight * 0.4,
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search for food...',
                                  border: InputBorder.none,
                                ),
                                controller: _searchController, // Bind the controller
                                onChanged: (value) {
                                  setState(() {}); // Trigger a rebuild to update the filtered items
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 0.0,
                  mainAxisSpacing: 5,
                  mainAxisExtent: 264,
                ),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: _filterFoodItems(_searchController.text).length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FoodDetailPage(foodId: _filterFoodItems(_searchController.text)[index].id),
                        ),
                      );
                    },
                    child: Card(
                      child: Container(
                        height: 290,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    _filterFoodItems(_searchController.text)[index].imageUrl ??
                                        'assets/food_images/9.png',
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/food_images/9.png',
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  _filterFoodItems(_searchController.text)[index].name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFood(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
