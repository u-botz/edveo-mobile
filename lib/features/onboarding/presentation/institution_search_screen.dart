import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/institution_repository.dart';

class InstitutionSearchScreen extends ConsumerStatefulWidget {
  const InstitutionSearchScreen({super.key});

  @override
  ConsumerState<InstitutionSearchScreen> createState() =>
      _InstitutionSearchScreenState();
}

class _InstitutionSearchScreenState
    extends ConsumerState<InstitutionSearchScreen> {
  final _controller = TextEditingController();
  List<InstitutionResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() { _results = []; _error = null; });
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final repo = ref.read(institutionRepositoryProvider);
      final results = await repo.search(query.trim());
      setState(() { _results = results; });
    } catch (e) {
      setState(() { _error = 'Search failed. Please try again.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find your institution')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Type institution name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final institution = _results[index];
                return ListTile(
                  leading: institution.logoUrl != null
                      ? Image.network(institution.logoUrl!, width: 40, height: 40)
                      : const Icon(Icons.school),
                  title: Text(institution.name),
                  subtitle: Text(institution.city),
                  onTap: () {
                    context.go('/login', extra: institution.slug);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
