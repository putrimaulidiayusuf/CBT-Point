import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/jenis_catatan_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/search_field.dart';
import '../widgets/glass_container.dart';

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
    final color = poin.tipe == 'prestasi' ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

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
                'Tambah Penerima Poin',
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
                color: color.withValues(alpha: 0.08),
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
                // Info poin yang dipilih
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: color.withValues(alpha: 0.05),
                    borderColor: color.withValues(alpha: 0.2),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              '${poin.poin}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                              const SizedBox(height: 2),
                              Text(
                                poin.deskripsi,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: color.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            poin.tipe == 'prestasi' ? 'Apresiasi' : 'Pelanggaran',
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Daftar penerima yang sudah dipilih
                if (guruVm.selectedSiswa.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      children: [
                        const Text(
                          'Penerima Terpilih',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${guruVm.selectedSiswa.length}',
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: guruVm.selectedSiswa.length,
                      itemBuilder: (context, index) {
                        final siswa = guruVm.selectedSiswa[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => guruVm.removeSiswaPenerima(siswa),
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              borderRadius: 30,
                              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                              borderColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                              child: Row(
                                children: [
                                  Text(
                                    '${siswa.nama} (${siswa.kelas})',
                                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.close_rounded, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                                ],
                              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Cari nama, kelas, atau NIS siswa...',
                    onChanged: _search,
                  ),
                ),
                const SizedBox(height: 14),

                // Hasil search
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final siswa = _searchResults[index];
                      final isSelected = guruVm.selectedSiswa.contains(siswa);
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        color: isSelected 
                            ? const Color(0xFF6C63FF).withValues(alpha: 0.08) 
                            : Colors.white.withValues(alpha: 0.03),
                        borderColor: isSelected 
                            ? const Color(0xFF6C63FF).withValues(alpha: 0.3) 
                            : Colors.white.withValues(alpha: 0.08),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected
                                ? const Color(0xFF6C63FF).withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.08),
                            child: Icon(
                              isSelected ? Icons.check_rounded : Icons.person_rounded,
                              size: 18,
                              color: isSelected ? const Color(0xFF6C63FF) : Colors.white70,
                            ),
                          ),
                          title: Text(
                            siswa.nama, 
                            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                          subtitle: Text(
                            '${siswa.kelas}  •  NIS: ${siswa.nis}',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
                          ),
                          onTap: () {
                            if (isSelected) {
                              guruVm.removeSiswaPenerima(siswa);
                            } else {
                              guruVm.addSiswaPenerima(siswa);
                            }
                          },
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6C63FF), size: 24)
                              : Icon(Icons.add_circle_outline_rounded, color: Colors.white.withValues(alpha: 0.35), size: 24),
                        ),
                      );
                    },
                  ),
                ),

                // Tombol aksi di bawah
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0C29).withValues(alpha: 0.8),
                        border: Border(
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                        ),
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
                                          content: Text('Draf berhasil disimpan!'),
                                          backgroundColor: Color(0xFF6C63FF),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text('Simpan Draf', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: const Color(0xFF6C63FF),
                                side: BorderSide(
                                  color: guruVm.selectedSiswa.isEmpty 
                                      ? Colors.white.withValues(alpha: 0.1) 
                                      : const Color(0xFF6C63FF),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: guruVm.selectedSiswa.isEmpty
                                  ? null
                                  : () async {
                                      await guruVm.berikanPoinKeSemuaSiswa();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Poin berhasil dicatat & diberikan!'),
                                          backgroundColor: color,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                              label: const Text('Berikan Poin', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                                disabledForegroundColor: Colors.white.withValues(alpha: 0.25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
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
