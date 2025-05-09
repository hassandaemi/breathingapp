import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_state.dart';
import '../models/music_track.dart';
import '../theme/app_theme.dart';

class MusicPlayerWidget extends StatefulWidget {
  // Music player widget for playing and seeking audio tracks
  const MusicPlayerWidget({super.key});

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isSeeking = false;
  String? _error;
  late AppState _appState;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _appState = Provider.of<AppState>(context, listen: false);
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();

    // Initialize rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  void _setupAudioPlayer() async {
    // Listen for duration changes and update UI
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    // Listen for position changes and update UI
    _audioPlayer.onPositionChanged.listen((p) {
      if (!_isSeeking) {
        setState(() {
          _position = p;
        });
      }
    });
    // Listen for completion
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = _duration;
        _rotationController.stop();
      });
    });
    // Removed onPlayerError listener (not supported)
    // Load the current track (local or remote)
    await _loadTrack();
  }

  Future<void> _loadTrack() async {
    setState(() {
      _error = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      _isPlaying = false;
    });
    final MusicTrack track = _appState.musicTracks.firstWhere(
      (t) => t.id == _appState.selectedMusicTrackId,
      orElse: () => _appState.musicTracks.first,
    );
    try {
      if (track.isDownloaded && track.localPath != null) {
        await _audioPlayer.setSource(DeviceFileSource(track.localPath!));
      } else {
        await _audioPlayer.setSource(UrlSource(track.url));
      }
      // Preload duration for accurate timeline
      final d = await _audioPlayer.getDuration();
      if (d != null) {
        setState(() {
          _duration = d;
        });
      }
    } catch (e) {
      setState(() {
        // Create a more concise error message
        _error = 'Loading error: ${e.toString().split(':').first}';
      });
    }
  }

  @override
  void dispose() {
    // Dispose audio player and animation controller to free resources
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    // Format duration as mm:ss or hh:mm:ss
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return '${twoDigits(d.inHours)}:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _rotationController.stop();
    } else {
      try {
        await _audioPlayer.resume();
        _rotationController.repeat();
      } catch (e) {
        setState(() {
          // Create a more concise error message
          _error = 'Playback error';
        });
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seek(double value) async {
    // Seek to a new position in the track
    final seekTo = Duration(seconds: value.toInt());
    setState(() {
      _isSeeking = true;
      _position = seekTo;
    });
    await _audioPlayer.seek(seekTo);
    setState(() {
      _isSeeking = false;
    });
  }

  // Change to a specific track
  void _changeTrack(String trackId) async {
    if (trackId == _appState.selectedMusicTrackId) return;

    // Save current playback state
    final wasPlaying = _isPlaying;

    // Change the track
    _appState.setSelectedMusicTrack(trackId);

    // Load the new track
    await _loadTrack();

    // Resume playback if it was playing before
    if (wasPlaying) {
      await _audioPlayer.resume();
      _rotationController.repeat();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  // Show track selection dialog
  void _showTrackSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Music Track'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _appState.musicTracks.length,
                itemBuilder: (context, index) {
                  final track = _appState.musicTracks[index];
                  final isSelected = track.id == _appState.selectedMusicTrackId;

                  return ListTile(
                    title: Text(
                      track.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: !track.isDownloaded
                        ? Text(
                            'Not downloaded',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : null,
                    leading: Icon(
                      Icons.music_note,
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Download button for tracks that aren't downloaded
                        if (!track.isDownloaded)
                          IconButton(
                            icon: const Icon(Icons.download, size: 20),
                            onPressed: () async {
                              // Show download in progress
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Downloading track...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );

                              // Download the track
                              await _appState.downloadMusicTrack(track.id);

                              // Update the dialog UI
                              setState(() {});

                              // Show download complete
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Track downloaded successfully'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            tooltip: 'Download for offline use',
                          ),

                        // Selected indicator
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: AppTheme.primaryColor),
                      ],
                    ),
                    selected: isSelected,
                    onTap: () {
                      Navigator.of(context).pop();
                      _changeTrack(track.id);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MusicTrack track = _appState.musicTracks.firstWhere(
      (t) => t.id == _appState.selectedMusicTrackId,
      orElse: () => _appState.musicTracks.first,
    );
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen =
        mediaQuery.size.width < 350 || mediaQuery.size.height < 600;
    final isVerySmallScreen =
        mediaQuery.size.width < 300 || mediaQuery.size.height < 500;

    // Adaptive padding based on screen size
    final verticalPadding =
        isVerySmallScreen ? 4.0 : (isSmallScreen ? 6.0 : 8.0);
    final horizontalPadding =
        isVerySmallScreen ? 6.0 : (isSmallScreen ? 8.0 : 12.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height for the player
        final availableHeight = constraints.maxHeight;
        final compactMode = availableHeight <
            100; // Use more compact layout if space is limited

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: double.infinity,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Track info row - always show this
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Music icon with rotation animation
                          RotationTransition(
                            turns: _rotationAnimation,
                            child: Icon(
                              Icons.library_music,
                              size: isVerySmallScreen
                                  ? 24
                                  : (isSmallScreen ? 28 : 36),
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),

                          // Track info (name and artist) - clickable to open music selection
                          Expanded(
                            child: InkWell(
                              onTap: _error != null
                                  ? null
                                  : _showTrackSelectionDialog,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      track.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isVerySmallScreen
                                            ? 12
                                            : (isSmallScreen ? 13 : 15),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // Display tap to change music message
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          size: isVerySmallScreen ? 10 : 12,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Tap to change music',
                                          style: TextStyle(
                                            fontSize: isVerySmallScreen
                                                ? 9
                                                : (isSmallScreen ? 10 : 11),
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Control buttons row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Music selection button
                              IconButton(
                                icon: Icon(
                                  Icons.queue_music,
                                  size: isVerySmallScreen
                                      ? 18
                                      : (isSmallScreen ? 22 : 24),
                                  color: AppTheme.primaryColor,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: isVerySmallScreen ? 20 : 30,
                                  minHeight: isVerySmallScreen ? 20 : 30,
                                ),
                                onPressed: _error != null
                                    ? null
                                    : _showTrackSelectionDialog,
                                tooltip: 'Select music',
                              ),

                              // Play/Pause button
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: isVerySmallScreen
                                      ? 20
                                      : (isSmallScreen ? 24 : 28),
                                  color: AppTheme.primaryColor,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: isVerySmallScreen ? 24 : 36,
                                  minHeight: isVerySmallScreen ? 24 : 36,
                                ),
                                onPressed: _error != null ? null : _playPause,
                                tooltip: _isPlaying ? 'Pause' : 'Play',
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Error message - show if there's an error
                      if (_error != null)
                        Container(
                          margin: EdgeInsets.only(top: isSmallScreen ? 4 : 6),
                          constraints: const BoxConstraints(maxHeight: 20),
                          child: Text(
                            _error!,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: isSmallScreen ? 10 : 11),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                      // Timeline - only show if we have duration and enough space
                      if (_duration > Duration.zero && !compactMode)
                        Padding(
                          padding: EdgeInsets.only(top: isSmallScreen ? 4 : 6),
                          child: Row(
                            children: [
                              // Current position
                              Text(
                                _formatDuration(_position),
                                style: TextStyle(
                                  fontSize: isVerySmallScreen
                                      ? 9
                                      : (isSmallScreen ? 10 : 12),
                                ),
                              ),

                              // Slider
                              Expanded(
                                child: Slider(
                                  min: 0.0,
                                  max: _duration.inSeconds.toDouble(),
                                  value: _position.inSeconds
                                      .clamp(0, _duration.inSeconds)
                                      .toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      _isSeeking = true;
                                      _position =
                                          Duration(seconds: value.toInt());
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    _seek(value);
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ),

                              // Total duration
                              Text(
                                _formatDuration(_duration),
                                style: TextStyle(
                                  fontSize: isVerySmallScreen
                                      ? 9
                                      : (isSmallScreen ? 10 : 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Show compact timeline for very small screens
                      if (_duration > Duration.zero && compactMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: LinearProgressIndicator(
                            value: _duration.inSeconds > 0
                                ? _position.inSeconds / _duration.inSeconds
                                : 0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        ),

                      // Loading indicator - show when loading but no duration yet
                      if (_duration == Duration.zero && _error == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
