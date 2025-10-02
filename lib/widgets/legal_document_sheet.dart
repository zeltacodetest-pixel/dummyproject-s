import 'package:flutter/material.dart';

class LegalDocumentSheet extends StatefulWidget {
  const LegalDocumentSheet({
    super.key,
    required this.title,
    required this.loader,
  });

  final String title;
  final Future<String> Function() loader;

  @override
  State<LegalDocumentSheet> createState() => _LegalDocumentSheetState();
}

class _LegalDocumentSheetState extends State<LegalDocumentSheet> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _retry() {
    setState(() {
      _future = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'We couldn\'t load this right now.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('Try again'),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: Text(
                    snapshot.data ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
