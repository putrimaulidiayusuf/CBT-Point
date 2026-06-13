import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/jenis_catatan_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/search_field.dart';

/// Halaman tambah penerima poin
/// Fitur: search siswa (nama/kelas/NIS), scan QR, daftar penerima
/// Tombol: Simpan Draft, Berikan Poin

class TambahPenerimaView extends StatefulWidget {
  final JenisCatatan selectedPoin;

  const TambahPenerimaView({super.key, required this.selectedPoin});

  @override
  State<TambahPenerimaView> createState() => _TambahPenerimaViewState();
}

class _TambahPenerimaViewState extends State<TambahPenerimaView> {
  final _searchController = TextEditingController();
  List<Siswa> _searchResults = [];

  @override
  void initState() {
    super.initState();
    final guruVm = Provider.of<GuruViewModel>(context, listen: false);
    guruVm.selectPoin(widget.selectedPoin);
    _searchResults = guruVm.getAllSiswa();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    final guruVm = Provider.of<GuruViewModel>(context, listen: false);
    setState(() {
      _searchResults = guruVm.searchSiswa(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);
    final poin = widget.selectedPoin;
    final color = poin.tipe == 'prestasi' ? const Color(0xFF4CAF50) : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Penerima'),
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info poin yang dipilih
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    '${poin.poin}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poin.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        poin.deskripsi,
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    poin.tipe == 'prestasi' ? 'Apresiasi' : 'Pelanggaran',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Daftar penerima yang sudah dipilih
          if (guruVm.selectedSiswa.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Penerima',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${guruVm.selectedSiswa.length}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: guruVm.selectedSiswa.length,
                itemBuilder: (context, index) {
                  final siswa = guruVm.selectedSiswa[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        '${siswa.nama} (${siswa.kelas})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => guruVm.removeSiswaPenerima(siswa),
                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                      side: BorderSide(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Search siswa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(
              controller: _searchController,
              hintText: 'Cari siswa (nama, kelas, NIS)...',
              onChanged: _search,
            ),
          ),
          const SizedBox(height: 8),

          // Hasil search
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final siswa = _searchResults[index];
                final isSelected = guruVm.selectedSiswa.contains(siswa);
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: isSelected
                          ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      child: Icon(
                        isSelected ? Icons.check : Icons.person,
                        size: 18,
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
                      ),
                    ),
                    title: Text(siswa.nama, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '${siswa.kelas} • NIS: ${siswa.nis}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    onTap: () {
                      if (isSelected) {
                        guruVm.removeSiswaPenerima(siswa);
                      } else {
                        guruVm.addSiswaPenerima(siswa);
                      }
                    },
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 22)
                        : const Icon(Icons.add_circle_outline, color: Colors.grey, size: 22),
                  ),
                );
              },
            ),
          ),

          // Tombol aksi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: guruVm.selectedSiswa.isEmpty
                        ? null
                        : () async {
                            await guruVm.simpanDraft();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Draft berhasil disimpan!'),
                                backgroundColor: Color(0xFF6C63FF),
                              ),
                            );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Simpan Draft'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: guruVm.selectedSiswa.isEmpty
                        ? null
                        : () async {
                            await guruVm.berikanPoinKeSemuaSiswa();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Poin berhasil diberikan!'),
                                backgroundColor: color,
                              ),
                            );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Berikan Poin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
}
