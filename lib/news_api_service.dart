import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  Map<
    String,
    dynamic
  >
  toJson() => {
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
  };
  final String
  title;
  final String
  description;
  final String
  url;
  final String
  urlToImage;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
  });

  factory NewsArticle.fromJson(
    Map<
      String,
      dynamic
    >
    json,
  ) {
    return NewsArticle(
      title:
          json['title'] ??
          '',
      description:
          json['description'] ??
          '',
      url:
          json['url'] ??
          '',
      urlToImage:
          json['urlToImage'] ??
          '',
    );
  }
}

class NewsApiService {
  static const String
  _apiKey = 'e83b17d4c3f44e49b55062717e608aef';
  static const String
  _baseUrl = 'https://newsapi.org/v2/top-headlines';

  Future<
    List<
      NewsArticle
    >
  >
  fetchNews(
    String category,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl?country=us&category=$category&apiKey=$_apiKey',
      ),
    );
    if (response.statusCode ==
        200) {
      final data = json.decode(
        response.body,
      );
      final List articles = data['articles'];
      return articles
          .map(
            (
              json,
            ) => NewsArticle.fromJson(
              json,
            ),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to load news',
      );
    }
  }
}
