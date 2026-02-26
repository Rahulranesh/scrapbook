import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/scrapbook_item.dart';
import '../services/storage_service.dart';
import '../widgets/vintage_loading.dart';
import '../theme/theme_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final StorageService _storageService = StorageService();
  List<ScrapbookItem> _allPhotos = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, photos, notes, stickers

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    setState(() => _isLoading = true);
    final boards = await _storageService.loadBoards();
    final allItems = <ScrapbookItem>[];
    
    for (final board in boards) {
      allItems.addAll(board.items);
    }

    setState(() {
      _allPhotos = allItems;
      _isLoading = false;
    });
  }

  List<ScrapbookItem> get _filteredItems {
    if (_filterType == 'all') return _allPhotos;
    return _allPhotos.where((item) => item.type == _filterType.substring(0, _filterType.length - 1)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: VintageLoading(message: 'Loading Gallery...'),
      );
    }

    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gallery',
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
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: themeProvider.surfaceColor),
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Items'),
              ),
              const PopupMenuItem(
                value: 'photos',
                child: Text('Photos Only'),
              ),
              const PopupMenuItem(
                value: 'notes',
                child: Text('Notes Only'),
              ),
              const PopupMenuItem(
                value: 'stickers',
                child: Text('Stickers Only'),
              ),
            ],
          ),
        ],
      ),
      body: filteredItems.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return _buildGalleryItem(filteredItems[index]);
              },
            ),
    );
  }

  Widget _buildGalleryItem(ScrapbookItem item) {
    return GestureDetector(
      onTap: () => _showItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildItemPreview(item),
        ),
      ),
    );
  }

  Widget _buildItemPreview(ScrapbookItem item) {
    switch (item.type) {
      case 'photo':
        if (item.content.isNotEmpty && File(item.content).existsSync()) {
          return Image.file(
            File(item.content),
            fit: BoxFit.cover,
          );
        }
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.photo, size: 40, color: Colors.grey),
          ),
        );
      case 'note':
        return Container(
          color: const Color(0xFFFFF59D),
          padding: const EdgeInsets.all(8),
          child: Text(
            item.content,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        );
      case 'sticker':
        return Container(
          color: const Color(0xFFF5F5DC),
          child: Center(
            child: Icon(
              _getStickerIcon(item.content),
              size: 40,
              color: const Color(0xFF8B4513),
            ),
          ),
        );
      default:
        return Container(color: Colors.grey[300]);
    }
  }

  IconData _getStickerIcon(String content) {
    switch (content) {
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      case 'smile':
        return Icons.sentiment_very_satisfied;
      case 'music':
        return Icons.music_note;
      case 'sun':
        return Icons.wb_sunny;
      default:
        return Icons.circle;
    }
  }

  void _showItemDetail(ScrapbookItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B4513),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B4513),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getItemIcon(item.type),
                      color: const Color(0xFFF5F5DC),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.type[0].toUpperCase()}${item.type.substring(1)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5DC),
                        fontFamily: 'serif',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFF5F5DC)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildDetailContent(item),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Added: ${_formatDate(item.dateAdded)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF8B4513).withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(ScrapbookItem item) {
    switch (item.type) {
      case 'photo':
        if (item.content.isNotEmpty && File(item.content).existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(item.content),
              fit: BoxFit.contain,
            ),
          );
        }
        return const Center(child: Text('Photo not found'));
      case 'note':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF59D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Text(
              item.content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        );
      case 'sticker':
        return Center(
          child: Icon(
            _getStickerIcon(item.content),
            size: 120,
            color: const Color(0xFF8B4513),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'photo':
        return Icons.photo;
      case 'note':
        return Icons.note;
      case 'sticker':
        return Icons.star;
      default:
        return Icons.image;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: const Color(0xFF8B4513).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Items Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos, notes, or stickers\nto your scrapbooks',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF8B4513).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
