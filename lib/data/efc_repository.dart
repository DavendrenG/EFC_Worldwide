import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'mock_data.dart';
import 'package:collection/collection.dart';

/// Every screen talks to this interface, never to HTTP directly.
/// That keeps the UI identical whether content comes from the CMS or mocks.
abstract class EfcRepository {
  Future<List<FightEvent>> events();
  Future<FightEvent?> event(String id);
  Future<List<Fighter>> fighters();
  Future<Fighter?> fighter(String id);
  Future<List<VideoItem>> videos();
  Future<List<Article>> articles();
  Future<Article?> article(String id);
}

/// Offline / demo implementation. Small delays keep loading states honest.
class MockEfcRepository implements EfcRepository {
  const MockEfcRepository({this.latency = const Duration(milliseconds: 260)});

  final Duration latency;

  Future<T> _delayed<T>(T value) async {
    await Future<void>.delayed(latency);
    return value;
  }

  @override
  Future<List<FightEvent>> events() => _delayed(MockData.events);

  @override
  Future<FightEvent?> event(String id) => _delayed(
        MockData.events.where((e) => e.id == id).firstOrNull,
      );

  @override
  Future<List<Fighter>> fighters() => _delayed(MockData.fighters);

  @override
  Future<Fighter?> fighter(String id) => _delayed(
        MockData.fighters.where((f) => f.id == id).firstOrNull,
      );

  @override
  Future<List<VideoItem>> videos() => _delayed(MockData.videos);

  @override
  Future<List<Article>> articles() => _delayed(MockData.articles);

  @override
  Future<Article?> article(String id) => _delayed(
        MockData.articles.where((a) => a.id == id).firstOrNull,
      );
}

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Production implementation. Point [baseUrl] at the EFC CMS API.
class HttpEfcRepository implements EfcRepository {
  HttpEfcRepository({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    late http.Response res;
    try {
      res = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(timeout);
    } catch (e) {
      throw ApiException('Could not reach the EFC servers. $e');
    }
    if (res.statusCode >= 400) {
      throw ApiException('Request failed for $path', res.statusCode);
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  List<Map<String, dynamic>> _list(dynamic decoded) {
    final raw = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    return (raw as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<FightEvent>> events() async =>
      _list(await _get('/events')).map(FightEvent.fromJson).toList();

  @override
  Future<FightEvent?> event(String id) async {
    final j = await _get('/events/$id');
    return j == null ? null : FightEvent.fromJson(j as Map<String, dynamic>);
  }

  @override
  Future<List<Fighter>> fighters() async =>
      _list(await _get('/fighters')).map(Fighter.fromJson).toList();

  @override
  Future<Fighter?> fighter(String id) async {
    final j = await _get('/fighters/$id');
    return j == null ? null : Fighter.fromJson(j as Map<String, dynamic>);
  }

  @override
  Future<List<VideoItem>> videos() async =>
      _list(await _get('/videos')).map(VideoItem.fromJson).toList();

  @override
  Future<List<Article>> articles() async =>
      _list(await _get('/articles')).map(Article.fromJson).toList();

  @override
  Future<Article?> article(String id) async {
    final j = await _get('/articles/$id');
    return j == null ? null : Article.fromJson(j as Map<String, dynamic>);
  }
}
