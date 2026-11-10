import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/crop_health/screens/scan_camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EloraApp(),
    ),
  );
}

class EloraApp extends StatelessWidget {
  const EloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elora',
      debugShowCheckedModeBanner: false,
      theme: EloraTheme.light(),
      home: const EloraShellScreen(),
    );
  }
}

class EloraShellScreen extends StatefulWidget {
  const EloraShellScreen({super.key});

  @override
  State<EloraShellScreen> createState() => _EloraShellScreenState();
}

class _EloraShellScreenState extends State<EloraShellScreen> {
  int _currentIndex = 0;

  void _openCameraScanner() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ScanCameraScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EloraColors.cream,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top curved mint header
            _buildTopHeader(context),

            // Main body content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeEloraView(context),
                  _buildPlaceholderTab('Community', Icons.people_outline),
                  const SizedBox.shrink(), // Placeholder for center FAB
                  _buildPlaceholderTab('Elora AI Assistant', Icons.chat_bubble_outline),
                  _buildPlaceholderTab('More & Settings', Icons.more_horiz),
                ],
              ),
            ),

            // Persistent curved deep-green bottom dock with elevated scan action
            _buildBottomDock(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFA6E3C3),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Circular user profile avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: EloraColors.deepGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Screen title + XP level pill
          Expanded(
            child: Row(
              children: [
                const Text(
                  'My Elora',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: EloraColors.deepGreen,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '650 / 1000 XP • Lvl 2',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: EloraColors.deepGreen,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Notification bell icon
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: EloraColors.deepGreen,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeEloraView(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF52B788), // Field Green background from docs/screens/Mobile app.png
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined, color: EloraColors.deepGreen, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tap any crop block or tap Scan below to diagnose leaf diseases.',
                      style: TextStyle(
                        fontSize: 13,
                        color: EloraColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Isometric Elora Plots Preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  _buildPlotCard('Citrus Orchard', 'Citrus • Dev 2', Icons.nature_outlined),
                  _buildPlotCard('Rose Flowerbed', 'Roses • Dev 4', Icons.local_florist_outlined),
                  _buildPlotCard(
                    'Tomato Patch',
                    'Tomato • Dev 1 (Tap to Scan)',
                    Icons.spa_outlined,
                    isFeatured: true,
                    onTap: _openCameraScanner,
                  ),
                  _buildPlotCard('Banana Grove', 'Banana • Dev 3', Icons.grass_outlined),
                  _buildPlotCard(
                    'Chilli Beds',
                    'Chilli • Dev 1',
                    Icons.energy_savings_leaf_outlined,
                    onTap: _openCameraScanner,
                  ),
                  _buildPlotCard(
                    'Point & Shoot Scan',
                    'Camera Viewfinder',
                    Icons.center_focus_strong,
                    isFeatured: true,
                    onTap: _openCameraScanner,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlotCard(
    String title,
    String subtitle,
    IconData icon, {
    bool isFeatured = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFeatured ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isFeatured
              ? Border.all(color: EloraColors.leafGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isFeatured ? EloraColors.leafGreen : EloraColors.deepGreen,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: EloraColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: EloraColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: EloraColors.leafGreen),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: EloraColors.deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Module ready for integration testing.',
            style: TextStyle(color: EloraColors.muted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E4D3B), // Deep Green navigation fill
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(0, Icons.yard_outlined, 'Elora'),
          _buildNavIcon(1, Icons.people_outline, 'Community'),
          // Elevated Center Scan FAB
          GestureDetector(
            onTap: _openCameraScanner,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF52B788), // Leaf Green
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.center_focus_weak,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          _buildNavIcon(3, Icons.chat_bubble_outline, 'Chat'),
          _buildNavIcon(4, Icons.more_horiz, 'More'),
        ],
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFA6E3C3) : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFFA6E3C3) : Colors.white70,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
