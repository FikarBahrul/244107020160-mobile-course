import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ai/ai_providers.dart';
import '../../../../ai/ai_service.dart';
import '../../../../ai/ai_service_provider.dart';

class AiKeyTile extends ConsumerStatefulWidget {
  const AiKeyTile({super.key});

  @override
  ConsumerState<AiKeyTile> createState() => _AiKeyTileState();
}

class _AiKeyTileState extends ConsumerState<AiKeyTile> {
  bool _busy = false;

  Future<void> _editKey() async {
    final service = ref.read(aiServiceProvider);
    final hasKey = await service.hasApiKey();
    if (!mounted) return;

    final controller = TextEditingController();
    var obscure = true;
    final action = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Kunci API Gemini'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'API key',
                  hintText: 'Tempelkan kunci dari Google AI Studio',
                  suffixIcon: IconButton(
                    tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
                    onPressed: () => setDialogState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kunci disimpan di flutter_secure_storage dan tidak ditulis '
                'ke kode sumber. Jangan kirim data pribadi ke AI.',
              ),
            ],
          ),
          actions: [
            if (hasKey)
              TextButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                child: const Text('Hapus'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) {
      controller.dispose();
      return;
    }

    if (action == 'delete') {
      await _run(() => service.deleteApiKey(), 'Kunci API dihapus.');
    } else if (action == 'save') {
      await _run(
        () => service.saveApiKey(controller.text),
        'Kunci API disimpan.',
      );
    }
    controller.dispose();
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(apiKeyStatusProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } on AiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(apiKeyStatusProvider);
    return ListTile(
      leading: const Icon(Icons.key_outlined),
      title: const Text('Kunci API Gemini'),
      subtitle: Text(
        status.when(
          loading: () => 'Memeriksa secure storage...',
          error: (error, stackTrace) => 'Gagal membaca kunci : $error',
          data: (hasKey) => hasKey
              ? 'Tersimpan aman di secure storage'
              : 'Belum diatur - fitur AI memakai mode lokal',
        ),
      ),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              tooltip: 'Atur kunci API',
              onPressed: _editKey,
              icon: const Icon(Icons.edit_outlined),
            ),
    );
  }
}
