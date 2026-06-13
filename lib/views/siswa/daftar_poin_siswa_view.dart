import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/jenis_catatan_model.dart';
import '../widgets/search_field.dart';
import '../widgets/glass_container.dart';

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
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              title: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F0C29).withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.themeColor.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Cari jenis poin...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.6)),
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
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.search_off_rounded, size: 56, color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Poin tidak ditemukan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Coba cari dengan kata kunci lain.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildItemCard(context, item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, JenisCatatan item) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: widget.themeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.themeColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '${item.poin}',
              style: TextStyle(
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          item.nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            item.deskripsi,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55), height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withValues(alpha: 0.35)),
        onTap: () => _showDetailPoin(context, item, widget.themeColor),
      ),
    );
  }

  void _showDetailPoin(BuildContext context, JenisCatatan item, Color color) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF151233).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '${item.poin}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.nama,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _detailRow('Nama', item.nama),
              const Divider(color: Colors.white10),
              _detailRow('Deskripsi', item.deskripsi),
              const Divider(color: Colors.white10),
              _detailRow('Kategori', item.tipe == 'prestasi' ? 'Apresiasi' : 'Pelanggaran'),
              const Divider(color: Colors.white10),
              _detailRow('Nilai Poin', '${item.poin} Poin'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
