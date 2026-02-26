import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyleEditor extends StatefulWidget {
  final String initialText;
  final TextStyle? initialStyle;

  const TextStyleEditor({
    super.key,
    required this.initialText,
    this.initialStyle,
  });

  @override
  State<TextStyleEditor> createState() => _TextStyleEditorState();
}

class _TextStyleEditorState extends State<TextStyleEditor> {
  late TextEditingController _textController;
  String _selectedFont = 'Caveat';
  double _fontSize = 20;
  Color _textColor = Colors.black87;
  bool _isBold = false;
  bool _isItalic = false;
  TextAlign _textAlign = TextAlign.left;

  final List<Map<String, dynamic>> _fonts = [
    {'name': 'Caveat', 'label': 'Handwritten'},
    {'name': 'Pacifico', 'label': 'Playful'},
    {'name': 'Dancing Script', 'label': 'Elegant'},
    {'name': 'Permanent Marker', 'label': 'Marker'},
    {'name': 'Special Elite', 'label': 'Typewriter'},
    {'name': 'Indie Flower', 'label': 'Casual'},
  ];

  final List<Color> _colors = [
    Colors.black87,
    Color(0xFF8B4513),
    Color(0xFFE53935),
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
    Color(0xFFD32F2F),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5F5DC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF8B4513), width: 3),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Customize Text',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 20),
            
            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8B4513)),
              ),
              child: Text(
                _textController.text.isEmpty ? 'Preview' : _textController.text,
                textAlign: _textAlign,
                style: _getCurrentTextStyle(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Text input
            TextField(
              controller: _textController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Enter text...',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF8B4513)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Font selection
                    const Text(
                      'Font',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fonts.map((font) {
                        final isSelected = _selectedFont == font['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFont = font['name'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8B4513)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF8B4513)),
                            ),
                            child: Text(
                              font['label'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF8B4513),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Font size
                    const Text(
                      'Size',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    Slider(
                      value: _fontSize,
                      min: 12,
                      max: 48,
                      divisions: 18,
                      label: _fontSize.round().toString(),
                      activeColor: const Color(0xFF8B4513),
                      onChanged: (value) => setState(() => _fontSize = value),
                    ),
                    
                    // Color selection
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colors.map((color) {
                        final isSelected = _textColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _textColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF8B4513) : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Style options
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyleButton(
                            icon: Icons.format_bold,
                            label: 'Bold',
                            isSelected: _isBold,
                            onTap: () => setState(() => _isBold = !_isBold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStyleButton(
                            icon: Icons.format_italic,
                            label: 'Italic',
                            isSelected: _isItalic,
                            onTap: () => setState(() => _isItalic = !_isItalic),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Alignment
                    Row(
                      children: [
                        Expanded(
                          child: _buildAlignButton(
                            icon: Icons.format_align_left,
                            alignment: TextAlign.left,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAlignButton(
                            icon: Icons.format_align_center,
                            alignment: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAlignButton(
                            icon: Icons.format_align_right,
                            alignment: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
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
                    if (_textController.text.isNotEmpty) {
                      Navigator.pop(context, {
                        'text': _textController.text,
                        'style': _getCurrentTextStyle(),
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: const Color(0xFFF5F5DC),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getCurrentTextStyle() {
    return GoogleFonts.getFont(
      _selectedFont,
      fontSize: _fontSize,
      color: _textColor,
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8B4513)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8B4513),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8B4513),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignButton({
    required IconData icon,
    required TextAlign alignment,
  }) {
    final isSelected = _textAlign == alignment;
    return GestureDetector(
      onTap: () => setState(() => _textAlign = alignment),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8B4513)),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF8B4513),
          size: 20,
        ),
      ),
    );
  }
}
