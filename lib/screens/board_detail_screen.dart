import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/scrapbook_board.dart';
import '../models/scrapbook_item.dart';
import '../services/storage_service.dart';
import '../widgets/note_editor.dart';
import '../widgets/add_item_sheet.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class BoardDetailScreen extends StatefulWidget {
  final ScrapbookBoard board;

  const BoardDetailScreen({super.key, required this.board});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  final StorageService _storageService = StorageService();
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _selectedItemId;
  late ScrapbookBoard _board;

  @override
  void initState() {
    super.initState();
    _board = widget.board;
  }

  Future<void> _updateBoard() async {
    final boards = await _storageService.loadBoards();
    final index = boards.indexWhere((b) => b.id == _board.id);
    if (index != -1) {
      boards[index] = _board;
      await _storageService.saveBoards(boards);
    }
  }

  void _updateItem(ScrapbookItem updatedItem) {
    setState(() {
      final index = _board.items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        final items = List<ScrapbookItem>.from(_board.items);
        items[index] = updatedItem;
        _board = ScrapbookBoard(
          id: _board.id,
          title: _board.title,
          theme: _board.theme,
          items: items,
          createdDate: _board.createdDate,
        );
      }
    });
    _updateBoard();
  }

  void _deleteItem(ScrapbookItem item) {
    setState(() {
      final items = List<ScrapbookItem>.from(_board.items);
      items.removeWhere((i) => i.id == item.id);
      _board = ScrapbookBoard(
        id: _board.id,
        title: _board.title,
        theme: _board.theme,
        items: items,
        createdDate: _board.createdDate,
      );
      _selectedItemId = null;
    });
    _updateBoard();
  }

  void _duplicateItem(ScrapbookItem item) {
    final newItem = ScrapbookItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: item.type,
      content: item.content,
      xPosition: item.xPosition + 20,
      yPosition: item.yPosition + 20,
      rotation: item.rotation,
      width: item.width,
      height: item.height,
      dateAdded: DateTime.now(),
    );
    
    setState(() {
      final items = List<ScrapbookItem>.from(_board.items);
      items.add(newItem);
      _board = ScrapbookBoard(
        id: _board.id,
        title: _board.title,
        theme: _board.theme,
        items: items,
        createdDate: _board.createdDate,
      );
    });
    _updateBoard();
  }

  void _bringToFront(ScrapbookItem item) {
    setState(() {
      final items = List<ScrapbookItem>.from(_board.items);
      items.removeWhere((i) => i.id == item.id);
      items.add(item);
      _board = ScrapbookBoard(
        id: _board.id,
        title: _board.title,
        theme: _board.theme,
        items: items,
        createdDate: _board.createdDate,
      );
    });
    _updateBoard();
  }

  void _sendToBack(ScrapbookItem item) {
    setState(() {
      final items = List<ScrapbookItem>.from(_board.items);
      items.removeWhere((i) => i.id == item.id);
      items.insert(0, item);
      _board = ScrapbookBoard(
        id: _board.id,
        title: _board.title,
        theme: _board.theme,
        items: items,
        createdDate: _board.createdDate,
      );
    });
    _updateBoard();
  }

  Future<void> _editItem(ScrapbookItem item) async {
    if (item.type == 'note') {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => NoteEditor(
          initialText: item.content,
          initialColor: _getNoteColor(item.content),
        ),
      );

      if (result != null) {
        final updatedItem = ScrapbookItem(
          id: item.id,
          type: item.type,
          content: result['text'],
          xPosition: item.xPosition,
          yPosition: item.yPosition,
          rotation: item.rotation,
          width: item.width,
          height: item.height,
          dateAdded: item.dateAdded,
        );
        _updateItem(updatedItem);
      }
    }
  }

  Color _getNoteColor(String content) {
    // Default to yellow if no color info
    return const Color(0xFFFFF59D);
  }

  Future<void> _showItemMenu(BuildContext context, ScrapbookItem item, Offset position) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFF8B4513),
          width: 2,
        ),
      ),
      color: const Color(0xFFF5F5DC),
      items: [
        if (item.type == 'note')
          PopupMenuItem<String>(
            value: 'edit',
            child: _buildMenuItem(Icons.edit, 'Edit'),
          ),
        PopupMenuItem<String>(
          value: 'duplicate',
          child: _buildMenuItem(Icons.content_copy, 'Duplicate'),
        ),
        PopupMenuItem<String>(
          value: 'front',
          child: _buildMenuItem(Icons.flip_to_front, 'Bring to Front'),
        ),
        PopupMenuItem<String>(
          value: 'back',
          child: _buildMenuItem(Icons.flip_to_back, 'Send to Back'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: _buildMenuItem(Icons.delete, 'Delete', isDestructive: true),
        ),
      ],
    );

    if (result != null && mounted) {
      switch (result) {
        case 'edit':
          await _editItem(item);
          break;
        case 'duplicate':
          _duplicateItem(item);
          break;
        case 'front':
          _bringToFront(item);
          break;
        case 'back':
          _sendToBack(item);
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation(item);
          if (confirmed == true) {
            _deleteItem(item);
          }
          break;
      }
    }
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isDestructive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDestructive ? Colors.red[700] : const Color(0xFF8B4513),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDestructive ? Colors.red[700] : const Color(0xFF8B4513),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _exportBoard() async {
    setState(() {
      _selectedItemId = null; // Hide selection handles
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DevelopingPhotoDialog(),
    );

    try {
      // Wait a moment for UI to update
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture screenshot
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 2.0,
      );

      if (imageBytes != null) {
        // Save to gallery
        final result = await ImageGallerySaver.saveImage(
          imageBytes,
          quality: 100,
          name: 'scrapbook_${_board.title}_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        if (result['isSuccess'] == true) {
          // Show success message
          _showSuccessMessage();

          // Ask if user wants to share
          final shouldShare = await _showShareDialog();
          if (shouldShare == true) {
            await _shareImage(imageBytes);
          }
        } else {
          _showErrorMessage('Failed to save image');
        }
      } else {
        if (mounted) Navigator.pop(context);
        _showErrorMessage('Failed to capture screenshot');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorMessage('Error: $e');
    }
  }

  Future<void> _shareImage(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/scrapbook_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my scrapbook: ${_board.title}',
      );
    } catch (e) {
      _showErrorMessage('Failed to share: $e');
    }
  }

  Future<bool?> _showShareDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF5F5DC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF8B4513),
            width: 3,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.share,
                size: 48,
                color: Color(0xFF8B4513),
              ),
              const SizedBox(height: 16),
              Text(
                'Share Scrapbook?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Would you like to share this scrapbook with others?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8B4513).withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Not Now',
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
                    child: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
              // Polaroid-style success indicator
              Container(
                width: 120,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Photo Developed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scrapbook saved to gallery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8B4513).withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: const Color(0xFFF5F5DC),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Future<void> _editBoard() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _EditBoardDialog(
        initialTitle: _board.title,
        initialTheme: _board.theme,
      ),
    );

    if (result != null) {
      setState(() {
        _board = ScrapbookBoard(
          id: _board.id,
          title: result['title']!,
          theme: result['theme']!,
          items: _board.items,
          createdDate: _board.createdDate,
        );
      });
      await _updateBoard();
    }
  }

  Future<void> _showAddItemSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddItemSheet(),
    );

    if (result != null) {
      _addItemToBoard(result);
    }
  }

  void _addItemToBoard(Map<String, dynamic> itemData) {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2 - 100;
    final centerY = screenSize.height / 2 - 100;

    final newItem = ScrapbookItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: itemData['type'],
      content: itemData['content'],
      xPosition: centerX,
      yPosition: centerY,
      rotation: 0,
      width: itemData['type'] == 'sticker' ? 80 : 200,
      height: itemData['type'] == 'sticker' ? 80 : 200,
      dateAdded: DateTime.now(),
    );

    setState(() {
      final items = List<ScrapbookItem>.from(_board.items);
      items.add(newItem);
      _board = ScrapbookBoard(
        id: _board.id,
        title: _board.title,
        theme: _board.theme,
        items: items,
        createdDate: _board.createdDate,
      );
    });
    _updateBoard();
  }

  Future<bool?> _showDeleteConfirmation(ScrapbookItem item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF5F5DC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF8B4513),
            width: 3,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.red[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Item?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete this ${item.type}? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8B4513).withOpacity(0.8),
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
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _board.title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F5DC), // Cream
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513).withOpacity(0.9), // Brown
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF5F5DC)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFF5F5DC)),
            onPressed: _editBoard,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFFF5F5DC)),
            onPressed: _exportBoard,
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate, color: Color(0xFFF5F5DC)),
            onPressed: _showAddItemSheet,
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(
          children: [
            _buildBackground(),
            // Display items
            ..._board.items.map((item) => _buildItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    switch (_board.theme) {
      case 'cork':
        return _buildCorkBackground();
      case 'felt':
        return _buildFeltBackground();
      case 'album':
        return _buildAlbumBackground();
      default:
        return _buildCorkBackground();
    }
  }

  Widget _buildCorkBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFC19A6B), // Cork
      ),
      child: CustomPaint(
        painter: _CorkTexturePainter(),
      ),
    );
  }

  Widget _buildFeltBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2D5016), // Felt green
      ),
      child: CustomPaint(
        painter: _FeltTexturePainter(),
      ),
    );
  }

  Widget _buildAlbumBackground() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5DC), // Cream
          ),
          child: CustomPaint(
            painter: _AlbumPagePainter(),
          ),
        ),
        // Corner tabs
        Positioned(
          top: 100,
          right: 0,
          child: _buildCornerTab(),
        ),
        Positioned(
          top: 200,
          right: 0,
          child: _buildCornerTab(),
        ),
        Positioned(
          top: 300,
          right: 0,
          child: _buildCornerTab(),
        ),
      ],
    );
  }

  Widget _buildCornerTab() {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5CC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        border: Border.all(
          color: const Color(0xFFD0D0B8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(-2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(ScrapbookItem item) {
    final isSelected = _selectedItemId == item.id;
    
    return Positioned(
      left: item.xPosition,
      top: item.yPosition,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedItemId = isSelected ? null : item.id;
          });
        },
        onLongPress: () {
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(
            Offset(item.xPosition + item.width / 2, item.yPosition + item.height / 2),
            ancestor: overlay,
          );
          _showItemMenu(context, item, position);
        },
        onPanUpdate: (details) {
          final updatedItem = ScrapbookItem(
            id: item.id,
            type: item.type,
            content: item.content,
            xPosition: item.xPosition + details.delta.dx,
            yPosition: item.yPosition + details.delta.dy,
            rotation: item.rotation,
            width: item.width,
            height: item.height,
            dateAdded: item.dateAdded,
          );
          _updateItem(updatedItem);
        },
        child: Transform.rotate(
          angle: item.rotation,
          child: Container(
            width: item.width,
            height: item.height,
            decoration: BoxDecoration(
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                _buildItemContent(item),
                if (isSelected) ...[
                  // Resize handles at corners
                  Positioned(
                    top: -8,
                    left: -8,
                    child: _buildResizeHandle(item, 'topLeft'),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: _buildResizeHandle(item, 'topRight'),
                  ),
                  Positioned(
                    bottom: -8,
                    left: -8,
                    child: _buildResizeHandle(item, 'bottomLeft'),
                  ),
                  Positioned(
                    bottom: -8,
                    right: -8,
                    child: _buildResizeHandle(item, 'bottomRight'),
                  ),
                  // Rotation handle at top center
                  Positioned(
                    top: -30,
                    left: item.width / 2 - 12,
                    child: _buildRotationHandle(item),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandle(ScrapbookItem item, String position) {
    return GestureDetector(
      onPanUpdate: (details) {
        double newWidth = item.width;
        double newHeight = item.height;
        double newX = item.xPosition;
        double newY = item.yPosition;

        switch (position) {
          case 'topLeft':
            newWidth = item.width - details.delta.dx;
            newHeight = item.height - details.delta.dy;
            newX = item.xPosition + details.delta.dx;
            newY = item.yPosition + details.delta.dy;
            break;
          case 'topRight':
            newWidth = item.width + details.delta.dx;
            newHeight = item.height - details.delta.dy;
            newY = item.yPosition + details.delta.dy;
            break;
          case 'bottomLeft':
            newWidth = item.width - details.delta.dx;
            newHeight = item.height + details.delta.dy;
            newX = item.xPosition + details.delta.dx;
            break;
          case 'bottomRight':
            newWidth = item.width + details.delta.dx;
            newHeight = item.height + details.delta.dy;
            break;
        }

        // Minimum size constraints
        if (newWidth < 50 || newHeight < 50) return;

        final updatedItem = ScrapbookItem(
          id: item.id,
          type: item.type,
          content: item.content,
          xPosition: newX,
          yPosition: newY,
          rotation: item.rotation,
          width: newWidth,
          height: newHeight,
          dateAdded: item.dateAdded,
        );
        _updateItem(updatedItem);
      },
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF8B4513),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationHandle(ScrapbookItem item) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Calculate rotation based on drag
        final center = Offset(
          item.xPosition + item.width / 2,
          item.yPosition + item.height / 2,
        );
        final angle = (details.globalPosition.dx - center.dx).sign * 0.05;
        
        final updatedItem = ScrapbookItem(
          id: item.id,
          type: item.type,
          content: item.content,
          xPosition: item.xPosition,
          yPosition: item.yPosition,
          rotation: item.rotation + angle,
          width: item.width,
          height: item.height,
          dateAdded: item.dateAdded,
        );
        _updateItem(updatedItem);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF2D5016),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.rotate_right,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildItemContent(ScrapbookItem item) {
    switch (item.type) {
      case 'photo':
        return _buildPhotoItem(item);
      case 'note':
        return _buildNoteItem(item);
      case 'sticker':
        return _buildStickerItem(item);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhotoItem(ScrapbookItem item) {
    return Stack(
      children: [
        // Polaroid frame with enhanced shadow
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(4, 6),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: item.content.isNotEmpty && File(item.content).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.file(
                            File(item.content),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.photo,
                            size: 40,
                            color: Colors.grey[500],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // Tape pieces at corners
        Positioned(
          top: -5,
          left: 10,
          child: _buildTapePiece(),
        ),
        Positioned(
          top: -5,
          right: 10,
          child: _buildTapePiece(),
        ),
      ],
    );
  }

  Widget _buildNoteItem(ScrapbookItem item) {
    return Stack(
      children: [
        // Sticky note with enhanced shadow
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF59D), // Yellow sticky note
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 5),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Paper texture
              CustomPaint(
                painter: _PaperTexturePainter(),
                size: Size(item.width, item.height),
              ),
              // Note content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  item.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontFamily: 'cursive',
                  ),
                ),
              ),
              // Curl effect at bottom right
              Positioned(
                bottom: 0,
                right: 0,
                child: CustomPaint(
                  painter: _CurlPainter(),
                  size: const Size(30, 30),
                ),
              ),
            ],
          ),
        ),
        // Tape piece at top
        Positioned(
          top: -5,
          left: item.width / 2 - 20,
          child: _buildTapePiece(),
        ),
      ],
    );
  }

  Widget _buildStickerItem(ScrapbookItem item) {
    // Vintage 80s/90s style stickers
    IconData stickerIcon;
    Color stickerColor;
    
    switch (item.content) {
      case 'star':
        stickerIcon = Icons.star;
        stickerColor = const Color(0xFFFFD700); // Gold
        break;
      case 'heart':
        stickerIcon = Icons.favorite;
        stickerColor = const Color(0xFFFF69B4); // Hot pink
        break;
      case 'smile':
        stickerIcon = Icons.sentiment_very_satisfied;
        stickerColor = const Color(0xFFFFEB3B); // Yellow
        break;
      case 'music':
        stickerIcon = Icons.music_note;
        stickerColor = const Color(0xFF9C27B0); // Purple
        break;
      case 'sun':
        stickerIcon = Icons.wb_sunny;
        stickerColor = const Color(0xFFFF9800); // Orange
        break;
      default:
        stickerIcon = Icons.circle;
        stickerColor = const Color(0xFF00BCD4); // Cyan
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: stickerColor,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(3, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          stickerIcon,
          size: item.width * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTapePiece() {
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6).withOpacity(0.8),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _CorkTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create cork grain texture with random dots and lines
    for (int i = 0; i < 500; i++) {
      final x = (i * 37 % size.width.toInt()).toDouble();
      final y = (i * 73 % size.height.toInt()).toDouble();
      
      // Darker spots
      paint.color = const Color(0xFFB08A5B).withOpacity(0.3);
      canvas.drawCircle(Offset(x, y), 2, paint);
      
      // Lighter spots
      paint.color = const Color(0xFFD4B896).withOpacity(0.2);
      canvas.drawCircle(Offset(x + 5, y + 5), 1.5, paint);
    }

    // Add some grain lines
    paint.strokeWidth = 0.5;
    for (int i = 0; i < 100; i++) {
      final x = (i * 67 % size.width.toInt()).toDouble();
      final y = (i * 89 % size.height.toInt()).toDouble();
      
      paint.color = const Color(0xFF8B7355).withOpacity(0.15);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 10, y + 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeltTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create felt fabric texture with cross-hatch pattern
    for (int i = 0; i < 800; i++) {
      final x = (i * 41 % size.width.toInt()).toDouble();
      final y = (i * 59 % size.height.toInt()).toDouble();
      
      // Fabric fibers
      paint.color = const Color(0xFF1F3D0F).withOpacity(0.3);
      canvas.drawCircle(Offset(x, y), 1, paint);
      
      paint.color = const Color(0xFF3D6B1F).withOpacity(0.2);
      canvas.drawCircle(Offset(x + 2, y + 2), 0.8, paint);
    }

    // Add fabric weave lines
    paint.strokeWidth = 0.3;
    paint.color = const Color(0xFF1F3D0F).withOpacity(0.2);
    
    for (double i = 0; i < size.width; i += 8) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.height; i += 8) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlbumPagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create aged paper texture
    for (int i = 0; i < 300; i++) {
      final x = (i * 53 % size.width.toInt()).toDouble();
      final y = (i * 79 % size.height.toInt()).toDouble();
      
      // Age spots
      paint.color = const Color(0xFFE5D5B5).withOpacity(0.3);
      canvas.drawCircle(Offset(x, y), 3, paint);
      
      paint.color = const Color(0xFFD0C0A0).withOpacity(0.2);
      canvas.drawCircle(Offset(x + 3, y + 3), 2, paint);
    }

    // Add subtle paper grain
    paint.strokeWidth = 0.2;
    for (int i = 0; i < 150; i++) {
      final x = (i * 71 % size.width.toInt()).toDouble();
      final y = (i * 97 % size.height.toInt()).toDouble();
      
      paint.color = const Color(0xFFD0C0A0).withOpacity(0.1);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 15, y + 1),
        paint,
      );
    }

    // Add vintage border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = const Color(0xFFD0C0A0).withOpacity(0.5);
    canvas.drawRect(
      Rect.fromLTWH(20, 100, size.width - 40, size.height - 120),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Add subtle paper texture
    for (int i = 0; i < 50; i++) {
      final x = (i * 31 % size.width.toInt()).toDouble();
      final y = (i * 47 % size.height.toInt()).toDouble();
      
      paint.color = const Color(0xFFFFF176).withOpacity(0.3);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEE58)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.7,
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Shadow for curl
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DevelopingPhotoDialog extends StatefulWidget {
  const _DevelopingPhotoDialog();

  @override
  State<_DevelopingPhotoDialog> createState() => _DevelopingPhotoDialogState();
}

class _DevelopingPhotoDialogState extends State<_DevelopingPhotoDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
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
            // Animated polaroid coming out of camera
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * _controller.value),
                  child: Opacity(
                    opacity: 1.0 - (_controller.value * 0.3),
                    child: Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.photo,
                                  size: 32,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Camera icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 40,
                color: Color(0xFFF5F5DC),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Developing Photo...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait while we capture\nyour scrapbook',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF8B4513).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: const Color(0xFFD0C0A0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF8B4513),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditBoardDialog extends StatefulWidget {
  final String initialTitle;
  final String initialTheme;

  const _EditBoardDialog({
    required this.initialTitle,
    required this.initialTheme,
  });

  @override
  State<_EditBoardDialog> createState() => _EditBoardDialogState();
}

class _EditBoardDialogState extends State<_EditBoardDialog> {
  late TextEditingController _titleController;
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedTheme = widget.initialTheme;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5F5DC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFF8B4513),
          width: 3,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Scrapbook',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
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
            const SizedBox(height: 20),
            Text(
              'Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF8B4513)),
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
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: const Color(0xFFF5F5DC),
                  ),
                  child: const Text('Save'),
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
                    ? const Color(0xFF8B4513)
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
              color: const Color(0xFF8B4513),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
