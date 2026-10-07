import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/providers.dart';
import 'settings_page.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  bool forceOffline = true;

  Future<void> _showEditor({Note? note}) async {
    final titleController = TextEditingController(text: note?.title);
    final bodyController = TextEditingController(text: note?.body);
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Catatan baru' : 'Edit catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
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
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(context, (title, bodyController.text.trim()));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    titleController.dispose();
    bodyController.dispose();
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
    final notes = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: 'Sinkronisasi',
            onPressed: forceOffline ? null : _sync,
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
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
                      itemBuilder: (context, index) => NoteTile(
                        note: items[index],
                        onEdit: () => _showEditor(note: items[index]),
                        onDelete: () => ref
                            .read(notesProvider.notifier)
                            .remove(items[index].id!),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
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
        subtitle: Text(
          note.body.isEmpty ? 'Tanpa isi' : note.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 64),
          SizedBox(height: 12),
          Text('Belum ada catatan'),
          Text('Tambahkan catatan untuk mulai bekerja offline.'),
        ],
      ),
    );
  }
}
