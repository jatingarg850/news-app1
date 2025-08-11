import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'news_api_service.dart';
import 'favorites_service.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:async';

// --- LovePage: Rotating Heart and Message ---
class LovePage
    extends
        StatefulWidget {
  @override
  State<
    LovePage
  >
  createState() => _LovePageState();
}

class _LovePageState
    extends
        State<
          LovePage
        >
    with
        SingleTickerProviderStateMixin {
  late AnimationController
  _controller;
  late Animation<
    double
  >
  _animation;

  @override
  void
  initState() {
    super.initState();
    _controller =
        AnimationController(
          duration: const Duration(
            seconds: 2,
          ),
          vsync: this,
        )..repeat(
          reverse: true,
        );
    _animation =
        Tween<
              double
            >(
              begin: 0,
              end: 1,
            )
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ),
            );
  }

  @override
  void
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animation,
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 100,
              ),
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              '#SHANAYA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'built with love',
              style: TextStyle(
                fontSize: 18,
                color: Colors.pink,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void
main() {
  runApp(
    ShanayaNewsApp(),
  );
}

class ShanayaNewsApp
    extends
        StatelessWidget {
  @override
  Widget
  build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Shanaya News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
        ),
        primarySwatch: Colors.pink,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.pink[50],
          indicatorColor: Colors.pink[100],
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              color: Colors.pinkAccent,
            ),
          ),
        ),
      ),
      home: MainNavPage(),
    );
  }
}

class MainNavPage
    extends
        StatefulWidget {
  @override
  State<
    MainNavPage
  >
  createState() => _MainNavPageState();
}

class _MainNavPageState
    extends
        State<
          MainNavPage
        > {
  int
  _selectedIndex = 0;
  final _pages = [
    NewsHomePage(),
    ProfilePage(),
    LovePage(),
  ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    // Defensive: clamp index to valid range
    final safeIndex =
        (_selectedIndex >=
                0 &&
            _selectedIndex <
                _pages.length)
        ? _selectedIndex
        : 0;
    return Scaffold(
      body: _pages[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected:
            (
              idx,
            ) => setState(
              () => _selectedIndex = idx,
            ),
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.article_outlined,
            ),
            selectedIcon: Icon(
              Icons.article,
              color: Colors.pinkAccent,
            ),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
            ),
            selectedIcon: Icon(
              Icons.favorite,
              color: Colors.pinkAccent,
            ),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite,
            ),
            selectedIcon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            label: 'Love',
          ),
        ],
      ),
    );
  }
}

class NewsHomePage
    extends
        StatefulWidget {
  @override
  _NewsHomePageState
  createState() => _NewsHomePageState();
}

class _NewsHomePageState
    extends
        State<
          NewsHomePage
        > {
  final FavoritesService
  _favoritesService = FavoritesService();
  Set<
    String
  >
  _favoriteTitles = {};

  Future<
    void
  >
  _loadFavorites() async {
    final favs = await _favoritesService.getFavorites();
    setState(
      () {
        _favoriteTitles = favs
            .map(
              (
                e,
              ) => e.title,
            )
            .toSet();
      },
    );
  }

  Future<
    void
  >
  _toggleFavorite(
    NewsArticle news,
  ) async {
    if (_favoriteTitles.contains(
      news.title,
    )) {
      await _favoritesService.removeFavorite(
        news,
      );
    } else {
      await _favoritesService.addFavorite(
        news,
      );
    }
    _loadFavorites();
  }

  final NewsApiService
  _newsApiService = NewsApiService();
  final FlutterTts
  _flutterTts = FlutterTts();
  String
  _selectedCategory = 'science';
  late Future<
    List<
      NewsArticle
    >
  >
  _newsFuture;
  bool
  _isSpeaking = false;
  bool
  _speakerOn = false;
  Future<
    void
  >
  _speakAllHeadlines(
    List<
      NewsArticle
    >
    newsList,
  ) async {
    setState(
      () {
        _isSpeaking = true;
        _speakerOn = true;
      },
    );
    for (final news in newsList) {
      if (!_speakerOn) break;
      await _flutterTts.speak(
        news.title,
      );
      // Wait for speaking to finish headline
      await _waitForSpeechEnd();
      // Wait 2 seconds before next headline, allow user to stop in this gap
      int waited = 0;
      while (_speakerOn &&
          waited <
              2000) {
        await Future.delayed(
          Duration(
            milliseconds: 100,
          ),
        );
        waited += 100;
      }
      if (!_speakerOn) break;
    }
    setState(
      () {
        _isSpeaking = false;
        _speakerOn = false;
      },
    );
  }

  // Set in initState to avoid resetting every time
  Completer<
    void
  >?
  _speechCompleter;

  @override
  void
  initState() {
    super.initState();
    _newsFuture = _newsApiService.fetchNews(
      _selectedCategory,
    );
    _loadFavorites();
    _flutterTts.setCompletionHandler(
      () {
        if (_speechCompleter !=
                null &&
            !_speechCompleter!.isCompleted) {
          _speechCompleter!.complete();
        }
      },
    );
  }

  Future<
    void
  >
  _waitForSpeechEnd() async {
    _speechCompleter =
        Completer<
          void
        >();
    await _speechCompleter!.future;
  }

  Future<
    void
  >
  _toggleSpeaker(
    List<
      NewsArticle
    >
    newsList,
  ) async {
    if (_speakerOn) {
      setState(
        () {
          _speakerOn = false;
          _isSpeaking = false;
        },
      );
      await _flutterTts.stop();
    } else {
      await _speakAllHeadlines(
        newsList,
      );
    }
  }

  final List<
    Map<
      String,
      String
    >
  >
  _categories = [
    {
      'name': 'Science',
      'value': 'science',
    },
    {
      'name': 'Tech',
      'value': 'technology',
    },
    {
      'name': 'Health',
      'value': 'health',
    },
    {
      'name': 'Human',
      'value': 'general',
    },
    {
      'name': 'Medical',
      'value': 'health',
    },
  ];

  // Duplicate initState removed.

  void
  _changeCategory(
    String category,
  ) {
    setState(
      () {
        _selectedCategory = category;
        _newsFuture = _newsApiService.fetchNews(
          _selectedCategory,
        );
      },
    );
    _loadFavorites();
  }

  Future<
    void
  >
  _speak(
    String text,
  ) async {
    await _flutterTts.stop();
    setState(
      () => _isSpeaking = true,
    );
    await _flutterTts.speak(
      text,
    );
  }

  Future<
    void
  >
  _stopSpeaking() async {
    await _flutterTts.stop();
    setState(
      () => _isSpeaking = false,
    );
  }

  // Always opens in the default browser (Chrome if set as default). Cannot force Chrome on all devices.
  void
  _searchOnGoogle(
    String query,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
    );
    // Try using launchUrlString for better compatibility
    try {
      await launchUrlString(
        url.toString(),
        mode: LaunchMode.externalApplication,
      );
    } catch (
      e
    ) {
      // fallback
      if (await canLaunchUrl(
        url,
      )) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.newspaper,
              size: 32,
              color: Colors.white,
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              'Shanaya News',
            ),
          ],
        ),
        actions: [
          // Stop button
          if (_speakerOn)
            IconButton(
              icon: Icon(
                Icons.stop,
              ),
              tooltip: 'Stop Reciting',
              onPressed: () async {
                setState(
                  () {
                    _speakerOn = false;
                    _isSpeaking = false;
                  },
                );
                await _flutterTts.stop();
              },
            ),
          FutureBuilder<
            List<
              NewsArticle
            >
          >(
            future: _newsFuture,
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return SizedBox.shrink();
                  }
                  // Always pass the full list for the selected category
                  final allNews = snapshot.data!;
                  return IconButton(
                    icon: Icon(
                      _speakerOn
                          ? Icons.volume_off
                          : Icons.volume_up,
                    ),
                    tooltip: _speakerOn
                        ? 'Stop Reciting All'
                        : 'Recite All Headlines',
                    onPressed: () => _toggleSpeaker(
                      allNews,
                    ),
                  );
                },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map(
                (
                  cat,
                ) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: ChoiceChip(
                      label: Text(
                        cat['name']!,
                      ),
                      selected:
                          _selectedCategory ==
                          cat['value'],
                      onSelected:
                          (
                            _,
                          ) => _changeCategory(
                            cat['value']!,
                          ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          Expanded(
            child:
                FutureBuilder<
                  List<
                    NewsArticle
                  >
                >(
                  future: _newsFuture,
                  builder:
                      (
                        context,
                        snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          final errorMsg = snapshot.error.toString();
                          String userMsg = 'An error occurred.';
                          if (errorMsg.contains('SocketException') || errorMsg.contains('Failed host lookup')) {
                            userMsg = 'No internet connection or unable to reach news server.\nPlease check your connection and try again.';
                          } else if (errorMsg.contains('ClientException')) {
                            userMsg = 'Network error. Please try again later.';
                          }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off, size: 48, color: Colors.pinkAccent),
                                SizedBox(height: 16),
                                Text(
                                  userMsg,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No news found.',
                            ),
                          );
                        }
                        final newsList = snapshot.data!;
                        return ListView.builder(
                          padding: EdgeInsets.all(
                            12,
                          ),
                          itemCount: newsList.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final news = newsList[index];
                                final isFav = _favoriteTitles.contains(
                                  news.title,
                                );
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => NewsDetailPage(
                                                news: news,
                                              ),
                                        ),
                                      ).then(
                                        (
                                          _,
                                        ) => _loadFavorites(),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (news.urlToImage.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                16,
                                              ),
                                              bottomLeft: Radius.circular(
                                                16,
                                              ),
                                            ),
                                            child: Image.network(
                                              news.urlToImage,
                                              width: 100,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 100,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              12.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  news.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFav
                                                ? Colors.pinkAccent
                                                : Colors.grey,
                                          ),
                                          onPressed: () => _toggleFavorite(
                                            news,
                                          ),
                                          tooltip: isFav
                                              ? 'Remove from Favorites'
                                              : 'Add to Favorites',
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: Colors.deepPurple,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                        );
                      },
                ),
          ),
        ],
      ),
    );
  }
}

class NewsDetailPage
    extends
        StatefulWidget {
  final FavoritesService
  _favoritesService = FavoritesService();
  final NewsArticle
  news;
  NewsDetailPage({
    Key? key,
    required this.news,
  }) : super(
         key: key,
       );

  @override
  State<
    NewsDetailPage
  >
  createState() => _NewsDetailPageState();
}

class _NewsDetailPageState
    extends
        State<
          NewsDetailPage
        > {
  bool
  _isFavorite = false;

  @override
  void
  initState() {
    super.initState();
    _checkFavorite();
  }

  Future<
    void
  >
  _checkFavorite() async {
    final fav = await widget._favoritesService.isFavorite(
      widget.news,
    );
    setState(
      () => _isFavorite = fav,
    );
  }

  Future<
    void
  >
  _toggleFavorite() async {
    if (_isFavorite) {
      await widget._favoritesService.removeFavorite(
        widget.news,
      );
    } else {
      await widget._favoritesService.addFavorite(
        widget.news,
      );
    }
    _checkFavorite();
  }

  void
  _searchOnInternet(
    String query,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(
      url,
    )) {
      await launchUrl(
        url,
      );
    }
  }

  final FlutterTts
  _flutterTts = FlutterTts();
  bool
  _isSpeaking = false;

  Future<
    void
  >
  _speak(
    String text,
  ) async {
    await _flutterTts.stop();
    setState(
      () => _isSpeaking = true,
    );
    await _flutterTts.speak(
      text,
    );
  }

  Future<
    void
  >
  _stopSpeaking() async {
    await _flutterTts.stop();
    setState(
      () => _isSpeaking = false,
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final news = widget.news;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News Detail',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.pinkAccent,
            ),
            tooltip: _isFavorite
                ? 'Remove from Favorites'
                : 'Add to Favorites',
            onPressed: _toggleFavorite,
          ),
          if (_isSpeaking)
            IconButton(
              icon: Icon(
                Icons.stop,
              ),
              onPressed: _stopSpeaking,
              tooltip: 'Stop Reciting',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.urlToImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  child: Image.network(
                    news.urlToImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(
                height: 16,
              ),
              Text(
                news.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                news.description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.search,
                ),
                label: Text(
                  'Search on Internet',
                ),
                onPressed: () => _searchOnInternet(
                  news.title,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.volume_up,
                    ),
                    label: Text(
                      'Recite Heading',
                    ),
                    onPressed: () => _speak(
                      news.title,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.record_voice_over,
                    ),
                    label: Text(
                      'Recite Description',
                    ),
                    onPressed: () => _speak(
                      news.description,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage
    extends
        StatefulWidget {
  @override
  State<
    ProfilePage
  >
  createState() => _ProfilePageState();
}

class _ProfilePageState
    extends
        State<
          ProfilePage
        > {
  final FavoritesService
  _favoritesService = FavoritesService();
  late Future<
    List<
      NewsArticle
    >
  >
  _favoritesFuture;

  @override
  void
  initState() {
    super.initState();
    _favoritesFuture = _favoritesService.getFavorites();
  }

  Future<
    void
  >
  _refreshFavorites() async {
    setState(
      () {
        _favoritesFuture = _favoritesService.getFavorites();
      },
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body:
          FutureBuilder<
            List<
              NewsArticle
            >
          >(
            future: _favoritesFuture,
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No favorites yet.',
                      ),
                    );
                  }
                  final favorites = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshFavorites,
                    child: ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder:
                          (
                            context,
                            index,
                          ) {
                            final news = favorites[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: ListTile(
                                leading: news.urlToImage.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                        child: Image.network(
                                          news.urlToImage,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null,
                                title: Text(
                                  news.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            context,
                                          ) => NewsDetailPage(
                                            news: news,
                                          ),
                                    ),
                                  ).then(
                                    (
                                      _,
                                    ) => _refreshFavorites(),
                                  );
                                },
                              ),
                            );
                          },
                    ),
                  );
                },
          ),
    );
  }
}
