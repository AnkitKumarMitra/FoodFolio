import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:foodfolio/homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFood extends StatefulWidget {
  const AddFood({Key? key}) : super(key: key);

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _foodNameController = TextEditingController();
  TextEditingController _recipeController = TextEditingController();
  PlatformFile? _platformFile;

  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _platformFile = result.files.first;
      });
    }
  }

void submitForm() async {
  if (_formKey.currentState!.validate() && _platformFile != null) {
    String foodName = _foodNameController.text.trim();
    String recipe = _recipeController.text.trim();
    
    if (foodName.isNotEmpty && recipe.isNotEmpty) {
      List<int> fileBytes = _platformFile!.bytes!;
  
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:8000/api/add/'),
        );
        
        request.headers['Content-Type'] = 'multipart/form-data';
  
        request.fields['name'] = foodName;
        request.fields['recipe'] = recipe;
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            fileBytes,
            filename: _platformFile!.name,
          ),
        );
  
        var response = await request.send();
  
        if (response.statusCode == 201) {
          print("Upload successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          print("Failed to upload");
        }
      } catch (error) {
        print("Error: $error");
      }
    } else {
      print("Food name and recipe cannot be empty.");
    }
  } else {
    print("Please select a file and fill in all fields.");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add your own Recipe!"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  controller: _foodNameController,
                  decoration: InputDecoration(
                    labelText: "Enter Food Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter food name";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  controller: _recipeController,
                  decoration: InputDecoration(
                    labelText: "Enter Recipe",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter recipe";
                    }
                    return null;
                  },
                ),
              ),
              GestureDetector(
                onTap: selectFile,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, color: Colors.blue, size: 40),
                        SizedBox(height: 15),
                        Text(
                          'Select your file',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: submitForm,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
