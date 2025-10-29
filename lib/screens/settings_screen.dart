import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../services/storage_service.dart';
import '../utils/background_utils.dart';
import '../widgets/menu_bubbles_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final List<Color> _colorOptions = const [
    Color(0xFF0D47A1),
    Color(0xFF6A1B9A),
    Color(0xFF2E7D32),
    Color(0xFFB71C1C),
    Color(0xFF006064),
    Color(0xFFEF6C00),
  ];

  late Color _selectedColor;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.settingsController.backgroundColor;
    widget.settingsController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    setState(() {
      _selectedColor = widget.settingsController.backgroundColor;
    });
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.settingsController.backgroundColor.withValues(
          alpha: 0.85,
        ),
        title: const Text('How to Play', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Pop as many O₂ bubbles as you can before time runs out.\n\n'
          '- Avoid toxic bubbles, they reduce your score.\n'
          '- Chain pops to build combos and earn more capsules.\n'
          '- Use power-ups from the shop to get an edge.\n'
          '- Try the daily lab test for a unique challenge every day!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteData() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.settingsController.backgroundColor.withValues(
          alpha: 0.85,
        ),
        title: const Text(
          'Delete All Data?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will reset your progress, achievements, and shop purchases.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _clearData();
    }
  }

  Future<void> _clearData() async {
    if (_isClearing) return;

    setState(() {
      _isClearing = true;
    });

    await _storageService.clearPlayerData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data deleted'),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      _isClearing = false;
    });
  }

  Future<void> _selectColor(Color color) async {
    await widget.settingsController.updateBackgroundColor(color);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Background color updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.settingsController.backgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: buildBackgroundDecoration(backgroundColor)),
          MenuBubblesBackground(color: backgroundColor),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        Card(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'How to Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: const Text(
                              'Learn the basics and tips',
                              style: TextStyle(color: Colors.white70),
                            ),
                            onTap: _showHowToPlayDialog,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SwitchListTile.adaptive(
                            value: widget.settingsController.isMusicEnabled,
                            onChanged: (value) => widget.settingsController
                                .setMusicEnabled(value),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            secondary: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Background Music',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: const Text(
                              'Play ambient soundtrack in menus and gameplay',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.delete_forever,
                              color: Colors.redAccent,
                            ),
                            title: const Text(
                              'Delete All Data',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: const Text(
                              'Reset progress and clear storage',
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: _isClearing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                            onTap: _isClearing ? null : _confirmDeleteData,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Background Color',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _colorOptions.map((color) {
                            final isSelected = color == _selectedColor;
                            return GestureDetector(
                              onTap: () => _selectColor(color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white24,
                                    width: isSelected ? 4 : 2,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withValues(alpha: 0.8),
                                      color,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
