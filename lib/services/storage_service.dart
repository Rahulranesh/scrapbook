import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../models/scrapbook_board.dart';

class StorageService {
  static const String _boardsKey = 'scrapbook_boards';

  Future<void> saveBoards(List<ScrapbookBoard> boards) async {
    final prefs = await SharedPreferences.getInstance();
    final boardsJson = boards.map((board) => board.toJson()).toList();
    final boardsString = jsonEncode(boardsJson);
    await prefs.setString(_boardsKey, boardsString);
  }

  Future<List<ScrapbookBoard>> loadBoards() async {
    final prefs = await SharedPreferences.getInstance();
    final boardsString = prefs.getString(_boardsKey);
    
    if (boardsString == null || boardsString.isEmpty) {
      return [];
    }
    
    final boardsJson = jsonDecode(boardsString) as List;
    return boardsJson
        .map((json) => ScrapbookBoard.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/scrapbook_images');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Optimize image before saving
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image != null) {
      // Resize if too large (max 1920px width)
      img.Image resized = image;
      if (image.width > 1920) {
        resized = img.copyResize(image, width: 1920);
      }
      
      // Compress and save
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${imagesDir.path}/$fileName';
      final compressedBytes = img.encodeJpg(resized, quality: 85);
      await File(savedPath).writeAsBytes(compressedBytes);
      
      return savedPath;
    }
    
    // Fallback: just copy the file
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy('${imagesDir.path}/$fileName');
    return savedImage.path;
  }

  Future<void> deleteBoard(String boardId) async {
    final boards = await loadBoards();
    final boardToDelete = boards.firstWhere((board) => board.id == boardId);
    
    // Delete associated images
    for (final item in boardToDelete.items) {
      if (item.type == 'photo' && item.content.isNotEmpty) {
        final file = File(item.content);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    
    final updatedBoards = boards.where((board) => board.id != boardId).toList();
    await saveBoards(updatedBoards);
  }

  Future<void> clearAllData() async {
    // Delete all images
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/scrapbook_images');
    
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_boardsKey);
  }

  Future<int> getTotalItemCount() async {
    final boards = await loadBoards();
    int count = 0;
    for (final board in boards) {
      count += board.items.length;
    }
    return count;
  }

  Future<Map<String, int>> getItemCountByType() async {
    final boards = await loadBoards();
    final counts = <String, int>{
      'photo': 0,
      'note': 0,
      'sticker': 0,
    };
    
    for (final board in boards) {
      for (final item in board.items) {
        counts[item.type] = (counts[item.type] ?? 0) + 1;
      }
    }
    
    return counts;
  }
}
