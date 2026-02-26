import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scrapbook_board.dart';
import '../models/scrapbook_item.dart';
import '../services/storage_service.dart';
import '../theme/theme_provider.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final StorageService _storageService = StorageService();
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'birthday',
      'name': 'Birthday Party',
      'category': 'celebrations',
      'description': 'Perfect for birthday memories',
      'theme': 'album',
      'icon': Icons.cake,
      'color': Color(0xFFFFB6C1),
      'items': [
        {'type': 'note', 'content': 'Happy Birthday!', 'x': 50.0, 'y': 100.0},
        {'type': 'sticker', 'content': 'star', 'x': 200.0, 'y': 150.0},
      ],
    },
    {
      'id': 'vacation',
      'name': 'Vacation Vibes',
      'category': 'travel',
      'description': 'Capture your travel adventures',
      'theme': 'cork',
      'icon': Icons.beach_access,
      'color': Color(0xFF87CEEB),
      'items': [
        {'type': 'note', 'content': 'Summer Vacation', 'x': 100.0, 'y': 120.0},
        {'type': 'sticker', 'content': 'sun', 'x': 250.0, 'y': 180.0},
      ],
    },
    {
      'id': 'wedding',
      'name': 'Wedding Day',
      'category': 'celebrations',
      'description': 'Cherish your special day',
      'theme': 'album',
      'icon': Icons.favorite,
      'color': Color(0xFFFFE4E1),
      'items': [
        {'type': 'note', 'content': 'Our Wedding Day', 'x': 80.0, 'y': 100.0},
        {'type': 'sticker', 'content': 'heart', 'x': 220.0, 'y': 160.0},
      ],
    },
    {
      'id': 'graduation',
      'name': 'Graduation',
      'category': 'milestones',
      'description': 'Celebrate achievements',
      'theme': 'felt',
      'icon': Icons.school,
      'color': Color(0xFF4169E1),
      'items': [
        {'type': 'note', 'content': 'Graduation 2024', 'x': 90.0, 'y': 110.0},
        {'type': 'sticker', 'content': 'graduation', 'x': 230.0, 'y': 170.0},
      ],
    },
    {
      'id': 'baby',
      'name': 'Baby Memories',
      'category': 'family',
      'description': 'First moments with baby',
      'theme': 'album',
      'icon': Icons.child_care,
      'color': Color(0xFFFFDAB9),
      'items': [
        {'type': 'note', 'content': 'Welcome Baby!', 'x': 70.0, 'y': 90.0},
        {'type': 'sticker', 'content': 'smile', 'x': 210.0, 'y': 140.0},
      ],
    },
    {
      'id': 'pets',
      'name': 'Pet Adventures',
      'category': 'family',
      'description': 'Furry friend memories',
      'theme': 'cork',
      'icon': Icons.pets,
      'color': Color(0xFFDDA0DD),
      'items': [
        {'type': 'note', 'content': 'My Best Friend', 'x': 85.0, 'y': 105.0},
        {'type': 'sticker', 'content': 'heart', 'x': 225.0, 'y': 155.0},
      ],
    },
    {
      'id': 'concert',
      'name': 'Concert Night',
      'category': 'events',
      'description': 'Music and memories',
      'theme': 'felt',
      'icon': Icons.music_note,
      'color': Color(0xFF9370DB),
      'items': [
        {'type': 'note', 'content': 'Best Concert Ever!', 'x': 75.0, 'y': 95.0},
        {'type': 'sticker', 'content': 'music', 'x': 215.0, 'y': 145.0},
      ],
    },
    {
      'id': 'sports',
      'name': 'Sports Victory',
      'category': 'events',
      'description': 'Championship moments',
      'theme': 'cork',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF32CD32),
      'items': [
        {'type': 'note', 'content': 'Champions!', 'x': 95.0, 'y': 115.0},
        {'type': 'sticker', 'content': 'trophy', 'x': 235.0, 'y': 165.0},
      ],
    },
    {
      'id': 'holiday',
      'name': 'Holiday Season',
      'category': 'celebrations',
      'description': 'Festive memories',
      'theme': 'album',
      'icon': Icons.celebration,
      'color': Color(0xFFDC143C),
      'items': [
        {'type': 'note', 'content': 'Happy Holidays!', 'x': 80.0, 'y': 100.0},
        {'type': 'sticker', 'content': 'star', 'x': 220.0, 'y': 150.0},
      ],
    },
    {
      'id': 'friendship',
      'name': 'Best Friends',
      'category': 'social',
      'description': 'Friendship moments',
      'theme': 'felt',
      'icon': Icons.group,
      'color': Color(0xFFFFD700),
      'items': [
        {'type': 'note', 'content': 'Friends Forever', 'x': 85.0, 'y': 105.0},
        {'type': 'sticker', 'content': 'smile', 'x': 225.0, 'y': 155.0},
      ],
    },
    {
      'id': 'road_trip',
      'name': 'Road Trip',
      'category': 'travel',
      'description': 'Journey memories',
      'theme': 'cork',
      'icon': Icons.directions_car,
      'color': Color(0xFFFF8C00),
      'items': [
        {'type': 'note', 'content': 'Road Trip 2024', 'x': 90.0, 'y': 110.0},
        {'type': 'sticker', 'content': 'lightning', 'x': 230.0, 'y': 160.0},
      ],
    },
    {
      'id': 'anniversary',
      'name': 'Anniversary',
      'category': 'celebrations',
      'description': 'Love and memories',
      'theme': 'album',
      'icon': Icons.favorite_border,
      'color': Color(0xFFFF69B4),
      'items': [
        {'type': 'note', 'content': 'Happy Anniversary', 'x': 75.0, 'y': 95.0},
        {'type': 'sticker', 'content': 'heart', 'x': 215.0, 'y': 145.0},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredTemplates {
    if (_selectedCategory == 'all') return _templates;
    return _templates.where((t) => t['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Templates',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeProvider.surfaceColor,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: themeProvider.primaryColor,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.surfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _filteredTemplates.length,
              itemBuilder: (context, index) {
                return _buildTemplateCard(_filteredTemplates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': 'all', 'name': 'All', 'icon': Icons.grid_view},
      {'id': 'celebrations', 'name': 'Celebrations', 'icon': Icons.celebration},
      {'id': 'travel', 'name': 'Travel', 'icon': Icons.flight},
      {'id': 'family', 'name': 'Family', 'icon': Icons.family_restroom},
      {'id': 'events', 'name': 'Events', 'icon': Icons.event},
      {'id': 'social', 'name': 'Social', 'icon': Icons.people},
      {'id': 'milestones', 'name': 'Milestones', 'icon': Icons.star},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category['id'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B4513)
                      : const Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8B4513),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? const Color(0xFFF5F5DC)
                          : const Color(0xFF8B4513),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFFF5F5DC)
                            : const Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return GestureDetector(
      onTap: () => _useTemplate(template),
      child: Container(
        decoration: BoxDecoration(
          color: template['color'] as Color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B4513),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                template['icon'] as IconData,
                size: 40,
                color: const Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                template['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                template['description'] as String,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useTemplate(Map<String, dynamic> template) async {
    final titleController = TextEditingController(text: template['name'] as String);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF5F5DC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF8B4513), width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create from Template',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Scrapbook Name',
                  labelStyle: const TextStyle(color: Color(0xFF8B4513)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8B4513)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF8B4513),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF8B4513)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: const Color(0xFFF5F5DC),
                    ),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final items = (template['items'] as List).map((item) {
        return ScrapbookItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + item['type'],
          type: item['type'],
          content: item['content'],
          xPosition: item['x'],
          yPosition: item['y'],
          rotation: 0,
          width: item['type'] == 'sticker' ? 80 : 200,
          height: item['type'] == 'sticker' ? 80 : 200,
          dateAdded: DateTime.now(),
        );
      }).toList();

      final newBoard = ScrapbookBoard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        theme: template['theme'] as String,
        items: items,
        createdDate: DateTime.now(),
      );

      final boards = await _storageService.loadBoards();
      boards.add(newBoard);
      await _storageService.saveBoards(boards);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created "${titleController.text}" from template'),
            backgroundColor: const Color(0xFF8B4513),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}
