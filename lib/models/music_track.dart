import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MusicTrack {
  final String id;
  final String name;
  final String url;
  final String? localPath;
  final bool isDownloaded;
  final String? artist; // Optional artist property

  MusicTrack({
    required this.id,
    required this.name,
    required this.url,
    this.localPath,
    this.isDownloaded = false,
    this.artist, // Add artist to constructor
  });

  // Create a copy of this track with updated properties
  MusicTrack copyWith({
    String? id,
    String? name,
    String? url,
    String? localPath,
    bool? isDownloaded,
    String? artist,
  }) {
    return MusicTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      artist: artist ?? this.artist,
    );
  }

  // Download the track and save it locally
  static Future<MusicTrack> downloadTrack(MusicTrack track) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/music/${track.id}.mp3';

      // Create the directory if it doesn't exist
      final dir = Directory('${directory.path}/music');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Check if the file already exists
      final file = File(filePath);
      if (await file.exists()) {
        return track.copyWith(
          localPath: filePath,
          isDownloaded: true,
        );
      }

      // Download the file
      final response = await http.get(Uri.parse(track.url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return track.copyWith(
          localPath: filePath,
          isDownloaded: true,
        );
      } else {
        throw Exception('Failed to download track: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading track: $e');
      return track; // Return original track on error
    }
  }

  // Predefined list of music tracks
  static List<MusicTrack> predefinedTracks = [
    MusicTrack(
      id: 'calm_lake',
      name: 'Calm Lake',
      url: 'https://cdn.jsdelivr.net/gh/hassandaemi/breath-audio/Calm Lake.mp3',
      artist: 'Hassan Daemi',
    ),
    MusicTrack(
      id: 'easy',
      name: 'Easy',
      url: 'https://cdn.jsdelivr.net/gh/hassandaemi/breath-audio/Easy.mp3',
      artist: 'Hassan Daemi',
    ),
    MusicTrack(
      id: 'heaven',
      name: 'Heaven',
      url: 'https://cdn.jsdelivr.net/gh/hassandaemi/breath-audio/Heaven.mp3',
      artist: 'Hassan Daemi',
    ),
    MusicTrack(
      id: 'soul',
      name: 'Soul',
      url: 'https://cdn.jsdelivr.net/gh/hassandaemi/breath-audio/Soul.mp3',
      artist: 'Hassan Daemi',
    ),
  ];
}
