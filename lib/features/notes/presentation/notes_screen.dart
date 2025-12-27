import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:offline_khatabook/core/constants/app_colors.dart';
import 'package:offline_khatabook/core/widgets/common_widgets.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final List<_NoteData> _notes = [
    _NoteData(
      content: 'Follow up with Rahul about the pending payment of ₹5,000',
      color: const Color(0xFFFEF3C7),
      isPinned: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _NoteData(
      content: 'Meeting scheduled with Priya on Monday to discuss bulk order',
      color: const Color(0xFFDBEAFE),
      isPinned: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _NoteData(
      content: 'Need to update GST details for the new quarter',
      color: const Color(0xFFD1FAE5),
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _NoteData(
      content: 'Reminder: Bank holiday next week, plan payments accordingly',
      color: const Color(0xFFFEE2E2),
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    _NoteData(
      content: 'Stock inventory check due this weekend',
      color: const Color(0xFFF3E8FF),
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pinnedNotes = _notes.where((n) => n.isPinned).toList();
    final otherNotes = _notes.where((n) => !n.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: _notes.isEmpty
          ? EmptyStateWidget(
              icon: Icons.note_alt_outlined,
              title: 'No Notes Yet',
              subtitle: 'Add quick notes for your business reminders',
              buttonText: 'Add Note',
              onButtonPressed: () => _showAddNoteDialog(context),
            )
          : CustomScrollView(
              slivers: [
                // Pinned Notes
                if (pinnedNotes.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          Gap(8),
                          Text(
                            'Pinned',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _NoteCard(
                          note: pinnedNotes[index],
                          onTap: () => _editNote(pinnedNotes[index]),
                          onPin: () => _togglePin(pinnedNotes[index]),
                          onDelete: () => _deleteNote(pinnedNotes[index]),
                        ),
                        childCount: pinnedNotes.length,
                      ),
                    ),
                  ),
                ],

                // Other Notes
                if (otherNotes.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        pinnedNotes.isNotEmpty ? 24 : 16,
                        16,
                        8,
                      ),
                      child: const Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _NoteCard(
                          note: otherNotes[index],
                          onTap: () => _editNote(otherNotes[index]),
                          onPin: () => _togglePin(otherNotes[index]),
                          onDelete: () => _deleteNote(otherNotes[index]),
                        ),
                        childCount: otherNotes.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: Gap(100)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddNoteSheet(
        onSave: (content, color) {
          setState(() {
            _notes.insert(
              0,
              _NoteData(
                content: content,
                color: color,
                isPinned: false,
                createdAt: DateTime.now(),
              ),
            );
          });
        },
      ),
    );
  }

  void _editNote(_NoteData note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddNoteSheet(
        initialContent: note.content,
        initialColor: note.color,
        isEdit: true,
        onSave: (content, color) {
          setState(() {
            final index = _notes.indexOf(note);
            if (index != -1) {
              _notes[index] = _NoteData(
                content: content,
                color: color,
                isPinned: note.isPinned,
                createdAt: note.createdAt,
              );
            }
          });
        },
      ),
    );
  }

  void _togglePin(_NoteData note) {
    setState(() {
      final index = _notes.indexOf(note);
      if (index != -1) {
        _notes[index] = _NoteData(
          content: note.content,
          color: note.color,
          isPinned: !note.isPinned,
          createdAt: note.createdAt,
        );
      }
    });
  }

  void _deleteNote(_NoteData note) {
    setState(() {
      _notes.remove(note);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notes.add(note);
            });
          },
        ),
      ),
    );
  }
}

class _NoteData {
  final String content;
  final Color color;
  final bool isPinned;
  final DateTime createdAt;

  _NoteData({
    required this.content,
    required this.color,
    required this.isPinned,
    required this.createdAt,
  });
}

class _NoteCard extends StatelessWidget {
  final _NoteData note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: note.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(note.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onPin,
                          child: Icon(
                            note.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            size: 16,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          onTap: onDelete,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}

class _AddNoteSheet extends StatefulWidget {
  final String? initialContent;
  final Color? initialColor;
  final bool isEdit;
  final Function(String content, Color color) onSave;

  const _AddNoteSheet({
    this.initialContent,
    this.initialColor,
    this.isEdit = false,
    required this.onSave,
  });

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  late TextEditingController _contentController;
  late Color _selectedColor;

  final List<Color> _colorOptions = [
    const Color(0xFFFEF3C7), // Amber
    const Color(0xFFDBEAFE), // Blue
    const Color(0xFFD1FAE5), // Green
    const Color(0xFFFEE2E2), // Red
    const Color(0xFFF3E8FF), // Purple
    const Color(0xFFCFFAFE), // Cyan
    const Color(0xFFFCE7F3), // Pink
    const Color(0xFFF5F5F5), // Gray
  ];

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
    _selectedColor = widget.initialColor ?? _colorOptions[0];
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _selectedColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEdit ? 'Edit Note' : 'New Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black.withOpacity(0.5)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(16),

            // Content Input
            TextField(
              controller: _contentController,
              maxLines: 5,
              autofocus: true,
              style: TextStyle(color: Colors.black.withOpacity(0.8)),
              decoration: InputDecoration(
                hintText: 'Write your note here...',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Gap(16),

            // Color Picker
            Text(
              'Color',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 12,
              children: _colorOptions
                  .map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 2,
                                )
                              : Border.all(
                                  color: Colors.black.withOpacity(0.1),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _selectedColor == color
                            ? Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.black.withOpacity(0.5),
                              )
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Gap(24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_contentController.text.trim().isNotEmpty) {
                    widget.onSave(
                      _contentController.text.trim(),
                      _selectedColor,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.isEdit ? 'Note updated!' : 'Note created!',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.isEdit ? 'Update Note' : 'Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
