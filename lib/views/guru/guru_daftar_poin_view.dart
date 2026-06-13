import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/jenis_catatan_model.dart';
import '../widgets/search_field.dart';
import '../widgets/glass_container.dart';
import 'tambah_penerima_view.dart';

class GuruDaftarPoinView extends StatefulWidget {
  final String title;
  final List<JenisCatatan> items;
  final Color themeColor;

  const GuruDaftarPoinView({
    super.key,
    required this.title,
    required this.items,
    required this.themeColor,
  });

  @override
  State<GuruDaftarPoinView> createState() => _GuruDaftarPoinViewState();
}

class _GuruDaftarPoinViewState extends State<GuruDaftarPoinView> {
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
                    hintText: 'Cari kategori poin...',
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
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
                                'Kategori tidak ditemukan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                            return _buildPoinTile(context, item, widget.themeColor);
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

  Widget _buildPoinTile(BuildContext context, JenisCatatan item, Color color) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '${item.poin}',
              style: TextStyle(
                color: color,
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
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: color.withValues(alpha: 0.7),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahPenerimaView(selectedPoin: item),
            ),
          );
        },
      ),
    );
  }
}
