import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package0:cloud_firestore/cloud_firestore.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final titleController = TextEditingController();
  final createController = TextEditingController();

  String? editingId;
  final inlineTitleController = TextEditingController();
  final inlineController = TextEditingController();
  final inlineFocus = FocusNode();

  bool loading = false;
  String? message;

  CollectionReference<Map<String, dynamic>> get _col {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes');
  }

  @override
  void dispose() {
    titleController.dispose();
    createController.dispose();
    inlineTitleController.dispose();
    inlineController.dispose();
    inlineFocus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = titleController.text.trim();
    final text = createController.text.trim();

    if (text.isEmpty) {
      setState(() => message = 'Preencha a descrição.');
      return;
    }

    setState(() {
      loading = true;
      message = null;
    });

    try {
      await _col.add({
        'title': title.isEmpty ? 'Sem Título' : title,
        'description': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      titleController.clear();
      createController.clear();
    } catch (e) {
      setState(() => message = 'Erro: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _startInlineEdit(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    setState(() {
      editingId = doc.id;
      inlineTitleController.text = (data?['title'] ?? '').toString();
      inlineController.text = (data?['description'] ?? '').toString();
    });
    Future.microtask(() => inlineFocus.requestFocus());
  }

  void _cancelInlineEdit() {
    setState(() {
      editingId = null;
      inlineTitleController.clear();
      inlineController.clear();
      inlineFocus.unfocus();
    });
  }

  Future<void> _commitInlineEdit(String docId) async {
    final newTitle = inlineTitleController.text.trim();
    final newText = inlineController.text.trim();

    if (newText.isEmpty) {
      setState(() => message = 'A descrição não pode ser vazia.');
      return;
    }

    try {
      await _col.doc(docId).update({
        'title': newTitle.isEmpty ? 'Sem Título' : newTitle,
        'description': newText,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _cancelInlineEdit();
    } catch (e) {
      setState(() => message = 'Erro ao atualizar: $e');
    }
  }

  Future<void> _remove(String docId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover nota'),
        content: const Text('Tem certeza que deseja remover esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _col.doc(docId).delete();
      if (editingId == docId) _cancelInlineEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Anotações'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título (opcional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: createController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: loading ? null : _add,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Nota'),
                      ),
                    ),
                  ],
                ),
              ),
              if (loading) const CircularProgressIndicator(),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _col
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma nota cadastrada.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        final isEditing = editingId == doc.id;

                        if (isEditing) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: inlineTitleController,
                                    focusNode: inlineFocus,
                                    decoration: const InputDecoration(
                                      labelText: 'Editar título',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: inlineController,
                                    decoration: const InputDecoration(
                                      labelText: 'Editar descrição',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (_) =>
                                        _commitInlineEdit(doc.id),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: _cancelInlineEdit,
                                        child: const Text('Cancelar'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _commitInlineEdit(doc.id),
                                        child: const Text('Salvar'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              (data['title'] ?? 'Sem Título').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              (data['description'] ?? '').toString(),
                            ),
                            onTap: () => _startInlineEdit(doc),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Remover',
                              onPressed: () => _remove(doc.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}