import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'news_api_service.dart';

class FavoritesService {
  static const _key = 'favorite_news';
  final FlutterSecureStorage
  _storage = const FlutterSecureStorage();

  Future<
    List<
      NewsArticle
    >
  >
  getFavorites() async {
    final jsonString = await _storage.read(
      key: _key,
    );
    if (jsonString ==
        null)
      return [];
    final List list = json.decode(
      jsonString,
    );
    return list
        .map(
          (
            e,
          ) => NewsArticle.fromJson(
            e,
          ),
        )
        .toList();
  }

  Future<
    void
  >
  addFavorite(
    NewsArticle article,
  ) async {
    final favorites = await getFavorites();
    if (favorites.any(
      (
        a,
      ) =>
          a.title ==
          article.title,
    ))
      return;
    favorites.add(
      article,
    );
    await _storage.write(
      key: _key,
      value: json.encode(
        favorites
            .map(
              (
                e,
              ) => e.toJson(),
            )
            .toList(),
      ),
    );
  }

  Future<
    void
  >
  removeFavorite(
    NewsArticle article,
  ) async {
    final favorites = await getFavorites();
    favorites.removeWhere(
      (
        a,
      ) =>
          a.title ==
          article.title,
    );
    await _storage.write(
      key: _key,
      value: json.encode(
        favorites
            .map(
              (
                e,
              ) => e.toJson(),
            )
            .toList(),
      ),
    );
  }

  Future<
    bool
  >
  isFavorite(
    NewsArticle article,
  ) async {
    final favorites = await getFavorites();
    return favorites.any(
      (
        a,
      ) =>
          a.title ==
          article.title,
    );
  }
}
