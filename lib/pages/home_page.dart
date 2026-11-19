import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../utils/preferences.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Recipe>> recipes;

  @override
  void initState() {
    super.initState();
    recipes = ApiService.getRecipes();
  }

  // LOGOUT
  Future<void> logout() async {
    await Preferences.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // MEMBUKA HALAMAN DETAIL
  void openDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          recipeId: recipe.id,
        ),
      ),
    );
  }

  // MEMBUKA HALAMAN FAVOURITE
  void openFavorite() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritePage(),
      ),
    );
  }

  // CARD RESEP
  Widget buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        openDetail(recipe);
      },
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                recipe.image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    width: double.infinity,
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    recipe.cuisine,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(recipe.rating.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resep Masakan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B956),
        foregroundColor: Colors.white,
        actions: [
          // TOMBOL FAVOURITE
          IconButton(
            onPressed: openFavorite,
            icon: const Icon(Icons.favorite),
          ),

          // TOMBOL LOGOUT
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: FutureBuilder<List<Recipe>>(
        future: recipes,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),

                  const SizedBox(height: 10),

                  const Text('Gagal memuat resep'),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        recipes = ApiService.getRecipes();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // DATA RESEP
          final recipeList = snapshot.data ?? [];

          if (recipeList.isEmpty) {
            return const Center(
              child: Text('Tidak ada resep tersedia'),
            );
          }

          // GRID VIEW
          return GridView.builder(
            padding: const EdgeInsets.all(10),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),

            itemCount: recipeList.length,

            itemBuilder: (context, index) {
              final recipe = recipeList[index];

              return buildRecipeCard(recipe);
            },
          );
        },
      ),
    );
  }
}