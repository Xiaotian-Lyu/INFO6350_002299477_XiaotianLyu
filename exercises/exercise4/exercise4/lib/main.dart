import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const HeroApp());

class HeroApp extends StatelessWidget {
  const HeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Animations',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HeroHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HeroHomePage extends StatelessWidget {
  const HeroHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demoList = [
      ('Standard Hero', const HeroAnimation()),
      ('Radial Hero', const RadialHeroAnimation()),
      ('Path Hero', const PathHeroAnimation()),
      ('Morphing Hero', const MorphingHeroAnimation()),
      ('Staggered Hero', const StaggeredHeroAnimation()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hero Animation Demos')),
      body: ListView.builder(
        itemCount: demoList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(demoList[index].$1),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => demoList[index].$2),
            ),
          );
        },
      ),
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({super.key, required this.photo, this.onTap, required this.width});

  final String photo;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(photo, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class HeroAnimation extends StatelessWidget {
  const HeroAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standard Hero')),
      body: Center(
        child: PhotoHero(
          photo: 'assets/flutter.png',
          width: 300.0,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Detail Page')),
                  body: Container(
                    color: Colors.lightBlueAccent,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.topLeft,
                    child: PhotoHero(
                      photo: 'assets/flutter.png',
                      width: 100.0,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
            ));
          },
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {
  const RadialExpansion({super.key, required this.maxRadius, required this.child})
      : clipRectSize = 2.0 * (maxRadius / math.sqrt2);

  final double maxRadius;
  final double clipRectSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Center(
        child: SizedBox(
          width: clipRectSize,
          height: clipRectSize,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

RectTween _createRectTween(Rect? begin, Rect? end) {
  return MaterialRectCenterArcTween(begin: begin, end: end);
}

class RadialHeroAnimation extends StatelessWidget {
  const RadialHeroAnimation({super.key});

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;
  static const String photo = 'assets/flutter.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radial Hero')),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Radial Detail')),
                    body: Center(
                      child: Hero(
                        tag: photo,
                        createRectTween: _createRectTween,
                        child: RadialExpansion(
                          maxRadius: kMaxRadius,
                          child: Image.asset(photo, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )),
          child: Hero(
            tag: photo,
            createRectTween: _createRectTween,
            child: RadialExpansion(
              maxRadius: kMinRadius,
              child: Image.asset(photo, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class PathHeroAnimation extends StatelessWidget {
  const PathHeroAnimation({super.key});

  static const String tag = 'path-photo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Path Hero')),
      body: Center(
        child: Hero(
          tag: tag,
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            return ScaleTransition(scale: animation, child: toHeroContext.widget);
          },
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PathHeroDetail())),
            child: Image.asset('assets/flutter.png', width: 120),
          ),
        ),
      ),
    );
  }
}

class PathHeroDetail extends StatelessWidget {
  const PathHeroDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Path Detail')),
      body: Center(
        child: Hero(
          tag: 'path-photo',
          child: Image.asset('assets/flutter.png', width: 300),
        ),
      ),
    );
  }
}

class MorphingHeroAnimation extends StatelessWidget {
  const MorphingHeroAnimation({super.key});

  static const String tag = 'morph-photo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morphing Hero')),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MorphingHeroDetail())),
          child: Hero(
            tag: tag,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MorphingHeroDetail extends StatelessWidget {
  const MorphingHeroDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morphing Detail')),
      body: Center(
        child: Hero(
          tag: 'morph-photo',
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class StaggeredHeroAnimation extends StatelessWidget {
  const StaggeredHeroAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered Hero')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final tag = 'staggered-$index';
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => StaggeredHeroDetail(tag: tag),
            )),
            child: Hero(
              tag: tag,
              child: Image.asset('assets/flutter.png'),
            ),
          );
        },
      ),
    );
  }
}

class StaggeredHeroDetail extends StatelessWidget {
  final String tag;
  const StaggeredHeroDetail({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail $tag')),
      body: Center(
        child: Hero(
          tag: tag,
          child: Image.asset('assets/flutter.png', width: 300),
        ),
      ),
    );
  }
}
