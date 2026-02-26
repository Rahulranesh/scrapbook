# 📔 Scrapbook Memories

A vintage-themed digital scrapbook app built with Flutter. Create beautiful memory boards with photos, notes, and stickers in a nostalgic 80s/90s aesthetic.

## ✨ Features

### 🎨 Vintage Aesthetic
- Handwritten-style fonts (Special Elite, Caveat)
- Retro color palette (cream, brown, cork, felt green)
- Paper texture overlays throughout
- Multi-layered shadows for physical depth
- Authentic vintage styling

### 📚 Board Management
- Create multiple scrapbook boards
- Three themes: Cork board, Felt board, Photo album
- Book spine visualization on home screen
- Persistent storage across app restarts

### 📸 Item Types
- **Photos**: Polaroid-style frames with tape corners
- **Notes**: Sticky notes with color picker and curl effect
- **Stickers**: Vintage 80s/90s icons (stars, hearts, smileys, etc.)

### 🎯 Interactions
- Drag items to reposition
- Resize with corner handles
- Rotate with top handle
- Long-press menu:
  - Edit (notes only)
  - Duplicate
  - Bring to Front / Send to Back
  - Delete

### 📤 Export & Share
- Screenshot entire board
- Save to device gallery
- Share via native share sheet
- Vintage "developing photo" animation

### 🎬 Animations
- Page turn transition between screens
- Film reel loading spinner
- Smooth drag and resize animations
- Polaroid slide animation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.8 or higher
- Dart 3.0 or higher
- iOS 12.0+ / Android 5.0+

### Installation

1. Clone the repository:
```bash
cd scrap/scrapbook_memories
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📦 Dependencies

### Core
- `flutter` - UI framework
- `google_fonts` - Handwritten fonts (Special Elite, Caveat)

### Storage
- `shared_preferences` - Board data persistence
- `path_provider` - File system access
- `image_picker` - Photo selection

### UI Components
- `flutter_staggered_grid_view` - Grid layouts
- `screenshot` - Board export
- `share_plus` - Native sharing
- `image_gallery_saver` - Save to gallery

### Optional
- `audioplayers` - Sound effects (not yet implemented)

## 🎮 Usage

### Creating a Board
1. Tap the "New Board" button on home screen
2. Enter a name for your scrapbook
3. Choose a theme (Cork, Felt, or Album)
4. Tap "Create"

### Adding Items
1. Open a board
2. Tap the camera icon in the app bar
3. Choose item type:
   - **Photo**: Select from gallery
   - **Note**: Write text and choose color
   - **Sticker**: Pick from library

### Editing Items
1. Tap an item to select it
2. Drag to move
3. Use corner handles to resize
4. Use top handle to rotate
5. Long-press for more options

### Exporting
1. Tap the camera icon in board detail
2. Wait for "developing photo" animation
3. Image saved to gallery automatically
4. Choose to share if desired

## 🎨 Customization

### Color Palette
```dart
Cream:      #F5F5DC
Brown:      #8B4513
Cork:       #C19A6B
Felt Green: #2D5016
```

### Fonts
- **App-wide**: Special Elite (typewriter style)
- **Notes**: Caveat (handwritten cursive)

## 📱 Screenshots

(Add screenshots here when available)

## 🐛 Known Issues

See [TEST_REPORT.md](TEST_REPORT.md) for detailed testing information.

### Minor Issues
- 65 deprecation warnings for `withOpacity()` (cosmetic only)
- Needs testing on various screen sizes

### Recommendations
- Test on tablets and small phones
- Add image cleanup for deleted boards
- Consider performance optimization for 20+ items

## 🔮 Future Enhancements

- [ ] Sound effects (camera shutter, paper rustle)
- [ ] Undo/Redo functionality
- [ ] Board templates
- [ ] Search and filter
- [ ] Export to PDF
- [ ] Cloud backup/sync
- [ ] Collaborative boards
- [ ] More sticker categories
- [ ] Custom sticker upload

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── scrapbook_board.dart
│   └── scrapbook_item.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── board_detail_screen.dart
│   └── sticker_library.dart
├── widgets/                  # Reusable widgets
│   ├── add_item_sheet.dart
│   ├── note_editor.dart
│   ├── paper_texture_overlay.dart
│   └── vintage_loading.dart
└── services/                 # Business logic
    └── storage_service.dart
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👏 Acknowledgments

- Inspired by vintage scrapbooking and 80s/90s aesthetics
- Google Fonts for handwritten typography
- Flutter community for excellent packages

## 📞 Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

Made with ❤️ and nostalgia
