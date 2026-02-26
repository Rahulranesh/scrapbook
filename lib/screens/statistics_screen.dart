import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/scrapbook_board.dart';
import '../widgets/vintage_loading.dart';
import '../theme/theme_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  int _totalBoards = 0;
  int _totalItems = 0;
  int _photoCount = 0;
  int _noteCount = 0;
  int _stickerCount = 0;
  String _mostUsedTheme = 'cork';
  String _oldestBoardName = '';
  String _newestBoardName = '';
  int _averageItemsPerBoard = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    final boards = await _storageService.loadBoards();
    final itemCounts = await _storageService.getItemCountByType();
    
    // Calculate statistics
    _totalBoards = boards.length;
    _totalItems = await _storageService.getTotalItemCount();
    _photoCount = itemCounts['photo'] ?? 0;
    _noteCount = itemCounts['note'] ?? 0;
    _stickerCount = itemCounts['sticker'] ?? 0;
    
    if (boards.isNotEmpty) {
      _averageItemsPerBoard = (_totalItems / _totalBoards).round();
      
      // Most used theme
      final themeCounts = <String, int>{};
      for (final board in boards) {
        themeCounts[board.theme] = (themeCounts[board.theme] ?? 0) + 1;
      }
      _mostUsedTheme = themeCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // Oldest and newest boards
      final sortedByDate = List<ScrapbookBoard>.from(boards)
        ..sort((a, b) => a.createdDate.compareTo(b.createdDate));
      _oldestBoardName = sortedByDate.first.title;
      _newestBoardName = sortedByDate.last.title;
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: VintageLoading(message: 'Loading Statistics...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
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
      body: _totalBoards == 0
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverviewCard(),
                const SizedBox(height: 16),
                _buildItemTypesCard(),
                const SizedBox(height: 16),
                _buildThemesCard(),
                const SizedBox(height: 16),
                _buildMilestonesCard(),
                const SizedBox(height: 16),
                _buildAchievementsCard(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: const Color(0xFF8B4513).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create scrapbooks to see statistics',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF8B4513).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513),
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
                Icons.dashboard,
                color: const Color(0xFF8B4513),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.book,
                  label: 'Scrapbooks',
                  value: _totalBoards.toString(),
                  color: const Color(0xFFC19A6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.collections,
                  label: 'Total Items',
                  value: _totalItems.toString(),
                  color: const Color(0xFF2D5016),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            icon: Icons.analytics,
            label: 'Avg Items/Board',
            value: _averageItemsPerBoard.toString(),
            color: const Color(0xFF8B4513),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTypesCard() {
    final total = _photoCount + _noteCount + _stickerCount;
    final photoPercent = total > 0 ? (_photoCount / total * 100).round() : 0;
    final notePercent = total > 0 ? (_noteCount / total * 100).round() : 0;
    final stickerPercent = total > 0 ? (_stickerCount / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513),
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
                Icons.pie_chart,
                color: const Color(0xFF8B4513),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Item Types',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            icon: Icons.photo,
            label: 'Photos',
            count: _photoCount,
            percent: photoPercent,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            icon: Icons.note,
            label: 'Notes',
            count: _noteCount,
            percent: notePercent,
            color: const Color(0xFFFFEB3B),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            icon: Icons.star,
            label: 'Stickers',
            count: _stickerCount,
            percent: stickerPercent,
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513),
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
                Icons.palette,
                color: const Color(0xFF8B4513),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Favorite Theme',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getThemeColor(_mostUsedTheme),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8B4513),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getThemeIcon(_mostUsedTheme),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Text(
                  _mostUsedTheme.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513),
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
                Icons.timeline,
                color: const Color(0xFF8B4513),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Milestones',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMilestoneItem(
            icon: Icons.first_page,
            label: 'First Scrapbook',
            value: _oldestBoardName,
          ),
          const SizedBox(height: 12),
          _buildMilestoneItem(
            icon: Icons.new_releases,
            label: 'Latest Scrapbook',
            value: _newestBoardName,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    final achievements = <Map<String, dynamic>>[];
    
    if (_totalBoards >= 1) {
      achievements.add({
        'icon': Icons.emoji_events,
        'title': 'Getting Started',
        'description': 'Created your first scrapbook',
        'unlocked': true,
      });
    }
    if (_totalBoards >= 5) {
      achievements.add({
        'icon': Icons.collections_bookmark,
        'title': 'Collector',
        'description': 'Created 5 scrapbooks',
        'unlocked': true,
      });
    }
    if (_totalBoards >= 10) {
      achievements.add({
        'icon': Icons.workspace_premium,
        'title': 'Memory Master',
        'description': 'Created 10 scrapbooks',
        'unlocked': true,
      });
    }
    if (_totalItems >= 50) {
      achievements.add({
        'icon': Icons.star,
        'title': 'Content Creator',
        'description': 'Added 50 items',
        'unlocked': true,
      });
    }
    if (_photoCount >= 20) {
      achievements.add({
        'icon': Icons.photo_camera,
        'title': 'Photographer',
        'description': 'Added 20 photos',
        'unlocked': true,
      });
    }

    // Add locked achievements
    if (_totalBoards < 10) {
      achievements.add({
        'icon': Icons.workspace_premium,
        'title': 'Memory Master',
        'description': 'Create 10 scrapbooks',
        'unlocked': false,
      });
    }
    if (_totalItems < 100) {
      achievements.add({
        'icon': Icons.military_tech,
        'title': 'Legendary',
        'description': 'Add 100 items',
        'unlocked': false,
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513),
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
                Icons.emoji_events,
                color: const Color(0xFF8B4513),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...achievements.map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAchievementItem(achievement),
              )),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required IconData icon,
    required String label,
    required int count,
    required int percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B4513),
              ),
            ),
            const Spacer(),
            Text(
              '$count ($percent%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF8B4513), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8B4513).withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final unlocked = achievement['unlocked'] as bool;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFFD700).withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: unlocked ? const Color(0xFFFFD700) : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            achievement['icon'] as IconData,
            color: unlocked ? const Color(0xFFFFD700) : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: unlocked ? const Color(0xFF8B4513) : Colors.grey,
                  ),
                ),
                Text(
                  achievement['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked
                        ? const Color(0xFF8B4513).withOpacity(0.7)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
        ],
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme) {
      case 'cork':
        return const Color(0xFFC19A6B);
      case 'felt':
        return const Color(0xFF2D5016);
      case 'album':
        return const Color(0xFF8B4513);
      default:
        return const Color(0xFF8B4513);
    }
  }

  IconData _getThemeIcon(String theme) {
    switch (theme) {
      case 'cork':
        return Icons.grid_4x4;
      case 'felt':
        return Icons.texture;
      case 'album':
        return Icons.book;
      default:
        return Icons.palette;
    }
  }
}
