# Building Memora: A Vintage-Themed Digital Memory App in Flutter

> *How I built a nostalgic 80s/90s-inspired memory app from scratch using Flutter — complete with Polaroid photos, sticky notes, cork boards, and a full custom design system.*

---

## The Idea

We live in a world of Stories, Reels, and Highlights — ephemeral content designed to disappear. But some memories deserve something more permanent. Something you can hold, arrange, and revisit years later.

That's what **Memora** is about. A digital app that replicates the tactile joy of a physical scrapbook — the kind you'd find in your grandma's attic, full of Polaroids, handwritten notes, and gold star stickers.

Built entirely in **Flutter**, this app combines vintage aesthetics with modern mobile UX. Here's the full breakdown of what I built, how it works, and the technical decisions behind it.

---

## What Is Memora?

Scrapbook Memories is a cross-platform (iOS & Android) mobile app that lets users:

- Create multiple **scrapbook boards** with unique themes
- Add **photos** (displayed as Polaroid-style frames), **sticky notes**, and **vintage stickers**
- **Drag, resize, and rotate** items freely on the board
- **Export** boards as high-quality images or PDFs
- **Share** directly via the native share sheet
- Browse a **timeline** of all memories chronologically
- View **statistics** about their scrapbooking activity
- Start with pre-built **templates** for common occasions
- Customize the entire **app theme** to their preference

The app opens with an animated splash screen, flows into a gentle 4-page onboarding experience, and lands on a home screen styled like a bookshelf — each scrapboard appearing as the spine of a book.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3 |
| State Management | Provider |
| Local Storage | SharedPreferences |
| File System | path_provider |
| Image Picking | image_picker |
| Image Processing | image (dart) |
| Export | screenshot, pdf, printing |
| Sharing | share_plus |
| Gallery Save | image_gallery_saver |
| Fonts | google_fonts (Special Elite, Caveat) |
| Grid Layouts | flutter_staggered_grid_view |
| Device/Package Info | device_info_plus, package_info_plus |
| Links | url_launcher |

---

## Architecture Overview

The project follows a clean, feature-oriented structure:

```
lib/
├── main.dart                  # App entry + splash screen + orientation lock
├── models/
│   ├── scrapbook_board.dart   # Board model (id, title, theme, items, isFavorite)
│   └── scrapbook_item.dart    # Item model (type, position, rotation, size)
├── screens/
│   ├── home_screen.dart       # Bookshelf-style board list + search/sort
│   ├── board_detail_screen.dart # Canvas editor (drag/resize/rotate)
│   ├── onboarding_screen.dart # 4-page welcome flow
│   ├── templates_screen.dart  # Pre-built board templates
│   ├── gallery_screen.dart    # Photo gallery browser
│   ├── timeline_screen.dart   # Chronological memory timeline
│   ├── statistics_screen.dart # Usage stats and insights
│   ├── settings_screen.dart   # Preferences + data management
│   ├── about_screen.dart      # App info
│   ├── photo_editor_screen.dart
│   ├── sticker_library.dart
│   ├── text_style_editor.dart
│   └── theme_selector_screen.dart
├── services/
│   └── storage_service.dart   # All CRUD operations for boards/items
├── theme/
│   ├── app_theme.dart         # Theme definitions (colors, typography)
│   └── theme_provider.dart    # ChangeNotifier for theme switching
├── widgets/
│   ├── add_item_sheet.dart    # Bottom sheet for adding items to board
│   ├── note_editor.dart       # Dialog for editing sticky notes
│   ├── paper_texture_overlay.dart # Global paper texture wrapping widget
│   ├── theme_palette_widget.dart  # Color palette UI widget
│   └── vintage_loading.dart   # Film-reel loading spinner
└── utils/                     # Utility helpers
```

### Data Models

**ScrapbookBoard** is the top-level entity:

```dart
class ScrapbookBoard {
  final String id;
  final String title;
  final String theme;        // 'cork', 'felt', or 'album'
  final List<ScrapbookItem> items;
  final DateTime createdDate;
  final bool isFavorite;
}
```

**ScrapbookItem** represents anything placed on the canvas:

```dart
class ScrapbookItem {
  final String id;
  final String type;         // 'photo', 'note', or 'sticker'
  final String content;      // image path, note text, or sticker name
  final double xPosition;
  final double yPosition;
  final double rotation;     // in radians
  final double width;
  final double height;
  final DateTime dateAdded;
}
```

Both models include full `toJson` / `fromJson` serialization for persistence via `SharedPreferences`.

---

## Key Features — Deep Dive

### 1. The Board Canvas Editor

The heart of the app. When you open a board, you enter a full-screen freeform canvas where every item is absolutely positioned using a `Stack`.

Each item supports:
- **Drag to reposition** — GestureDetector with `onPanUpdate`
- **Resize** — draggable corner handles that update width/height
- **Rotate** — top handle using pointer angle math
- **Long-press context menu** — Edit, Duplicate, Bring to Front, Send to Back, Delete

Z-ordering is managed by list index — items at the end of the list render on top. Bring to Front / Send to Back simply move the item to the end or start of the list, then re-save.

```dart
void _bringToFront(ScrapbookItem item) {
  final items = List<ScrapbookItem>.from(_board.items);
  items.removeWhere((i) => i.id == item.id);
  items.add(item);   // Add to end = render on top
  _board = _board.copyWith(items: items);
  _updateBoard();
}
```

### 2. Three Board Themes

Each board picks one of three visual backgrounds:
- **Cork board** — warm amber/brown burlap texture, classic bulletin board style
- **Felt board** — deep green, like a school-era felt display board
- **Photo album** — cream/ivory, like pages from a classic photo album

The theme affects background color, border styling, and drop shadow colors throughout.

### 3. Polaroid Photo Cards

Photos are rendered as Polaroid-style cards:
- White border (thicker at the bottom, like real Polaroids)
- Slightly rotated by default
- "Tape corners" in the CSS/paint layer for authenticity
- Multi-layered shadows for physical depth effect

When a photo is selected, an animated glow ring appears around it.

### 4. Sticky Notes with Color Picker

Notes render as handwritten sticky-note cards using the **Caveat** font from Google Fonts. Users can:
- Write multi-line text
- Pick from a palette of pastel colors (yellow, pink, blue, green, lavender, orange)
- See a subtle paper curl on the bottom-right corner (drawn with CustomPainter)

### 5. Vintage Sticker Library

A scrollable sticker picker featuring classic 80s/90s icons: stars, hearts, smileys, rainbows, flowers, and more. Each sticker is an emoji/Unicode character rendered in a styled container with a vintage look.

### 6. Export & Share

The board is wrapped in a `Screenshot` widget from the [`screenshot`](https://pub.dev/packages/screenshot) package. On tap of the share button:
1. The board is captured as PNG bytes
2. A "developing photo" animation plays (vintage camera aesthetic)
3. The user gets options: Save to Gallery, Share via Sheet, or Export as PDF

PDF export uses the `pdf` + `printing` packages, embedding the board screenshot into a full A4 page.

### 7. Timeline View

All items across all boards are flattened into a single list, sorted by `dateAdded`. This gives users a chronological "memory feed" — like scrolling through their scrapbooking history.

### 8. Statistics Screen

A dedicated analytics-style screen showing:
- Total boards and total items
- Breakdown: photos vs notes vs stickers
- Most used board theme
- Average items per board
- Oldest and newest board names

This gives the app a journaling quality — you can look back at how you've been using it over time.

### 9. Templates

Pre-built starter boards for common occasions:
- Birthday Party
- Vacation Vibes
- Wedding Day
- Graduation
- Baby Memories
- Friendship, Seasons, and more

Each template ships with pre-placed notes and stickers so users can immediately add their photos.

### 10. Multi-Theme Design System

The app has a fully dynamic design system powered by `ThemeProvider` (a `ChangeNotifier`). Every screen reads theme colors from the provider rather than hardcoding them, making the entire app re-skin automatically when the user changes their theme in Settings.

The `AppTheme` class encapsulates: primary, secondary, tertiary, background, surface, textPrimary, and textSecondary colors. Themes are persisted via `SharedPreferences`.

---

## The Vintage Aesthetic — Design Decisions

Getting the visual feel right was as important as the features. Here's what went into it:

### Typography
- **Special Elite** — a typewriter-style font used for titles and headings. It immediately evokes nostalgia.
- **Caveat** — a handwriting font used for note content. Makes notes feel genuinely handwritten.

### Color Palette
- Cream (`#F5F5DC`) — base background, like aged paper
- Cork (`#C19A6B`) — warm tan tones for cork board
- Saddle Brown (`#8B4513`) — borders, accents, depth
- Felt Green (`#2D5016`) — the felt board theme
- Vintage Gold (`#FFD700`) — highlights, stars, shimmer

### Paper Texture
The `PaperTextureOverlay` widget wraps the entire app. It uses a `CustomPainter` to draw subtle noise/grain over every screen — simulating the tooth of old paper. This runs at a low opacity so it never overwhelms content.

### Depth & Shadows
Every card, note, and photo uses multiple `BoxShadow` layers with warm-tinted colors rather than cold grey. This makes items feel like they're physically sitting on the board rather than floating in digital space.

### Animations
- **Splash screen**: fade + scale animation on the app logo (1.5s)
- **Page transition**: custom `PageRouteBuilder` with a page-turn / fade-and-scale effect
- **VintageLoading**: a film-reel spinner widget shown during data loads
- **Polaroid slide**: items animate onto the board with a slide+fade entrance
- **Export animation**: "developing photo" camera shutter effect

---

## Challenges & Solutions

### Challenge 1: Freeform Canvas Performance
With many items on a board, rebuilding the entire `Stack` on every gesture update caused jitter.

**Solution**: Used `setState` scoped to only the actively dragged item using a `selectedItemId` flag. The rest of the stack doesn't rebuild on drag events.

### Challenge 2: Persistent Storage for Complex Data
`SharedPreferences` stores strings/booleans natively, not complex objects.

**Solution**: Implemented full JSON serialization on both models. The entire boards list is encoded to a JSON string and stored under a single key. On load, it's decoded back.

### Challenge 3: Screenshot of a Scrollable Canvas
The `screenshot` package wraps a widget tree, but the board canvas can extend beyond the viewport.

**Solution**: The board canvas is a fixed-size container (matching screen dimensions), so taking a screenshot captures everything without scroll complications.

### Challenge 4: Z-Index Control
Flutter's `Stack` doesn't have a z-index property — items render in list order.

**Solution**: Items are stored in an ordered list. Bring to Front = move to end. Send to Back = move to start. Simple and effective.

---

## What's Next

- **Cloud sync** — back up boards to Firebase/iCloud
- **Collaborative boards** — shared scrapbooks with friends and family
- **Audio clips** — attach voice notes to photos (the `audioplayers` dependency is already included, awaiting implementation)
- **Handwriting recognition** — convert handwritten notes to searchable text
- **AR mode** — view scrapbook boards in augmented reality
- **Widget support** — iOS/Android home screen widgets showing a random memory

---

## Lessons Learned

1. **Start with the data model.** Everything flowed naturally once `ScrapbookBoard` and `ScrapbookItem` were well-defined.
2. **Design is a feature.** The vintage aesthetic is core to the app's identity — not decorative. Users feel something different opening this app vs a generic photo organizer.
3. **Provider is enough.** For this scale of app, you don't need Riverpod or BLoC. Provider + ChangeNotifier covers state management cleanly.
4. **Screenshots over custom rendering.** Using the `screenshot` package for export was far simpler than trying to manually reconstruct the board as a Canvas/image.
5. **Animate thoughtfully.** Every animation in this app serves the narrative — the film reel, the Polaroid slide, the page turn. Animation earns its complexity when it deepens the experience.

---

## Try It Yourself

**Memora** runs on Flutter 3.x. Clone it, run `flutter pub get`, then `flutter run`.

```bash
flutter pub get
flutter run
```

Minimum requirements:
- iOS 12.0+ or Android 5.0+ (API 21+)
- Flutter SDK 3.10.8+
- Dart 3.0+

---

## Final Thoughts

Building Scrapbook Memories reminded me that apps don't have to follow the current design meta. Dark mode, glassy morphism, and flat minimalism are fine — but there's something deeply satisfying about building something that looks and feels like it was printed on paper from the past.

Flutter made this possible in a way that would have taken me three times as long in native iOS + Android. The widget tree maps naturally to a physical scrapbook's layered structure, the animation system is expressive enough for all the vintage effects, and the cross-platform output means one codebase for both platforms.

If you're thinking about your next side project, consider reaching into the past for inspiration. Nostalgia is a powerful design tool.

---

---

> **About the name:** *Memora* is coined from *memory* + the Latin *-ora* — the aura of time. Simple enough to remember, distinct enough to own.

---

*Built with Flutter and AI. Developed at a rapid pace. Designed with love for the analog era.*

---

**Tags:** `#Flutter` `#MobileApp` `#DartLang` `#AppDevelopment` `#SideProject` `#iOS` `#Android` `#OpenSource` `#UXDesign` `#Nostalgia`
