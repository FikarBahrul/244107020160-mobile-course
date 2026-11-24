import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../../../core/validate.dart';
import '../../../../routes.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  bool forceOffline = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showEditor({Note? note}) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => _NoteEditorDialog(note: note),
    );
    if (!mounted || result == null) return;
    if (note == null) {
      await ref
          .read(notesProvider.notifier)
          .add(title: result.$1, body: result.$2);
    } else if (note.id != null) {
      await ref
          .read(notesProvider.notifier)
          .updateNote(id: note.id!, title: result.$1, body: result.$2);
    }
  }

  Future<void> _sync() async {
    final count = await ref.read(notesProvider.notifier).sync();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 0
              ? 'Tidak ada catatan dalam antrean.'
              : '$count catatan tersinkron.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(filteredNotesProvider);
    final searchEmpty = ref.watch(
      searchQueryProvider.select((query) => query.isEmpty),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: 'Asisten AI',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            tooltip: 'Jelajah post',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.posts),
            icon: const Icon(Icons.photo_library_outlined),
          ),
          IconButton(
            tooltip: 'Sinkronisasi',
            onPressed: forceOffline ? null : _sync,
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile.adaptive(
            value: forceOffline,
            onChanged: (value) => setState(() => forceOffline = value),
            title: Text(
              forceOffline ? 'Mode offline aktif' : 'Mode online aktif',
            ),
            subtitle: Text(
              forceOffline
                  ? 'Catatan dibaca dari penyimpanan lokal'
                  : 'Sinkronisasi simulasi tersedia',
            ),
            secondary: Icon(
              forceOffline ? Icons.cloud_off : Icons.cloud_done,
              color: forceOffline ? Colors.orange : Colors.green,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).updateQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari judul catatan',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(searchQueryProvider.notifier)
                              .updateQuery('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: FilledButton.icon(
                  onPressed: () => ref.invalidate(notesProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text('Gagal memuat: $error'),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const _EmptyNotes()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: items.length,
                      itemBuilder: (context, index) => RepaintBoundary(
                        child: NoteTile(
                          note: items[index],
                          onEdit: () => _showEditor(note: items[index]),
                          onDelete: () => ref
                              .read(notesProvider.notifier)
                              .remove(items[index].id!),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-note-fab'),
        onPressed: () => _showEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }
}

class _NoteEditorDialog extends StatefulWidget {
  const _NoteEditorDialog({this.note});

  final Note? note;

  @override
  State<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<_NoteEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _bodyController = TextEditingController(text: widget.note?.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    final error = validateNoteTitle(_titleController.text);
    if (error != null) {
      setState(() => _titleError = error);
      return;
    }
    Navigator.pop(context, (
      _titleController.text.trim(),
      _bodyController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Catatan baru' : 'Edit catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('note-title-field'),
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Judul',
              errorText: _titleError,
            ),
          ),
          TextField(
            controller: _bodyController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Isi catatan'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('save-note-button'),
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onEdit,
        title: Text(note.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.body.isEmpty ? 'Tanpa isi' : note.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Diperbarui ${formatDateTime(note.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        leading: CircleAvatar(child: Text('${note.id ?? '-'}')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.dirty)
              const Tooltip(
                message: 'Belum tersinkron',
                child: Chip(
                  avatar: Icon(Icons.sync_problem, size: 16),
                  label: Text('dirty'),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotes extends ConsumerWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyword = ref.watch(
      searchQueryProvider.select((query) => query.trim()),
    );
    final searching = keyword.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searching ? Icons.search_off : Icons.note_alt_outlined,
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(searching ? 'Catatan tidak ditemukan' : 'Belum ada catatan'),
          Text(
            searching
                ? 'Tidak ada judul yang cocok dengan "$keyword".'
                : 'Tambahkan catatan untuk mulai bekerja offline.',
          ),
        ],
      ),
    );
  }
}
