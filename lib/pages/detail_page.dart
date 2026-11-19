import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../utils/preferences.dart';

class DetailPage extends StatefulWidget {
  final int recipeId;

  const DetailPage({
    super.key,
    required this.recipeId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Recipe> recipeFuture;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    recipeFuture =
        ApiService.getRecipeDetail(widget.recipeId);

    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final result =
        await Preferences.isFavorite(widget.recipeId);

    if (mounted) {
      setState(() {
        isFavorite = result;
      });
    }
  }

  Future<void> toggleFavorite() async {
    await Preferences.toggleFavorite(widget.recipeId);

    await checkFavorite();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Resep ditambahkan ke Favorite'
              : 'Resep dihapus dari Favorite',
              style: const TextStyle(
                color: Colors.black
              ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Resep'),
        backgroundColor: const Color(0xFF00B956),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),

      body: FutureBuilder<Recipe>(
        future: recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Gagal memuat detail resep'),
            );
          }

          final recipe = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  recipe.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.restaurant,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(recipe.cuisine),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 5),
                          Text(recipe.rating.toString()),
                        ],
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Bahan-bahan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...recipe.ingredients.map(
                        (ingredient) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(ingredient),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Langkah Memasak',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...recipe.instructions.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 15,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.green,
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
