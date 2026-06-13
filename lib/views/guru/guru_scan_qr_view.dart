import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../models/jenis_catatan_model.dart';
import '../../view_models/guru_view_model.dart';

/// Tab Scan QR Guru
/// Fitur: scan QR code siswa (NIS), deteksi info siswa, pilih jenis poin,
/// scan beberapa siswa sekaligus, berikan poin langsung atau simpan draf.
/// Menyediakan fallback input manual jika kamera tidak tersedia.
class GuruScanQrView extends StatefulWidget {
  const GuruScanQrView({super.key});

  @override
  State<GuruScanQrView> createState() => _GuruScanQrViewState();
}

class _GuruScanQrViewState extends State<GuruScanQrView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _manualNisController = TextEditingController();
  bool _isScannerActive = true;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualNisController.dispose();
    super.dispose();
  }

  void _handleQrDetected(String code, GuruViewModel vm) {
    final siswa = vm.getSiswaByNis(code.trim());
    if (siswa != null) {
      if (vm.selectedSiswa.any((s) => s.nis == siswa.nis)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${siswa.nama} sudah ada di daftar penerima'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        vm.addSiswaPenerima(siswa);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menambahkan ${siswa.nama}'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Siswa dengan NIS "$code" tidak ditemukan'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);
    final selectedPoin = guruVm.selectedPoin;
    final color = selectedPoin != null
        ? (selectedPoin.tipe == 'prestasi' ? const Color(0xFF4CAF50) : Colors.redAccent)
        : const Color(0xFF302B63);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text(
          'Scan QR Code Siswa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _isScannerActive ? Icons.videocam_off_outlined : Icons.videocam_outlined,
              color: const Color(0xFF302B63),
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
            icon: const Icon(Icons.flash_on, color: Colors.amber),
            onPressed: () => _scannerController.toggleTorch(),
            tooltip: 'Toggle Flashlight',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scanner Frame / Fallback
            if (_isScannerActive)
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                              const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                'Kamera tidak dapat diakses',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gunakan input manual di bawah jika di simulator.',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                textAlign: Alignment.center as TextAlign?,
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
              Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off, size: 36, color: Colors.grey),
                      SizedBox(height: 6),
                      Text('Kamera dinonaktifkan', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),

            // Fallback Input Manual
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualNisController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Input NIS manual (e.g. 123456)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final nis = _manualNisController.text.trim();
                      if (nis.isNotEmpty) {
                        _handleQrDetected(nis, guruVm);
                        _manualNisController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF302B63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Poin Terpilih Selector
            _buildPoinSelectorSection(context, guruVm, color),
            const SizedBox(height: 20),

            // Daftar Siswa Ter-scan
            _buildScannedStudentsSection(context, guruVm),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context, guruVm, selectedPoin, color),
    );
  }

  Widget _buildPoinSelectorSection(BuildContext context, GuruViewModel vm, Color themeColor) {
    final selectedPoin = vm.selectedPoin;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Pilih Jenis Poin *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          if (selectedPoin != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: themeColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: themeColor.withValues(alpha: 0.15),
                    child: Text(
                      '${selectedPoin.poin}',
                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedPoin.nama,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeColor),
                        ),
                        Text(
                          selectedPoin.deskripsi,
                          style: TextStyle(fontSize: 11, color: themeColor.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: themeColor, size: 18),
                    onPressed: () => vm.resetSelectedPoin(),
                  ),
                ],
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _showPoinSelectionDialog(context, vm),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Pilih Poin Apresiasi / Pelanggaran'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
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
        return DefaultTabController(
          length: 2,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pilih Poin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TabBar(
                  labelColor: const Color(0xFF302B63),
                  indicatorColor: const Color(0xFF302B63),
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
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
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          child: Text('+${item.poin}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.deskripsi, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          vm.selectPoin(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  // Pelanggaran Tab
                  ListView.builder(
                    itemCount: vm.daftarPelanggaran.length,
                    itemBuilder: (context, index) {
                      final item = vm.daftarPelanggaran[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                          child: Text('-${item.poin}', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.deskripsi, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          vm.selectPoin(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScannedStudentsSection(BuildContext context, GuruViewModel vm) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2. Daftar Siswa Ter-scan *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (vm.selectedSiswa.isNotEmpty)
                TextButton(
                  onPressed: () => vm.clearSelectedSiswa(),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('Hapus Semua', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
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
                    Icon(Icons.qr_code_scanner, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 6),
                    Text(
                      'Pindai QR code siswa atau input manual di atas.',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
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
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  title: Text(siswa.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('${siswa.kelas} • NIS: ${siswa.nis}', style: const TextStyle(fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                    onPressed: () => vm.removeSiswaPenerima(siswa),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
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
                          content: Text('Berhasil menyimpan draft!'),
                          backgroundColor: Color(0xFF302B63),
                        ),
                      );
                    },
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Simpan Draft'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: !hasData
                  ? null
                  : () async {
                      await vm.berikanPoinKeSemuaSiswa();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Berhasil memberikan poin!'),
                          backgroundColor: themeColor,
                        ),
                      );
                    },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Berikan Poin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
