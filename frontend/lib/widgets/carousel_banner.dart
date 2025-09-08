import 'package:flutter/material.dart';

class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<String> images = [
    'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=1200',
    'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=1200',
    'https://images.unsplash.com/photo-1502767089025-6572583495b0?w=1200',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: images.length,
            itemBuilder: (ctx, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[i],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _index == i ? 12 : 8,
              height: _index == i ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _index == i ? Colors.blue : Colors.grey,
              ),
            );
          }),
        )
      ],
    );
  }
}
