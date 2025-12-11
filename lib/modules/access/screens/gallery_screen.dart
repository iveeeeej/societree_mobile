import 'package:flutter/material.dart';

import '../widgets/shared.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = List.generate(8, (index) => Colors.primaries[index % Colors.primaries.length]);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: const [
            LogoBadge(size: 32, elevation: false),
            SizedBox(width: 10),
            Text('Gallery'),
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0.85),
        foregroundColor: Colors.black,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: RibbonMarker())],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
        child: GridView.builder(
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    images[index].withOpacity(0.9),
                    images[index].withOpacity(0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: images[index].withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    top: 10,
                    child: FrostedCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      borderRadius: 14,
                      opacity: 0.28,
                      child: Text('Album ${index + 1}', style: appTextStyle(size: 12, weight: FontWeight.w700)),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.collections, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Curated shots & assets',
                              style: appTextStyle(color: Colors.white, size: 13, weight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(Icons.image, size: 48, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

