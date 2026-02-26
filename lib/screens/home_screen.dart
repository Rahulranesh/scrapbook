import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scrapbook_board.dart';
import '../models/scrapbook_item.dart';
import '../services/storage_service.dart';
import 'board_detail_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';
import 'templates_screen.dart';
import 'statistics_screen.dart';
import 'timeline_screen.dart';
import '../widgets/vintage_loading.dart';
import '../widgets/theme_palette_widget.dart';
import '../theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<ScrapbookBoard> _boards = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'date'; // date, name

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    setState(() => _isLoading = true);
    final boards = await _storageService.loadBoards();
    setState(() {
      _boards = boards;
      _sortBoards();
      _isLoading = false;
    });
  }

  void _sortBoards() {
    if (_sortBy == 'date') {
      _boards.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    } else {
      _boards.sort((a, b) => a.title.compareTo(b.title));
    }
  }

  List<ScrapbookBoard> get _filteredBoards {
    if (_searchQuery.isEmpty) return _boards;
    return _boards.where((board) =>
        board.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<void> _deleteBoard(ScrapbookBoard board) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(boardTitle: board.title),
    );

    if (confirmed == true) {
      await _storageService.deleteBoard(board.id);
      await _loadBoards();
    }
  }

  Future<void> _showBoardOptions(ScrapbookBoard board) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              board.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimaryColor,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.open_in_new, color: themeProvider.primaryColor),
              title: const Text('Open'),
              onTap: () {
                Navigator.pop(context, 'open');
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy, color: themeProvider.primaryColor),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context, 'duplicate');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context, 'delete');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      switch (result) {
        case 'open':
          _openBoard(board);
          break;
        case 'duplicate':
          await _duplicateBoard(board);
          break;
        case 'delete':
          await _deleteBoard(board);
          break;
      }
    }
  }

  Future<void> _createNewBoard() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>  _NewBoardDialog(),
    );

    if (result != null) {
      final newBoard = ScrapbookBoard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title']!,
        theme: result['theme']!,
        items: [],
        createdDate: DateTime.now(),
      );

      _boards.add(newBoard);
      await _storageService.saveBoards(_boards);
      setState(() {});
    }
  }

  Future<void> _duplicateBoard(ScrapbookBoard board) async {
    final newBoard = ScrapbookBoard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${board.title} (Copy)',
      theme: board.theme,
      items: board.items.map((item) => ScrapbookItem(
        id: '${item.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
        type: item.type,
        content: item.content,
        xPosition: item.xPosition,
        yPosition: item.yPosition,
        rotation: item.rotation,
        width: item.width,
        height: item.height,
        dateAdded: DateTime.now(),
      )).toList(),
      createdDate: DateTime.now(),
    );

    _boards.add(newBoard);
    await _storageService.saveBoards(_boards);
    setState(() {});
    
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duplicated "${board.title}"'),
          backgroundColor: themeProvider.primaryColor,
        ),
      );
    }
  }

  void _openBoard(ScrapbookBoard board) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BoardDetailScreen(board: board),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Page turn animation
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
    // Reload boards when returning from detail screen
    await _loadBoards();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: VintageLoading(
          message: 'Loading Scrapbooks...',
        ),
      );
    }

    final filteredBoards = _filteredBoards;
    final hasBoards = filteredBoards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Scrapbooks',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F5DC),
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
        elevation: 8,
        shadowColor: Colors.black45,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeProvider.primaryColor,
                themeProvider.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Color(0xFFF5F5DC)),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Color(0xFFF5F5DC)),
            tooltip: 'Gallery',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFF5F5DC)),
            onSelected: (value) {
              if (value == 'sort_date') {
                setState(() {
                  _sortBy = 'date';
                  _sortBoards();
                });
              } else if (value == 'sort_name') {
                setState(() {
                  _sortBy = 'name';
                  _sortBoards();
                });
              } else if (value == 'timeline') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimelineScreen()),
                );
              } else if (value == 'templates') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TemplatesScreen()),
                ).then((created) {
                  if (created == true) _loadBoards();
                });
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                ).then((_) => _loadBoards());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'templates',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 20, color: themeProvider.primaryColor),
                    const SizedBox(width: 12),
                    const Text('Templates'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'timeline',
                child: Row(
                  children: [
                    Icon(Icons.timeline, size: 20, color: themeProvider.primaryColor),
                    const SizedBox(width: 12),
                    const Text('Timeline'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'sort_date',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'date' ? Icons.check : Icons.calendar_today,
                      size: 20,
                      color: themeProvider.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Text('Sort by Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_name',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name' ? Icons.check : Icons.sort_by_alpha,
                      size: 20,
                      color: themeProvider.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20, color: themeProvider.primaryColor),
                    const SizedBox(width: 12),
                    const Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick theme switcher
          const ThemePaletteWidget(),
          if (_boards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search scrapbooks...',
                  prefixIcon: Icon(Icons.search, color: themeProvider.primaryColor),
                  filled: true,
                  fillColor: themeProvider.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeProvider.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
          Expanded(
            child: hasBoards ? _buildBoardsGrid(filteredBoards) : _buildEmptyState(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewBoard,
        backgroundColor: themeProvider.secondaryColor,
        icon: Icon(
          Icons.add_photo_alternate,
          color: themeProvider.tertiaryColor,
        ),
        label: Text(
          'New Board',
          style: TextStyle(
            color: themeProvider.tertiaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardsGrid(List<ScrapbookBoard> boards) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Group boards by theme and favorites
    final favoriteBoards = boards.where((b) => b.isFavorite).toList();
    final corkBoards = boards.where((b) => b.theme == 'cork' && !b.isFavorite).toList();
    final feltBoards = boards.where((b) => b.theme == 'felt' && !b.isFavorite).toList();
    final albumBoards = boards.where((b) => b.theme == 'album' && !b.isFavorite).toList();
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (favoriteBoards.isNotEmpty) ...[
          _buildCategoryHeader('Favorites', Icons.favorite, themeProvider),
          _buildCarouselScroller(favoriteBoards, 'favorite', themeProvider),
          const SizedBox(height: 24),
        ],
        if (corkBoards.isNotEmpty) ...[
          _buildCategoryHeader('Cork Boards', Icons.push_pin, themeProvider),
          _buildCarouselScroller(corkBoards, 'cork', themeProvider),
          const SizedBox(height: 24),
        ],
        if (feltBoards.isNotEmpty) ...[
          _buildCategoryHeader('Felt Boards', Icons.texture, themeProvider),
          _buildCarouselScroller(feltBoards, 'felt', themeProvider),
          const SizedBox(height: 24),
        ],
        if (albumBoards.isNotEmpty) ...[
          _buildCategoryHeader('Photo Albums', Icons.photo_album, themeProvider),
          _buildCarouselScroller(albumBoards, 'album', themeProvider),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProvider.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeProvider.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: themeProvider.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimaryColor,
              fontFamily: 'serif',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.primaryColor.withOpacity(0.5),
                    themeProvider.primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselScroller(List<ScrapbookBoard> boards, String theme, ThemeProvider themeProvider) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: PageController(
          viewportFraction: 0.85, // Shows peek of adjacent cards
          initialPage: 0,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: boards.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: _buildEnhancedCard(boards[index], theme, themeProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCard(ScrapbookBoard board, String theme, ThemeProvider themeProvider) {
    return _ScrapbookCardWidget(
      board: board,
      theme: theme,
      themeProvider: themeProvider,
      onTap: () => _openBoard(board),
      onLongPress: () => _showBoardOptions(board),
      onFavoriteToggle: () => _toggleFavorite(board),
    );
  }

  Future<void> _toggleFavorite(ScrapbookBoard board) async {
    setState(() {
      final index = _boards.indexWhere((b) => b.id == board.id);
      if (index != -1) {
        _boards[index] = board.copyWith(isFavorite: !board.isFavorite);
      }
    });
    await _storageService.saveBoards(_boards);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            board.isFavorite 
                ? 'Removed from favorites' 
                : 'Added to favorites',
          ),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Provider.of<ThemeProvider>(context, listen: false).primaryColor,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vintage trunk illustration
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: themeProvider.primaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.primaryColor.withOpacity(0.7),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Trunk lid
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: themeProvider.secondaryColor,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                // Lock decoration
                Positioned(
                  top: 70,
                  left: 85,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: themeProvider.secondaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeProvider.primaryColor.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Scrapbooks Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimaryColor,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create\nyour first memory collection',
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
}

class _NewBoardDialog extends StatefulWidget {
  const _NewBoardDialog();

  @override
  State<_NewBoardDialog> createState() => _NewBoardDialogState();
}

class _NewBoardDialogState extends State<_NewBoardDialog> {
  final _titleController = TextEditingController();
  String _selectedTheme = 'cork';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: themeProvider.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: themeProvider.primaryColor,
          width: 3,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Scrapbook',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimaryColor,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Scrapbook Name',
                labelStyle: TextStyle(color: themeProvider.primaryColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: themeProvider.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeOption('cork', 'Cork', const Color(0xFFC19A6B)),
                _buildThemeOption('felt', 'Felt', const Color(0xFF2D5016)),
                _buildThemeOption('album', 'Album', const Color(0xFF8B4513)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: themeProvider.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      Navigator.pop(context, {
                        'title': _titleController.text,
                        'theme': _selectedTheme,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: themeProvider.surfaceColor,
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, String label, Color color) {
    final isSelected = _selectedTheme == theme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = theme),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? themeProvider.primaryColor
                    : Colors.transparent,
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
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: themeProvider.textPrimaryColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  final String boardTitle;

  const _DeleteConfirmationDialog({required this.boardTitle});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: themeProvider.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: themeProvider.primaryColor,
          width: 3,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: themeProvider.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Scrapbook?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimaryColor,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to delete "$boardTitle"? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: themeProvider.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: themeProvider.surfaceColor,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// Custom painter for corner fold effect
class _CornerFoldPainter extends CustomPainter {
  final Color color;

  _CornerFoldPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - size.width * 0.7, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Shadow for fold
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final shadowPath = Path()
      ..moveTo(size.width - 2, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// Stateful card widget with scale animation on press
class _ScrapbookCardWidget extends StatefulWidget {
  final ScrapbookBoard board;
  final String theme;
  final ThemeProvider themeProvider;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteToggle;

  const _ScrapbookCardWidget({
    required this.board,
    required this.theme,
    required this.themeProvider,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteToggle,
  });

  @override
  State<_ScrapbookCardWidget> createState() => _ScrapbookCardWidgetState();
}

class _ScrapbookCardWidgetState extends State<_ScrapbookCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onLongPress: widget.onLongPress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.4 : 0.25),
                    blurRadius: _isPressed ? 20 : 15,
                    offset: Offset(0, _isPressed ? 12 : 8),
                    spreadRadius: _isPressed ? 3 : 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Card background
                    _buildCardBackground(),
                    
                    // Decorative elements
                    _buildCardDecorations(),
                    
                    // Vintage accents
                    _buildVintageAccents(),
                    
                    // Content
                    _buildCardContent(),
                    
                    // Favorite button
                    _buildFavoriteButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.themeProvider.primaryColor.withOpacity(0.95),
            widget.themeProvider.secondaryColor,
            widget.themeProvider.tertiaryColor.withOpacity(0.85),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.themeProvider.surfaceColor.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCardDecorations() {
    return Stack(
      children: [
        // Corner decorations
        Positioned(
          top: 12,
          right: 12,
          child: Icon(
            Icons.auto_awesome,
            color: widget.themeProvider.surfaceColor.withOpacity(0.4),
            size: 28,
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Icon(
            Icons.favorite_border,
            color: widget.themeProvider.surfaceColor.withOpacity(0.3),
            size: 24,
          ),
        ),
        
        // Texture overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.themeProvider.surfaceColor.withOpacity(0.15),
                Colors.transparent,
                Colors.black.withOpacity(0.15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVintageAccents() {
    return Stack(
      children: [
        // Top left paper clip
        Positioned(
          top: -5,
          left: 20,
          child: Transform.rotate(
            angle: -0.3,
            child: Container(
              width: 35,
              height: 10,
              decoration: BoxDecoration(
                color: widget.themeProvider.tertiaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Top right corner fold
        Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(35, 35),
            painter: _CornerFoldPainter(widget.themeProvider.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          // Title with vintage label style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.themeProvider.primaryColor.withOpacity(0.4),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(3, 4),
                ),
              ],
            ),
            child: Text(
              widget.board.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.themeProvider.textPrimaryColor,
                fontFamily: 'serif',
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const Spacer(),
          
          // Stats with vintage card style
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.themeProvider.surfaceColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.themeProvider.primaryColor.withOpacity(0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 18,
                      color: widget.themeProvider.secondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.board.items.length} items',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.themeProvider.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: widget.themeProvider.secondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(widget.board.createdDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.themeProvider.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 14),
          
          // Theme badge with vintage stamp style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: widget.themeProvider.primaryColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getThemeIcon(widget.theme),
                  size: 16,
                  color: widget.themeProvider.surfaceColor,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.theme.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.themeProvider.surfaceColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 10,
      left: 10,
      child: GestureDetector(
        onTap: widget.onFavoriteToggle,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            widget.board.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.board.isFavorite 
                ? Colors.red.shade600 
                : widget.themeProvider.primaryColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(String theme) {
    switch (theme) {
      case 'cork':
        return Icons.push_pin;
      case 'felt':
        return Icons.texture;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.photo_album;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
