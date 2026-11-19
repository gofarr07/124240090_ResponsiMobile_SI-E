import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../utils/preferences.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Recipe>> favoriteFuture;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() {
    favoriteFuture = getFavoriteRecipes();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final ids = await Preferences.getFavorites();

    final recipes = await Future.wait(
      ids.map((id) => ApiService.getRecipeDetail(id)),
    );

    return recipes;
  }

  Future<void> refreshFavorites() async {
    setState(() {
      loadFavorites();
    });

    await favoriteFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        backgroundColor: const Color(0xFF00B956),
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<List<Recipe>>(
        future: favoriteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: refreshFavorites,
                child: const Text('Coba Lagi'),
              ),
            );
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Belum ada resep yang ditambhkan ke Favorite',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),

                  leading: Image.network(
                    recipe.image,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 50,
                      );
                    },
                  ),

                  title: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '${recipe.cuisine} ⭐ ${recipe.rating}',
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),

                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          recipeId: recipe.id,
                        ),
                      ),
                    );

                    refreshFavorites();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
