import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/guru_view_model.dart';
import '../../models/jenis_catatan_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/search_field.dart';
import '../login_view.dart';
import 'tambah_penerima_view.dart';

/// Tab Dashboard Guru
/// Menampilkan: Header Info Guru, Pencarian Jenis Poin, dan Daftar Apresiasi/Pelanggaran
class GuruDashboardView extends StatefulWidget {
  const GuruDashboardView({super.key});

  @override
  State<GuruDashboardView> createState() => _GuruDashboardViewState();
}

class _GuruDashboardViewState extends State<GuruDashboardView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final guruVm = Provider.of<GuruViewModel>(context);
    final guru = authVm.currentGuru;

    if (guru == null) {
      return const Scaffold(body: Center(child: Text('Data guru tidak ditemukan')));
    }

    // Filter list berdasarkan search query
    final filteredApresiasi = guruVm.daftarApresiasi.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.nama.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query) ||
          item.poin.toString().contains(query);
    }).toList();

    final filteredPelanggaran = guruVm.daftarPelanggaran.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.nama.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query) ||
          item.poin.toString().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: Column(
        children: [
          // Header Guru
          CustomHeader(
            nama: guru.nama,
            detail1: 'NIP: ${guru.nip}',
            backgroundColor: const Color(0xFF302B63),
            onLogout: () {
              authVm.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          ),

          // Content
          Expanded(
            child: guruVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => guruVm.refreshData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Berikan Poin Siswa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pilih salah satu jenis poin di bawah ini untuk mencari siswa penerima.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Search Bar
                          SearchField(
                            controller: _searchController,
                            hintText: 'Cari jenis poin...',
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Section Apresiasi
                          _buildSectionTitle('Daftar Apresiasi (Poin Positif)'),
                          const SizedBox(height: 10),
                          if (filteredApresiasi.isEmpty)
                            _buildEmptyState('Apresiasi tidak ditemukan')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredApresiasi.length,
                              itemBuilder: (context, index) {
                                return _buildPoinTile(
                                  context: context,
                                  item: filteredApresiasi[index],
                                  color: const Color(0xFF4CAF50),
                                );
                              },
                            ),
                          const SizedBox(height: 24),

                          // Section Pelanggaran
                          _buildSectionTitle('Daftar Pelanggaran (Poin Negatif)'),
                          const SizedBox(height: 10),
                          if (filteredPelanggaran.isEmpty)
                            _buildEmptyState('Pelanggaran tidak ditemukan')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredPelanggaran.length,
                              itemBuilder: (context, index) {
                                return _buildPoinTile(
                                  context: context,
                                  item: filteredPelanggaran[index],
                                  color: Colors.redAccent,
                                );
                              },
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF302B63),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPoinTile({
    required BuildContext context,
    required JenisCatatan item,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(
            '+${item.poin}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          item.nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            item.deskripsi,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey.shade400,
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
