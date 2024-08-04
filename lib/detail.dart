import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodDetailPage extends StatefulWidget {
  final int foodId;

  const FoodDetailPage({Key? key, required this.foodId}) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class FoodDetail {
  final String name;
  final String imageUrl;
  final String recipe;

  FoodDetail(
      {required this.name, required this.imageUrl, required this.recipe});
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late Future<FoodDetail> _foodDetail;

  @override
  void initState() {
    super.initState();
    _foodDetail = fetchFoodDetail(widget.foodId);
  }

  Future<FoodDetail> fetchFoodDetail(int foodId) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/get/$foodId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String imageUrl = "assets/${data['image']}";
      return FoodDetail(
        name: data['name'],
        imageUrl: imageUrl,
        recipe: data['recipe'],
      );
    } else {
      throw Exception('Failed to load food detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Detail'),
      ),
      body: FutureBuilder<FoodDetail>(
        future: _foodDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      snapshot.data!.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      snapshot.data!.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Recipe:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      snapshot.data!.recipe,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
