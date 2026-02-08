import 'dart:convert';
import 'dart:html' as html;

class BackendClient {
  BackendClient({
    required this.baseUrl,
  });

  final String baseUrl;

  Future<DecideResponse> decide(List<String> options) async {
    final payload = <String, Object?>{'options': options};
    final json = await _requestJson(
      method: 'POST',
      path: '/api/decide',
      body: payload,
    );
    if (json is! Map) {
      throw StateError('Invalid decide response: $json');
    }
    return DecideResponse.fromJson(json.cast<String, Object?>());
  }

  Future<List<HistoryItem>> history({int limit = 200}) async {
    final json = await _requestJson(
      method: 'GET',
      path: '/api/history?limit=$limit',
    );
    if (json is! List) {
      throw StateError('Invalid history response: $json');
    }
    return json
        .whereType<Map>()
        .map((e) => HistoryItem.fromJson(e.cast<String, Object?>()))
        .toList();
  }

  Future<void> clearHistory() async {
    await _request(
      method: 'DELETE',
      path: '/api/history',
    );
  }

  Future<Object?> _requestJson({
    required String method,
    required String path,
    Object? body,
  }) async {
    final text = await _request(method: method, path: path, body: body);
    if (text.trim().isEmpty) return null;
    return jsonDecode(text);
  }

  Future<String> _request({
    required String method,
    required String path,
    Object? body,
  }) async {
    final url = '$baseUrl$path';
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    String? data;
    if (body != null) {
      headers['Content-Type'] = 'application/json';
      data = jsonEncode(body);
    }

    print('[BackendClient] $method $url');
    final req = await html.HttpRequest.request(
      url,
      method: method,
      sendData: data,
      requestHeaders: headers,
    );
    final status = req.status ?? 0;
    if (status < 200 || status >= 300) {
      throw StateError('HTTP $status: ${req.responseText}');
    }
    return req.responseText ?? '';
  }
}

class DecideResponse {
  DecideResponse({
    required this.choice,
    required this.timestampMs,
    required this.recent3,
    required this.penalizedChoices,
  });

  final String choice;
  final int timestampMs;
  final List<String> recent3;
  final Set<String> penalizedChoices;

  static DecideResponse fromJson(Map<String, Object?> json) {
    final choice = json['choice'];
    final timestampMs = json['timestampMs'];
    final recent3 = json['recent3'];
    final penalized = json['penalizedChoices'];
    if (choice is! String || timestampMs is! int) {
      throw FormatException('Invalid DecideResponse json: $json');
    }
    return DecideResponse(
      choice: choice,
      timestampMs: timestampMs,
      recent3: recent3 is List ? recent3.whereType<String>().toList() : const [],
      penalizedChoices: penalized is List
          ? penalized.whereType<String>().toSet()
          : <String>{},
    );
  }
}

class HistoryItem {
  HistoryItem({
    required this.choice,
    required this.timestampMs,
  });

  final String choice;
  final int timestampMs;

  static HistoryItem fromJson(Map<String, Object?> json) {
    final choice = json['choice'];
    final timestampMs = json['timestampMs'];
    if (choice is! String || timestampMs is! int) {
      throw FormatException('Invalid HistoryItem json: $json');
    }
    return HistoryItem(choice: choice, timestampMs: timestampMs);
  }
}

