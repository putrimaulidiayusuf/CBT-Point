import 'package:flutter/material.dart';
import '../../models/jenis_catatan_model.dart';
import '../widgets/search_field.dart';

/// Halaman detail untuk melihat daftar poin apresiasi atau pelanggaran
class DaftarPoinSiswaView extends StatefulWidget {
  final String title;
  final List<JenisCatatan> items;
  final Color themeColor;

  const DaftarPoinSiswaView({
    super.key,
    required this.title,
    required this.items,
    required this.themeColor,
  });

  @override
  State<DaftarPoinSiswaView> createState() => _DaftarPoinSiswaViewState();
}

class _DaftarPoinSiswaViewState extends State<DaftarPoinSiswaView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.nama.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query) ||
          item.poin.toString().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: widget.themeColor.withValues(alpha: 0.1),
        foregroundColor: widget.themeColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchField(
              controller: _searchController,
              hintText: 'Cari jenis poin di sini...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
          ),

          // Items List
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Poin tidak ditemukan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba cari dengan kata kunci lain.',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: widget.themeColor.withValues(alpha: 0.1),
                            child: Text(
                              '${item.poin}',
                              style: TextStyle(
                                color: widget.themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            item.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              item.deskripsi,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                          onTap: () => _showDetailPoin(context, item, widget.themeColor),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetailPoin(BuildContext context, JenisCatatan item, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                '${item.poin}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(item.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Nama', item.nama),
            _detailRow('Detail', item.deskripsi),
            _detailRow('Kategori', item.tipe == 'prestasi' ? 'Apresiasi' : 'Pelanggaran'),
            _detailRow('Poin', item.poin.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}
