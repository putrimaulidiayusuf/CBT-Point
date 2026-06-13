import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/guru_view_model.dart';
import '../../models/point_record_model.dart';
import '../widgets/search_field.dart';
import '../widgets/glass_container.dart';

class GuruRiwayatView extends StatefulWidget {
  const GuruRiwayatView({super.key});

  @override
  State<GuruRiwayatView> createState() => _GuruRiwayatViewState();
}

class _GuruRiwayatViewState extends State<GuruRiwayatView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final guruVm = Provider.of<GuruViewModel>(context, listen: false);
      guruVm.setSearchQuery('');
      guruVm.setFilterJenis('semua');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              title: const Text(
                'Riwayat Pemberian Poin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
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
          // Background Glows
          Positioned(
            top: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F2FE).withValues(alpha: 0.08),
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
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Cari nama, kelas, NIS, atau poin...',
                    onChanged: (val) {
                      guruVm.setSearchQuery(val);
                    },
                    suffixIcon: guruVm.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.6)),
                            onPressed: () {
                              _searchController.clear();
                              guruVm.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),

                // Filter Chips
                _buildFilterChips(guruVm),

                // List Riwayat
                Expanded(
                  child: guruVm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF6C63FF),
                          backgroundColor: const Color(0xFF151233),
                          onRefresh: () => guruVm.refreshData(),
                          child: guruVm.riwayatPoin.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  itemCount: guruVm.riwayatPoin.length,
                                  itemBuilder: (context, index) {
                                    final record = guruVm.riwayatPoin[index];
                                    return _buildRiwayatCard(context, record, guruVm);
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(GuruViewModel vm) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip(vm, 'semua', 'Semua', Icons.grid_view_rounded, const Color(0xFF6C63FF)),
          const SizedBox(width: 10),
          _buildChip(vm, 'prestasi', 'Apresiasi', Icons.star_rounded, const Color(0xFF00FF87)),
          const SizedBox(width: 10),
          _buildChip(vm, 'pelanggaran', 'Pelanggaran', Icons.gavel_rounded, const Color(0xFFFF2E93)),
        ],
      ),
    );
  }

  Widget _buildChip(
    GuruViewModel vm,
    String value,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = vm.filterJenis == value;
    return GestureDetector(
      onTap: () => vm.setFilterJenis(value),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        borderRadius: 30,
        color: isSelected 
            ? activeColor.withValues(alpha: 0.25) 
            : Colors.white.withValues(alpha: 0.04),
        borderColor: isSelected 
            ? activeColor 
            : Colors.white.withValues(alpha: 0.1),
        boxShadow: isSelected ? [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.25),
            blurRadius: 10,
          )
        ] : [],
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history_rounded, size: 56, color: Colors.white.withValues(alpha: 0.25)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada riwayat pemberian poin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Coba gunakan filter lain atau catat poin baru.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatCard(
      BuildContext context, PointRecord record, GuruViewModel vm) {
    final isApresiasi = record.jenisPoin == 'prestasi';
    final color = isApresiasi ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showDetailDialog(context, record),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Poin Bulat
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  '${isApresiasi ? "+" : ""}${record.poin}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info Tengah
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.namaSiswa,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.kelasSiswa}  •  NIS: ${record.nisSiswa}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.namaPoin,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.detailPoin,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 6),
                      Text(
                        '${record.tanggal}  •  ${record.jam}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol Delete
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF2E93), size: 22),
              onPressed: () => _confirmDelete(context, record, vm),
              tooltip: 'Hapus riwayat',
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, PointRecord record) {
    final isApresiasi = record.jenisPoin == 'prestasi';
    final color = isApresiasi ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '${record.poin}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Detail Riwayat Poin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Siswa', record.namaSiswa),
              const Divider(color: Colors.white10),
              _detailRow('Kelas / NIS', '${record.kelasSiswa} / ${record.nisSiswa}'),
              const Divider(color: Colors.white10),
              _detailRow('Nama Poin', record.namaPoin),
              const Divider(color: Colors.white10),
              _detailRow('Deskripsi', record.detailPoin),
              const Divider(color: Colors.white10),
              _detailRow('Kategori', isApresiasi ? 'Apresiasi' : 'Pelanggaran'),
              const Divider(color: Colors.white10),
              _detailRow('Guru Catat', record.namaGuru),
              const Divider(color: Colors.white10),
              _detailRow('Waktu', '${record.tanggal} • ${record.jam}'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          const Text('  ', style: TextStyle(color: Colors.white30)),
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

  void _confirmDelete(BuildContext context, PointRecord record, GuruViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2E93).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF2E93), size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Hapus Riwayat?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan poin "${record.namaPoin}" untuk ${record.namaSiswa}? Tindakan ini akan mengembalikan poin siswa tersebut.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await vm.deleteRiwayat(record.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan riwayat berhasil dihapus'),
                    backgroundColor: Color(0xFFFF2E93),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E93),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
