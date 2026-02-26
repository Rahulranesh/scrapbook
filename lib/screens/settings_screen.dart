import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _autoSave = true;
  bool _showGrid = false;
  bool _snapToGrid = false;
  double _exportQuality = 100;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSave = prefs.getBool('autoSave') ?? true;
      _showGrid = prefs.getBool('showGrid') ?? false;
      _snapToGrid = prefs.getBool('snapToGrid') ?? false;
      _exportQuality = prefs.getDouble('exportQuality') ?? 100;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  Future<void> _clearAllData() async {
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
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.red[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Clear All Data?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will delete all scrapbooks and images. This action cannot be undone.',
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
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _storageService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully'),
            backgroundColor: Color(0xFF8B4513),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F5DC),
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF5F5DC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'General',
            children: [
              _buildSwitchTile(
                title: 'Auto-save',
                subtitle: 'Automatically save changes',
                value: _autoSave,
                onChanged: (value) {
                  setState(() => _autoSave = value);
                  _saveSetting('autoSave', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Editor',
            children: [
              _buildSwitchTile(
                title: 'Show Grid',
                subtitle: 'Display alignment grid',
                value: _showGrid,
                onChanged: (value) {
                  setState(() => _showGrid = value);
                  _saveSetting('showGrid', value);
                },
              ),
              _buildSwitchTile(
                title: 'Snap to Grid',
                subtitle: 'Align items to grid',
                value: _snapToGrid,
                onChanged: (value) {
                  setState(() => _snapToGrid = value);
                  _saveSetting('snapToGrid', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Export',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Quality: ${_exportQuality.toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    Slider(
                      value: _exportQuality,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      activeColor: const Color(0xFF8B4513),
                      inactiveColor: const Color(0xFFC19A6B),
                      onChanged: (value) {
                        setState(() => _exportQuality = value);
                      },
                      onChangeEnd: (value) {
                        _saveSetting('exportQuality', value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Data',
            children: [
              _buildActionTile(
                title: 'Clear All Data',
                subtitle: 'Delete all scrapbooks and images',
                icon: Icons.delete_forever,
                color: Colors.red[700]!,
                onTap: _clearAllData,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'About',
            children: [
              _buildActionTile(
                title: 'About App',
                subtitle: 'Version, legal, and support',
                icon: Icons.info,
                color: const Color(0xFF8B4513),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
              _buildInfoTile(
                title: 'Version',
                value: '1.0.0', theme: Provider.of<ThemeProvider>(context).currentTheme ,
              ),
              _buildInfoTile(
                title: 'Developer',
                value: 'Scrapbook Memories Team', theme: Provider.of<ThemeProvider>(context).currentTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513).withOpacity(0.3),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
                fontFamily: 'serif',
              ),
            ),
          ),
          const Divider(
            color: Color(0xFF8B4513),
            height: 1,
            thickness: 1,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B4513),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFF8B4513).withOpacity(0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF8B4513),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: color.withOpacity(0.7),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required AppTheme theme,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: theme.textSecondary,
        ),
      ),
    );
  }
}
