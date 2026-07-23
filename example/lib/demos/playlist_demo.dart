import 'package:flutter/material.dart';
import 'package:flutter_drag_auto_scroll/flutter_drag_auto_scroll.dart';

/// Same-tree demo: a music playlist whose songs can be reordered by dragging.
///
/// The [DragAutoScroller] creates its controller internally and provides it
/// to the [AutoScrollDraggable] rows via [DragAutoScrollScope] — no explicit
/// wiring needed.
class PlaylistDemo extends StatefulWidget {
  const PlaylistDemo({super.key});

  @override
  State<PlaylistDemo> createState() => _PlaylistDemoState();
}

class _Song {
  const _Song(this.title, this.artist, this.duration, this.artIndex);

  final String title;
  final String artist;
  final String duration;
  final int artIndex;
}

const _initialSongs = [
  _Song('Neon Skyline', 'Cassette Motel', '3:42', 0),
  _Song('Paper Planes at Dawn', 'The Velvet Foxes', '4:05', 1),
  _Song('Golden Hour Drive', 'Mona & The Waves', '3:18', 2),
  _Song('Static Bloom', 'Polar Youth Club', '2:57', 3),
  _Song('Milemarker 82', 'Harbor Lights', '4:26', 4),
  _Song('Tangerine Radio', 'June Atlas', '3:33', 5),
  _Song('Slow Motion City', 'The Night Cartographers', '5:01', 6),
  _Song('Coastline Confetti', 'Riva Fontaine', '3:12', 7),
  _Song('Half Past Summer', 'Cassette Motel', '3:48', 0),
  _Song('Wildflower Highway', 'Dust & Denim', '4:14', 1),
  _Song('Echoes in the Backseat', 'Polar Youth Club', '3:26', 2),
  _Song('Cherry Cola Nights', 'The Velvet Foxes', '2:49', 3),
  _Song('Lighthouse Parade', 'Harbor Lights', '4:37', 4),
  _Song('Analog Heart', 'June Atlas', '3:05', 5),
  _Song('Midnight Fuel Stop', 'Dust & Denim', '3:57', 6),
  _Song('Postcards from Nowhere', 'Mona & The Waves', '4:22', 7),
  _Song('Sunroof Symphony', 'Riva Fontaine', '3:36', 0),
  _Song('Gravel Road Waltz', 'The Night Cartographers', '4:48', 1),
  _Song('Fireflies on the Dash', 'Cassette Motel', '3:21', 2),
  _Song('Borrowed Sunglasses', 'June Atlas', '2:54', 3),
  _Song('Detour Season', 'Polar Youth Club', '3:44', 4),
  _Song('Vanilla Sky Rerun', 'The Velvet Foxes', '4:09', 5),
  _Song('Last Exit Lullaby', 'Harbor Lights', '4:52', 6),
  _Song('Homeward Static', 'Dust & Denim', '3:29', 7),
];

const _artGradients = [
  [Color(0xFF7C4DFF), Color(0xFF448AFF)],
  [Color(0xFFFF7043), Color(0xFFFFCA28)],
  [Color(0xFF26A69A), Color(0xFF9CCC65)],
  [Color(0xFFEC407A), Color(0xFFAB47BC)],
  [Color(0xFF5C6BC0), Color(0xFF29B6F6)],
  [Color(0xFFFFA726), Color(0xFFEF5350)],
  [Color(0xFF66BB6A), Color(0xFF26C6DA)],
  [Color(0xFF8D6E63), Color(0xFFFF8A65)],
];

class _PlaylistDemoState extends State<PlaylistDemo> {
  final _scrollController = ScrollController();
  final _songs = List.of(_initialSongs);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onReorder(int draggedIndex, int insertBeforeIndex) {
    setState(() {
      if (insertBeforeIndex > draggedIndex) insertBeforeIndex--;
      if (draggedIndex == insertBeforeIndex) return;
      final song = _songs.removeAt(draggedIndex);
      _songs.insert(insertBeforeIndex, song);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
              child: _PlaylistHeader(songCount: _songs.length),
            ),
            Expanded(
              child: DragAutoScroller(
                scrollController: _scrollController,
                showEdgeZones: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) => _ReorderableSongRow(
                    index: index,
                    song: _songs[index],
                    onReorder: _onReorder,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({required this.songCount});

  final int songCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5C6BC0), Color(0xFFAB47BC)],
            ),
          ),
          child: const Icon(
            Icons.queue_music_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAYLIST',
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              Text(
                'Road Trip Mix',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$songCount songs · 1 hr 32 min · Drag to reorder',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play'),
        ),
        const SizedBox(width: 12),
        IconButton.outlined(
          onPressed: () {},
          icon: const Icon(Icons.shuffle_rounded),
        ),
      ],
    );
  }
}

class _ReorderableSongRow extends StatefulWidget {
  const _ReorderableSongRow({
    required this.index,
    required this.song,
    required this.onReorder,
  });

  final int index;
  final _Song song;
  final void Function(int draggedIndex, int insertBeforeIndex) onReorder;

  @override
  State<_ReorderableSongRow> createState() => _ReorderableSongRowState();
}

class _ReorderableSongRowState extends State<_ReorderableSongRow> {
  bool _dropAbove = false;
  bool _dropBelow = false;

  void _onMove(DragTargetDetails<int> details) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(details.offset);
    final half = box.size.height / 2;
    setState(() {
      _dropAbove = local.dy < half;
      _dropBelow = local.dy >= half;
    });
  }

  void _clearIndicators() {
    setState(() {
      _dropAbove = false;
      _dropBelow = false;
    });
  }

  void _onAccept(DragTargetDetails<int> details) {
    final insertAt = _dropBelow ? widget.index + 1 : widget.index;
    _clearIndicators();
    widget.onReorder(details.data, insertAt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<int>(
      onAcceptWithDetails: _onAccept,
      onMove: _onMove,
      onLeave: (_) => _clearIndicators(),
      builder: (context, candidateData, rejectedData) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DropLine(visible: _dropAbove, color: theme.colorScheme.primary),
            AutoScrollDraggable<int>(
              data: widget.index,
              feedback: _SongDragFeedback(song: widget.song),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _SongTile(index: widget.index, song: widget.song),
              ),
              child: _SongTile(index: widget.index, song: widget.song),
            ),
            _DropLine(visible: _dropBelow, color: theme.colorScheme.primary),
          ],
        );
      },
    );
  }
}

class _DropLine extends StatelessWidget {
  const _DropLine({required this.visible, required this.color});

  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(height: 3);
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({required this.index, required this.song});

  final int index;
  final _Song song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _AlbumArt(artIndex: song.artIndex),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            song.duration,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 20),
          Icon(Icons.drag_handle_rounded, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.artIndex, this.size = 48});

  final int artIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = _artGradients[artIndex % _artGradients.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}

class _SongDragFeedback extends StatelessWidget {
  const _SongDragFeedback({required this.song});

  final _Song song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _AlbumArt(artIndex: song.artIndex, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.drag_handle_rounded, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
