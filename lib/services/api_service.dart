import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl =
      'https://dummyjson.com/recipes';

  static Future<List<Recipe>> getRecipes() async {
    final response = await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List recipes = data['recipes'];

      return recipes.map((item) {
        return Recipe.fromJson(item);
      }).toList();
    } else {
      throw Exception('Gagal mengambil data resep');
    }
  }

  static Future<Recipe> getRecipeDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Recipe.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail resep');
    }
  }
}
