import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/jenis_catatan_view_model.dart';
import '../models/jenis_catatan_model.dart';

class JenisCatatanView extends StatefulWidget {
  @override
  State<JenisCatatanView> createState() => _JenisCatatanViewState();
}

class _JenisCatatanViewState extends State<JenisCatatanView> {
  String selectedTipe = 'pelanggaran';

  @override
  void initState() {
    super.initState();
    // Ambil data pertama kali saat aplikasi dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JenisCatatanViewModel>(context, listen: false).fetchJenisCatatan(selectedTipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JenisCatatanViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("ZiePoint - Jenis Catatan")),
      body: Column(
        children: [
          _buildFilterButtons(viewModel),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildList(viewModel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, viewModel),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButtons(JenisCatatanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text("Pelanggaran"),
            selected: selectedTipe == 'pelanggaran',
            onSelected: (val) {
              setState(() => selectedTipe = 'pelanggaran');
              vm.fetchJenisCatatan('pelanggaran');
            },
          ),
          const SizedBox(width: 10),
          ChoiceChip(
            label: const Text("Prestasi"),
            selected: selectedTipe == 'prestasi',
            onSelected: (val) {
              setState(() => selectedTipe = 'prestasi');
              vm.fetchJenisCatatan('prestasi');
            },
          ),
        ],
      ),
    );
  }

Widget _buildList(JenisCatatanViewModel vm) {
  return ListView.builder(
    itemCount: vm.listData.length,
    itemBuilder: (context, index) {
      final item = vm.listData[index];
      return Card( // Pake Card biar lebih rapi
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.tipe == 'pelanggaran' ? Colors.red.shade100 : Colors.green.shade100,
            child: Text(
              item.poin.toString(),
              style: TextStyle(color: item.tipe == 'pelanggaran' ? Colors.red : Colors.green),
            ),
          ),
          title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.deskripsi),
          // INI TOMBOL DELETE NYA
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Kasih konfirmasi dulu biar gak sengaja kehapus
              _konfirmasiHapus(context, vm, item);
            },
          ),
          onTap: () => _showFormDialog(context, vm, item: item),
        ),
      );
    },
  );
}

// Tambahkan fungsi popup konfirmasi ini di bawahnya
void _konfirmasiHapus(BuildContext context, JenisCatatanViewModel vm, JenisCatatan item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Hapus Data?"),
      content: Text("Apakah kamu yakin ingin menghapus '${item.nama}'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Batal")
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await vm.deleteData(item.idJenis, selectedTipe);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data berhasil dihapus"))
            );
          },
          child: const Text("Hapus", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  void _showFormDialog(BuildContext context, JenisCatatanViewModel vm, {JenisCatatan? item}) {
    // Sederhananya kita buat dialog untuk input data
    final namaController = TextEditingController(text: item?.nama ?? '');
    final descController = TextEditingController(text: item?.deskripsi ?? '');
    final poinController = TextEditingController(text: item?.poin.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? "Tambah Data" : "Edit Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Deskripsi")),
            TextField(controller: poinController, decoration: const InputDecoration(labelText: "Poin"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final newItem = JenisCatatan(
                idJenis: item?.idJenis ?? 0,
                nama: namaController.text,
                deskripsi: descController.text,
                tipe: selectedTipe,
                poin: int.parse(poinController.text),
              );
              if (item == null) {
                await vm.addData(newItem);
              } else {
                await vm.updateData(item.idJenis, newItem);
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}