import 'package:flutter/material.dart';
import '../../client/rest_client.dart'; 
import '../../service/post_service.dart';
import '../../models/post.dart'; 

class ApiPostsScreen extends StatefulWidget {
  const ApiPostsScreen({super.key});

  @override
  State<ApiPostsScreen> createState() => _ApiPostsScreenState();
}

class _ApiPostsScreenState extends State<ApiPostsScreen> {
  // --- INI ADALAH LAPISAN SERVICE ---
  late final RestClient _client;
  late final PostService _service;
  List<Post> _posts = [];
  bool _loading = false;
  // --- END SERVICE ---

  @override
  void initState() {
    super.initState();
    // Inisialisasi Klien dan Service
    _client = RestClient(baseUrl: 'https://jsonplaceholder.typicode.com'); 
    _service = PostService(_client);
    _loadPosts();
  }

  // Metode READ (GET ALL)
  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      // Panggil PostService untuk list data
      final posts = await _service.list(limit: 20);
      if (!mounted) return;
      setState(() => _posts = posts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat postingan: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Metode CREATE (POST)
  Future<void> _showCreateDialog() async {
    final titleCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Postingan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                controller: bodyCtl,
                decoration: const InputDecoration(labelText: 'Isi Postingan'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Isi wajib diisi' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Buat objek Post (dengan ID dummy 101, user 1)
      final post = Post(
        userId: 1, 
        title: titleCtl.text,
        body: bodyCtl.text,
      );
      
      // Tambahkan ke list lokal dulu (Optimistic UI)
      setState(() => _posts.insert(0, post));
      
      try {
        final created = await _service.create(post); // PANGGIL SERVICE UNTUK POST
        if (!mounted) return;
        
        // Update item lokal dengan data lengkap (ID dari server)
        setState(() => _posts[0] = created);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post berhasil ditambahkan')));
      } catch (e) {
        if (!mounted) return;
        // Hapus item lokal jika POST gagal
        setState(() => _posts.removeAt(0));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah post: $e')));
      }
    }
  }

  // Metode DELETE
  Future<void> _deletePost(int index) async {
    final id = _posts[index].id;
    if (id == null) {
      setState(() => _posts.removeAt(index));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Postingan'),
        content: const Text('Apakah Anda yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _posts.removeAt(index));
      try {
        await _service.delete(id); // PANGGIL SERVICE UNTUK DELETE
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post berhasil dihapus')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  @override
  void dispose() {
    _client.close(); // Penting: Menutup klien HTTP
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(icon: const Icon(Icons.arrow_back_rounded), color: Colors.white, onPressed: () => Navigator.pop(context)),
                    ),
                    const Text('API Test - Postingan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(icon: const Icon(Icons.refresh_rounded), color: Colors.white, onPressed: _loadPosts),
                    ),
                  ],
                ),
              ),

              // Body Daftar Postingan
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    //color: Colors.grey.shade100, // Mengubah warna keabu-abuan
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _posts.isEmpty
                          ? const Center(child: Text('Belum ada postingan', style: TextStyle(fontSize: 16, color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _posts.length,
                              itemBuilder: (context, index) {
                                final post = _posts[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        post.body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                      onPressed: () => _deletePost(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
      // FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF667eea),
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}