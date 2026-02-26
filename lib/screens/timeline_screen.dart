import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:scrapbook_memories/widgets/vintage_loading.dart';
import '../models/scrapbook_item.dart';
import '../services/storage_service.dart';
import '../theme/theme_provider.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _timelineItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    
    final boards = await _storageService.loadBoards();
    final items = <Map<String, dynamic>>[];
    
    for (final board in boards) {
      for (final item in board.items) {
        items.add({
          'item': item,
          'boardName': board.title,
          'boardTheme': board.theme,
        });
      }
    }
    
    // Sort by date (newest first)
    items.sort((a, b) => (b['item'] as ScrapbookItem)
        .dateAdded
        .compareTo((a['item'] as ScrapbookItem).dateAdded));
    
    setState(() {
      _timelineItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: VintageLoading(message: 'Loading Timeline...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timeline',
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
      body: _timelineItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _timelineItems.length,
              itemBuilder: (context, index) {
                return _buildTimelineItem(_timelineItems[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 80,
            color: themeProvider.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Memories Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimaryColor,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your scrapbooks\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> data, int index) {
    final item = data['item'] as ScrapbookItem;
    final boardName = data['boardName'] as String;
    final isLeft = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLeft) ...[
            Expanded(child: _buildItemCard(item, boardName)),
            const SizedBox(width: 16),
            _buildTimelineDot(item.dateAdded),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ] else ...[
            const Expanded(child: SizedBox()),
            const SizedBox(width: 16),
            _buildTimelineDot(item.dateAdded),
            const SizedBox(width: 16),
            Expanded(child: _buildItemCard(item, boardName)),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineDot(DateTime date) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: themeProvider.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: themeProvider.surfaceColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.surfaceColor,
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: 100,
          color: themeProvider.primaryColor.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildItemCard(ScrapbookItem item, String boardName) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getItemIcon(item.type),
                color: themeProvider.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  boardName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildItemPreview(item),
          const SizedBox(height: 8),
          Text(
            _formatDate(item.dateAdded),
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(ScrapbookItem item) {
    switch (item.type) {
      case 'photo':
        if (item.content.isNotEmpty && File(item.content).existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(item.content),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.photo, size: 40, color: Colors.grey),
          ),
        );
      case 'note':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF59D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        );
      case 'sticker':
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF8B4513).withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Icon(
              _getStickerIcon(item.content),
              size: 40,
              color: const Color(0xFF8B4513),
            ),
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
      case 'trophy':
        return Icons.emoji_events;
      case 'graduation':
        return Icons.school;
      default:
        return Icons.circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
