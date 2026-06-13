import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../models/jenis_catatan_model.dart';
import '../../models/user_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/search_field.dart';
import '../widgets/glass_container.dart';

class GuruScanQrView extends StatefulWidget {
  const GuruScanQrView({super.key});

  @override
  State<GuruScanQrView> createState() => _GuruScanQrViewState();
}

class _GuruScanQrViewState extends State<GuruScanQrView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _searchController = TextEditingController();
  List<Siswa> _searchResults = [];
  bool _isScannerActive = true;

  String _scanStatus = 'Menunggu pemindaian kartu QR siswa...';
  bool? _scanSuccess;

  @override
  void dispose() {
    _scannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleQrDetected(String code, GuruViewModel vm) {
    final siswa = vm.getSiswaByNis(code.trim());
    setState(() {
      if (siswa != null) {
        if (vm.selectedSiswa.any((s) => s.nis == siswa.nis)) {
          _scanStatus = 'Siswa "${siswa.nama}" sudah terdaftar di penerima.';
          _scanSuccess = true;
        } else {
          vm.addSiswaPenerima(siswa);
          _scanStatus = 'Scan Berhasil! "${siswa.nama}" (${siswa.kelas}) ditambahkan.';
          _scanSuccess = true;
        }
      } else {
        _scanStatus = 'Scan Gagal! Kode QR "$code" tidak dikenal. Data tidak disimpan.';
        _scanSuccess = false;
      }
    });
  }

  void _searchSiswa(String query, GuruViewModel vm) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = vm.searchSiswa(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);
    final selectedPoin = guruVm.selectedPoin;
    final color = selectedPoin != null
        ? (selectedPoin.tipe == 'prestasi' ? const Color(0xFF00FF87) : const Color(0xFFFF2E93))
        : const Color(0xFF6C63FF);

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
                'Pemindai QR Code Siswa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F0C29).withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isScannerActive ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isScannerActive = !_isScannerActive;
                      if (_isScannerActive) {
                        _scannerController.start();
                      } else {
                        _scannerController.stop();
                      }
                    });
                  },
                  tooltip: 'Toggle Kamera',
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on_rounded, color: Color(0xFFFFB300)),
                  onPressed: () => _scannerController.toggleTorch(),
                  tooltip: 'Toggle Flashlight',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 100,
            left: -100,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Scanner Frame / Fallback
                  if (_isScannerActive)
                    Container(
                      height: 250,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              final String? rawValue = barcode.rawValue;
                              if (rawValue != null) {
                                _handleQrDetected(rawValue, guruVm);
                              }
                            }
                          },
                          errorBuilder: (context, error, child) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, color: Colors.white.withValues(alpha: 0.5), size: 48),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Kamera tidak dapat diakses',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Gunakan kolom pencarian di bawah di simulator.',
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    GlassContainer(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white.withValues(alpha: 0.03),
                      borderColor: Colors.white.withValues(alpha: 0.08),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off_rounded, size: 36, color: Colors.white54),
                            SizedBox(height: 6),
                            Text('Kamera dinonaktifkan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Indikator Status Scan
                  _buildScanStatusCard(),

                  // Search Bar untuk Pencarian Multi-Field
                  GlassContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    color: Colors.white.withValues(alpha: 0.03),
                    borderColor: Colors.white.withValues(alpha: 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cari Siswa Manual (Nama / Kelas / NIS)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        SearchField(
                          controller: _searchController,
                          hintText: 'Ketik nama, kelas, atau NIS...',
                          onChanged: (val) => _searchSiswa(val, guruVm),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.6)),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchSiswa('', guruVm);
                                  },
                                )
                              : null,
                        ),
                        if (_searchResults.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                          const SizedBox(height: 14),
                          Text(
                            'Hasil Pencarian (${_searchResults.length} siswa)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.45)),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final siswa = _searchResults[index];
                              final isSelected = guruVm.selectedSiswa.any((s) => s.nis == siswa.nis);
                              return GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    guruVm.removeSiswaPenerima(siswa);
                                  } else {
                                    guruVm.addSiswaPenerima(siswa);
                                  }
                                },
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(8.0),
                                  color: isSelected 
                                      ? const Color(0xFF6C63FF).withValues(alpha: 0.1) 
                                      : Colors.white.withValues(alpha: 0.02),
                                  borderColor: isSelected 
                                      ? const Color(0xFF6C63FF) 
                                      : Colors.white.withValues(alpha: 0.06),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              siswa.nama,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Kelas: ${siswa.kelas}',
                                              style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.55)),
                                            ),
                                            Text(
                                              'NIS: ${siswa.nis}',
                                              style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.55)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                        color: isSelected ? const Color(0xFF00FF87) : Colors.white24,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Poin Terpilih Selector
                  _buildPoinSelectorSection(context, guruVm, color),
                  const SizedBox(height: 16),

                  // Daftar Siswa Ter-scan
                  _buildScannedStudentsSection(context, guruVm),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context, guruVm, selectedPoin, color),
    );
  }

  Widget _buildScanStatusCard() {
    Color cardColor = Colors.white.withValues(alpha: 0.03);
    Color colorTheme = Colors.white.withValues(alpha: 0.45);
    IconData statusIcon = Icons.info_outline_rounded;

    if (_scanSuccess == true) {
      cardColor = const Color(0xFF00FF87).withValues(alpha: 0.05);
      colorTheme = const Color(0xFF00FF87);
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (_scanSuccess == false) {
      cardColor = const Color(0xFFFF2E93).withValues(alpha: 0.05);
      colorTheme = const Color(0xFFFF2E93);
      statusIcon = Icons.error_outline_rounded;
    }

    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: cardColor,
      borderColor: colorTheme.withValues(alpha: 0.2),
      child: Row(
        children: [
          Icon(statusIcon, color: colorTheme, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _scanStatus,
              style: TextStyle(
                fontSize: 12,
                color: colorTheme,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoinSelectorSection(BuildContext context, GuruViewModel vm, Color themeColor) {
    final selectedPoin = vm.selectedPoin;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Pilih Kategori Poin *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 12),
          if (selectedPoin != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${selectedPoin.poin}',
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedPoin.nama,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedPoin.deskripsi,
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: themeColor, size: 18),
                    onPressed: () => vm.resetSelectedPoin(),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showPoinSelectionDialog(context, vm),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                label: const Text('Pilih Poin Apresiasi / Pelanggaran', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPoinSelectionDialog(BuildContext context, GuruViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DefaultTabController(
            length: 2,
            child: AlertDialog(
              backgroundColor: const Color(0xFF151233).withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pilih Kategori Poin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  const TabBar(
                    labelColor: Color(0xFF6C63FF),
                    indicatorColor: Color(0xFF6C63FF),
                    unselectedLabelColor: Colors.white54,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'Apresiasi'),
                      Tab(text: 'Pelanggaran'),
                    ],
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: TabBarView(
                  children: [
                    // Apresiasi Tab
                    ListView.builder(
                      itemCount: vm.daftarApresiasi.length,
                      itemBuilder: (context, index) {
                        final item = vm.daftarApresiasi[index];
                        return _buildDialogItemTile(item, const Color(0xFF00FF87), vm);
                      },
                    ),
                    // Pelanggaran Tab
                    ListView.builder(
                      itemCount: vm.daftarPelanggaran.length,
                      itemBuilder: (context, index) {
                        final item = vm.daftarPelanggaran[index];
                        return _buildDialogItemTile(item, const Color(0xFFFF2E93), vm);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogItemTile(JenisCatatan item, Color color, GuruViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '+${item.poin}',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text(item.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(item.deskripsi, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () {
          vm.selectPoin(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildScannedStudentsSection(BuildContext context, GuruViewModel vm) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2. Daftar Penerima Poin *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              if (vm.selectedSiswa.isNotEmpty)
                TextButton(
                  onPressed: () => vm.clearSelectedSiswa(),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('Hapus Semua', style: TextStyle(color: Color(0xFFFF2E93), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (vm.selectedSiswa.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, size: 40, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Text(
                      'Pindai QR code siswa atau ketik di kolom manual.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.selectedSiswa.length,
              itemBuilder: (context, index) {
                final siswa = vm.selectedSiswa[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      child: const Icon(Icons.person_rounded, size: 16, color: Colors.white70),
                    ),
                    title: Text(siswa.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text('${siswa.kelas}  •  NIS: ${siswa.nis}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45))),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFFF2E93), size: 20),
                      onPressed: () => vm.removeSiswaPenerima(siswa),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
      BuildContext context, GuruViewModel vm, JenisCatatan? selectedPoin, Color themeColor) {
    final hasData = selectedPoin != null && vm.selectedSiswa.isNotEmpty;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  onPressed: !hasData
                      ? null
                      : () async {
                          await vm.simpanDraft();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draf berhasil disimpan!'),
                              backgroundColor: Color(0xFF6C63FF),
                            ),
                          );
                          setState(() {
                            _scanStatus = 'Menunggu pemindaian kartu QR siswa...';
                            _scanSuccess = null;
                          });
                        },
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Simpan Draf', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: !hasData 
                          ? Colors.white.withValues(alpha: 0.1) 
                          : const Color(0xFF6C63FF),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !hasData
                      ? null
                      : () async {
                          await vm.berikanPoinKeSemuaSiswa();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Poin berhasil dicatat & diberikan!'),
                              backgroundColor: themeColor,
                            ),
                          );
                          setState(() {
                            _scanStatus = 'Menunggu pemindaian kartu QR siswa...';
                            _scanSuccess = null;
                          });
                        },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Berikan Poin', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
