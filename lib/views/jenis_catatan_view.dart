import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/jenis_catatan_view_model.dart';
import '../models/jenis_catatan_model.dart';
import 'widgets/glass_container.dart';

class JenisCatatanView extends StatefulWidget {
  const JenisCatatanView({super.key});

  @override
  State<JenisCatatanView> createState() => _JenisCatatanViewState();
}

class _JenisCatatanViewState extends State<JenisCatatanView> {
  String selectedTipe = 'pelanggaran';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JenisCatatanViewModel>(context, listen: false).fetchJenisCatatan(selectedTipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JenisCatatanViewModel>(context);
    final activeColor = selectedTipe == 'prestasi' ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              title: const Text(
                "ZiePoint - Jenis Catatan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              backgroundColor: const Color(0xFFEFF2FF).withValues(alpha: 0.7),
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
                color: activeColor.withValues(alpha: 0.08),
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
                const SizedBox(height: 12),
                _buildFilterButtons(viewModel),
                const SizedBox(height: 12),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                          ),
                        )
                      : _buildList(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showFormDialog(context, viewModel),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(JenisCatatanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChip(vm, 'pelanggaran', 'Pelanggaran', Icons.gavel_rounded, const Color(0xFFFF2E93)),
          const SizedBox(width: 14),
          _buildChip(vm, 'prestasi', 'Apresiasi/Prestasi', Icons.star_rounded, const Color(0xFF00FF87)),
        ],
      ),
    );
  }

  Widget _buildChip(
    JenisCatatanViewModel vm,
    String value,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = selectedTipe == value;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTipe = value);
        vm.fetchJenisCatatan(value);
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            const SizedBox(width: 8),
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

  Widget _buildList(JenisCatatanViewModel vm) {
    final activeColor = selectedTipe == 'prestasi' ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

    if (vm.listData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_outlined, size: 56, color: Colors.white.withValues(alpha: 0.25)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: vm.listData.length,
      itemBuilder: (context, index) {
        final item = vm.listData[index];
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          color: Colors.white.withValues(alpha: 0.03),
          borderColor: Colors.white.withValues(alpha: 0.08),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: activeColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  '${item.poin}',
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            title: Text(
              item.nama, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item.deskripsi, 
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55), height: 1.3),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF2E93), size: 22),
              onPressed: () => _konfirmasiHapus(context, vm, item),
            ),
            onTap: () => _showFormDialog(context, vm, item: item),
          ),
        );
      },
    );
  }

  void _konfirmasiHapus(BuildContext context, JenisCatatanViewModel vm, JenisCatatan item) {
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFF2E93),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text("Hapus Data?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            "Apakah kamu yakin ingin menghapus '${item.nama}'? Tindakan ini permanen.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Batal", style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E93),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await vm.deleteData(item.idJenis, selectedTipe);
                Navigator.pop(context);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Color(0xFFFF2E93))
                );
              },
              child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, JenisCatatanViewModel vm, {JenisCatatan? item}) {
    final namaController = TextEditingController(text: item?.nama ?? '');
    final descController = TextEditingController(text: item?.deskripsi ?? '');
    final poinController = TextEditingController(text: item?.poin.toString() ?? '');

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
          title: Text(
            item == null ? "Tambah Kategori Poin" : "Edit Kategori Poin",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(namaController, "Nama Kategori", Icons.label_important_outline_rounded),
              const SizedBox(height: 12),
              _buildDialogField(descController, "Deskripsi", Icons.description_outlined),
              const SizedBox(height: 12),
              _buildDialogField(poinController, "Jumlah Poin", Icons.pin_rounded, keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Batal", style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))
            ),
            ElevatedButton(
              onPressed: () async {
                if (namaController.text.trim().isEmpty || poinController.text.trim().isEmpty) return;
                final newItem = JenisCatatan(
                  idJenis: item?.idJenis ?? 0,
                  nama: namaController.text.trim(),
                  deskripsi: descController.text.trim(),
                  tipe: selectedTipe,
                  poin: int.parse(poinController.text.trim()),
                );
                if (item == null) {
                  await vm.addData(newItem);
                } else {
                  await vm.updateData(item.idJenis, newItem);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.45), size: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}