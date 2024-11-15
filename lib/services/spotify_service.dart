import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  static const String clientId = '305c63f9591444a791458554ad6991f7';
  static const String clientSecret = '22556760aafc4b8983793478aed69477';

  static Future<String> getAccessToken() async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}';

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': basicAuth,
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    } else {
      throw Exception('Failed to obtain access token: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    try {
      String accessToken = await getAccessToken();

      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=podcast&type=show&market=US&limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['shows']['items'];
        final List<Map<String, dynamic>> podcasts = items
            .map((item) => {
                  'id': item['id'],
                  'name': item['name'],
                  'publisher': item['publisher'],
                  'image': item['images'][0]['url'],
                  'description': item['description'],
                })
            .toList()
            .cast<Map<String, dynamic>>();

        return podcasts;
      } else {
        throw Exception('Failed to load podcasts: ${response.body}');
      }
    } catch (e) {
      print('Error fetching podcasts: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEpisodes(String showId) async {
    try {
      String accessToken = await getAccessToken();

      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/shows/$showId/episodes?market=US'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['items'];

        return items
            .map((item) => {
                  'id': item['id'],
                  'name': item['name'],
                  'description': item['description'],
                  'duration_ms': item['duration_ms'],
                  'release_date': item['release_date'],
                  'audio_url': item['audio_preview_url'],
                })
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load episodes: ${response.body}');
      }
    } catch (e) {
      print('Error fetching episodes: $e');
      return [];
    }
  }
}
