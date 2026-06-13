import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/guru_view_model.dart';
import '../../models/point_record_model.dart';
import '../widgets/search_field.dart';

/// Tab Riwayat Guru
/// Menampilkan: Daftar riwayat pemberian poin oleh guru, fitur search multi-field, filter jenis, & delete
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
    // Reset filters on load
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
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Pemberian Poin',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchField(
              controller: _searchController,
              hintText: 'Cari nama siswa, kelas, NIS, atau poin...',
              onChanged: (val) {
                guruVm.setSearchQuery(val);
              },
              suffixIcon: guruVm.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
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
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => guruVm.refreshData(),
                    child: guruVm.riwayatPoin.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
    );
  }

  Widget _buildFilterChips(GuruViewModel vm) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(vm, 'semua', 'Semua', Icons.grid_view, const Color(0xFF302B63)),
          const SizedBox(width: 8),
          _buildChip(vm, 'prestasi', 'Apresiasi', Icons.star, const Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          _buildChip(vm, 'pelanggaran', 'Pelanggaran', Icons.gavel, Colors.redAccent),
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
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : activeColor.withValues(alpha: 0.7),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          vm.setFilterJenis(value);
        }
      },
      selectedColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Tidak ada riwayat pemberian poin',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba gunakan filter lain atau berikan poin baru.',
                style: TextStyle(
                  color: Colors.grey.shade400,
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
    final color = isApresiasi ? const Color(0xFF4CAF50) : Colors.redAccent;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetailDialog(context, record),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Poin Bulat
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Text(
                  '${isApresiasi ? "+" : ""}${record.poin}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      '${record.kelasSiswa} • NIS: ${record.nisSiswa}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withValues(alpha: 0.1)),
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
                          Text(
                            record.detailPoin,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${record.tanggal} • ${record.jam}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Delete
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(context, record, vm),
                tooltip: 'Hapus riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, PointRecord record) {
    final isApresiasi = record.jenisPoin == 'prestasi';
    final color = isApresiasi ? const Color(0xFF4CAF50) : Colors.redAccent;

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
                '${record.poin}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Detail Riwayat Poin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Siswa', record.namaSiswa),
            _detailRow('Kelas/NIS', '${record.kelasSiswa} / ${record.nisSiswa}'),
            _detailRow('Nama Poin', record.namaPoin),
            _detailRow('Deskripsi', record.detailPoin),
            _detailRow('Nilai Poin', '${isApresiasi ? "+" : ""}${record.poin} (${isApresiasi ? "Apresiasi" : "Pelanggaran"})'),
            _detailRow('Guru', record.namaGuru),
            _detailRow('Waktu', '${record.tanggal} pukul ${record.jam}'),
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
            width: 80,
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PointRecord record, GuruViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Riwayat'),
          ],
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus riwayat pemberian poin "${record.namaPoin}" untuk ${record.namaSiswa}? Tindakan ini akan mengembalikan poin siswa terkait.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteRiwayat(record.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat berhasil dihapus'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
