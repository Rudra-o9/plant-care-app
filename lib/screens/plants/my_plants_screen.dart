import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/plant_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../services/plant_service.dart';
import 'plant_details_screen.dart';
import 'plant_library_screen.dart';
import '../../utils/page_transitions.dart';

/// Screen listing user's personal plant collection with search, filtering, and responsive grid layout.
class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _plantService = PlantService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Plants'),
        actions: [
          IconButton(
            tooltip: 'Plant care library',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () =>
                Navigator.of(context)
                    .push(AppPageRoute.slideUp(const PlantLibraryScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _plantService.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search plants by name...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _plantService.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category Filter Chips
          ListenableBuilder(
            listenable: _plantService,
            builder: (context, _) {
              final categories = ['All', 'Favorites', 'Easy Care'];
              return SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = _plantService.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => _plantService.setCategory(cat),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Plant Grid
          Expanded(
            child: ListenableBuilder(
              listenable: _plantService,
              builder: (context, _) {
                final plantList = _plantService.plants;

                if (plantList.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Plants Found',
                    description: 'No plants matched your current search or category filter.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      _plantService.setSearchQuery('');
                      _plantService.setCategory('All');
                    },
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isLaptop = constraints.maxWidth >= 720;
                    final isTablet = constraints.maxWidth >= 480;
                    final columns = isLaptop ? 4 : (isTablet ? 3 : 2);
                    final aspectRatio = constraints.maxWidth < 360
                        ? 0.62
                        : constraints.maxWidth < 480
                        ? 0.64
                        : (isLaptop ? 0.75 : 0.70);

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: plantList.length,
                      itemBuilder: (context, index) {
                        final plant = plantList[index];
                        return PlantCard(
                          plant: plant,
                          onTap: () {
                            Navigator.of(context).push(
                              AppPageRoute.slideUp(
                                PlantDetailsScreen(plant: plant),
                              ),
                            );
                          },
                          onFavoriteToggle: () {
                            _plantService.toggleFavorite(plant.id);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
