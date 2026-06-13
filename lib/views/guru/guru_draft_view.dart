import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/draft_model.dart';
import '../../models/user_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/search_field.dart';

/// Halaman Detail Draft & Pesan Guru (Request #5)
/// Menampilkan: 
/// 1. Daftar Draft belum diproses (bisa proses per siswa, proses semua, edit, hapus)
/// 2. Formulir Kirim Surat / Pesan Peringatan ke Siswa dengan Lampiran Dokumen Realistis
class GuruDraftView extends StatefulWidget {
  const GuruDraftView({super.key});

  @override
  State<GuruDraftView> createState() => _GuruDraftViewState();
}

class _GuruDraftViewState extends State<GuruDraftView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form state untuk Kirim Pesan
  final _messageFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _catatanController = TextEditingController();
  final _lampiranController = TextEditingController();
  List<Siswa> _selectedRecipients = [];

  // Simulated file upload states (Request #3)
  String? _attachedFileName;
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _catatanController.dispose();
    _lampiranController.dispose();
    super.dispose();
  }

  void _simulateFileUpload(String fileName) async {
    setState(() {
      _isUploadingFile = true;
      _uploadProgress = 0.0;
      _attachedFileName = fileName;
    });

    // Jalankan timer untuk progress bar upload
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _uploadProgress = i / 10.0;
      });
    }

    setState(() {
      _isUploadingFile = false;
      _lampiranController.text = fileName;
    });
  }

  void _removeAttachedFile() {
    setState(() {
      _attachedFileName = null;
      _isUploadingFile = false;
      _uploadProgress = 0.0;
      _lampiranController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text(
          'Kelola Draf & Kirim Surat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF302B63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF302B63),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Daftar Draft'),
            Tab(text: 'Kirim Pesan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDraftTab(context),
          _buildPesanTab(context),
        ],
      ),
    );
  }

  // ===== BUILD TAB DRAFT =====
  Widget _buildDraftTab(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);

    if (guruVm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (guruVm.drafts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => guruVm.refreshData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada draft tersimpan',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Poin yang disimpan sebagai draft akan muncul di sini.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => guruVm.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guruVm.drafts.length,
        itemBuilder: (context, index) {
          final draft = guruVm.drafts[index];
          return _buildDraftCard(context, draft, guruVm);
        },
      ),
    );
  }

  Widget _buildDraftCard(BuildContext context, Draft draft, GuruViewModel vm) {
    final isApresiasi = draft.jenisPoin == 'prestasi';
    final color = isApresiasi ? const Color(0xFF4CAF50) : Colors.redAccent;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Draft Poin
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Text(
                    '${isApresiasi ? "+" : ""}${draft.poin}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.namaPoin,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        draft.detailPoin,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade50,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  draft.createdAt.split(' ').first,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
            const Divider(height: 24),

            // Daftar Penerima (Siswa)
            Row(
              children: [
                const Text(
                  'Daftar Penerima:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  '${draft.daftarSiswa.length} siswa',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Student list as horizontal chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: draft.daftarSiswa.length,
                itemBuilder: (context, index) {
                  final siswa = draft.daftarSiswa[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      onPressed: () => _showStudentActionSheet(context, draft, siswa, vm),
                      label: Text(
                        '${siswa.nama} (${siswa.kelas})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: const Color(0xFF302B63).withValues(alpha: 0.05),
                      side: BorderSide(
                        color: const Color(0xFF302B63).withValues(alpha: 0.15),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Aksi Draft
            Row(
              children: [
                // Edit / Manage Recipient
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDraftDialog(context, draft, vm),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Hapus Draft
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDeleteDraft(context, draft, vm),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Proses Semua
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await vm.prosesDraft(draft);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Berhasil memproses draft ${draft.namaPoin}!'),
                          backgroundColor: color,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Proses Semua'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF302B63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentActionSheet(
      BuildContext context, Draft draft, Siswa siswa, GuruViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                siswa.nama,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Kelas: ${siswa.kelas} • NIS: ${siswa.nis}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Tindakan untuk draf poin: "${draft.namaPoin}" (${draft.poin} Poin)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  child: Icon(Icons.check),
                ),
                title: const Text('Berikan Poin Sekarang', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Hanya proses siswa ini dari draft', style: TextStyle(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(context);
                  await vm.prosesDraftSatuSiswa(draft, siswa);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Poin berhasil diberikan ke ${siswa.nama}!'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.person_remove),
                ),
                title: const Text('Keluarkan dari Draft', style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                subtitle: const Text('Hapus siswa ini dari draf penerima', style: TextStyle(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(context);
                  final updatedSiswa = List<Siswa>.from(draft.daftarSiswa)..remove(siswa);
                  if (updatedSiswa.isEmpty) {
                    await vm.hapusDraft(draft.id);
                  } else {
                    await vm.updateDraft(draft.copyWith(daftarSiswa: updatedSiswa));
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${siswa.nama} dikeluarkan dari draft'),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDraftDialog(BuildContext context, Draft draft, GuruViewModel vm) {
    List<Siswa> tempSiswa = List.from(draft.daftarSiswa);
    final allSiswaList = vm.getAllSiswa();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Edit Penerima Draft', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    Text(
                      'Poin: ${draft.namaPoin} (+${draft.poin})',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allSiswaList.length,
                        itemBuilder: (context, index) {
                          final siswa = allSiswaList[index];
                          final isSelected = tempSiswa.any((s) => s.nis == siswa.nis);

                          return CheckboxListTile(
                            title: Text(siswa.nama, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('${siswa.kelas} • NIS: ${siswa.nis}', style: const TextStyle(fontSize: 11)),
                            value: isSelected,
                            activeColor: const Color(0xFF302B63),
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  if (!tempSiswa.any((s) => s.nis == siswa.nis)) {
                                    tempSiswa.add(siswa);
                                  }
                                } else {
                                  tempSiswa.removeWhere((s) => s.nis == siswa.nis);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (tempSiswa.isEmpty) {
                      await vm.hapusDraft(draft.id);
                    } else {
                      await vm.updateDraft(draft.copyWith(daftarSiswa: tempSiswa));
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Draft berhasil diperbarui')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDraft(BuildContext context, Draft draft, GuruViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Draft'),
        content: Text('Apakah Anda yakin ingin menghapus draft "${draft.namaPoin}" ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.hapusDraft(draft.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draft berhasil dihapus'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ===== BUILD TAB PESAN / INBOX =====
  Widget _buildPesanTab(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _messageFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kirim Surat / Pesan Peringatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF302B63),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Surat ini akan dikirimkan langsung ke inbox dashboard siswa yang bersangkutan.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),

                // Penerima Siswa Selector
                const Text(
                  'Penerima Siswa *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildRecipientSelector(context, guruVm),
                const SizedBox(height: 16),

                // Judul Pesan / Subjek
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Surat *',
                    hintText: 'Contoh: Surat Peringatan I (Terlambat)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Isi Pesan
                TextFormField(
                  controller: _bodyController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Isi Surat / Pesan *',
                    hintText: 'Tuliskan isi surat peringatan atau pembinaan siswa secara detail di sini...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Isi pesan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Catatan Tambahan (Optional)
                TextFormField(
                  controller: _catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Tambahan (Opsional)',
                    hintText: 'Contoh: Harus menghadap wali kelas besok pagi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Unggah File Lampiran Realistis (Request #3)
                const Text(
                  'Lampiran Berkas (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildFileUploaderSection(),
                const SizedBox(height: 24),

                // Button Kirim
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _submitMessage(context, guruVm),
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Surat / Pesan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF302B63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploaderSection() {
    if (_attachedFileName != null) {
      // Tampilan File Ter-upload / Sedang Upload
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _isUploadingFile
                      ? const Color(0xFF302B63).withValues(alpha: 0.1)
                      : const Color(0xFFE8F5E9),
                  child: Icon(
                    _isUploadingFile ? Icons.cloud_upload : Icons.insert_drive_file,
                    color: _isUploadingFile ? const Color(0xFF302B63) : const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _attachedFileName!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _isUploadingFile
                            ? 'Sedang mengunggah berkas...'
                            : 'Unggah berhasil • 2.4 MB',
                        style: TextStyle(
                          fontSize: 11,
                          color: _isUploadingFile ? Colors.grey : const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isUploadingFile)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                    onPressed: _removeAttachedFile,
                  ),
              ],
            ),
            if (_isUploadingFile) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _uploadProgress,
                color: const Color(0xFF302B63),
                backgroundColor: const Color(0xFF302B63).withValues(alpha: 0.1),
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Tampilan Area Klik untuk Lampirkan Berkas
    return GestureDetector(
      onTap: () => _showFilePickerMockDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF302B63).withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 36, color: const Color(0xFF302B63).withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            const Text(
              'Pilih File Lampiran Pembinaan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF302B63)),
            ),
            const SizedBox(height: 2),
            Text(
              'Mendukung JPG, PNG, PDF, DOCX (Maks. 5 MB)',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePickerMockDialog() {
    final mockFiles = [
      'bukti_pelanggaran_terlambat.jpg',
      'surat_pembinaan_tatap_muka.pdf',
      'dokumentasi_prestasi_lomba.png',
      'laporan_konseling_siswa.docx',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Pilih Berkas Lampiran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mockFiles.length,
              itemBuilder: (context, index) {
                final file = mockFiles[index];
                IconData fileIcon = Icons.insert_drive_file;
                Color iconColor = Colors.grey;

                if (file.endsWith('.jpg') || file.endsWith('.png')) {
                  fileIcon = Icons.image;
                  iconColor = Colors.blue;
                } else if (file.endsWith('.pdf')) {
                  fileIcon = Icons.picture_as_pdf;
                  iconColor = Colors.redAccent;
                } else if (file.endsWith('.docx')) {
                  fileIcon = Icons.description;
                  iconColor = Colors.blue.shade800;
                }

                return ListTile(
                  leading: Icon(fileIcon, color: iconColor),
                  title: Text(file, style: const TextStyle(fontSize: 13)),
                  trailing: const Text('2.4 MB', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(context);
                    _simulateFileUpload(file);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipientSelector(BuildContext context, GuruViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedRecipients.isNotEmpty) ...[
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: _selectedRecipients.map((siswa) {
              return Chip(
                label: Text('${siswa.nama} (${siswa.kelas})', style: const TextStyle(fontSize: 11)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () {
                  setState(() {
                    _selectedRecipients.remove(siswa);
                  });
                },
                backgroundColor: const Color(0xFF302B63).withValues(alpha: 0.08),
                side: BorderSide(color: const Color(0xFF302B63).withValues(alpha: 0.15)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: () => _showRecipientSearchDialog(context, vm),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Pilih Siswa Penerima'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  void _showRecipientSearchDialog(BuildContext context, GuruViewModel vm) {
    List<Siswa> tempRecipients = List.from(_selectedRecipients);
    final allSiswaList = vm.getAllSiswa();
    String dialogSearchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredList = allSiswaList.where((siswa) {
              final query = dialogSearchQuery.toLowerCase();
              return siswa.nama.toLowerCase().contains(query) ||
                  siswa.kelas.toLowerCase().contains(query) ||
                  siswa.nis.contains(query);
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Pilih Penerima Surat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    SearchField(
                      hintText: 'Cari nama, kelas, NIS...',
                      onChanged: (val) {
                        setDialogState(() {
                          dialogSearchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final siswa = filteredList[index];
                          final isSelected = tempRecipients.any((s) => s.nis == siswa.nis);

                          return CheckboxListTile(
                            title: Text(siswa.nama, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('${siswa.kelas} • NIS: ${siswa.nis}', style: const TextStyle(fontSize: 11)),
                            value: isSelected,
                            activeColor: const Color(0xFF302B63),
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  if (!tempRecipients.any((s) => s.nis == siswa.nis)) {
                                    tempRecipients.add(siswa);
                                  }
                                } else {
                                  tempRecipients.removeWhere((s) => s.nis == siswa.nis);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedRecipients = tempRecipients;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Selesai'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitMessage(BuildContext context, GuruViewModel vm) async {
    if (_selectedRecipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu siswa penerima!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_messageFormKey.currentState?.validate() ?? false) {
      await vm.kirimPesan(
        judul: _titleController.text.trim(),
        isiPesan: _bodyController.text.trim(),
        tujuan: _selectedRecipients,
        catatan: _catatanController.text.trim().isEmpty ? null : _catatanController.text.trim(),
        lampiran: _lampiranController.text.trim().isEmpty ? null : _lampiranController.text.trim(),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat/Pesan berhasil dikirim!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      // Reset form & file uploader
      _titleController.clear();
      _bodyController.clear();
      _catatanController.clear();
      _lampiranController.clear();
      setState(() {
        _selectedRecipients.clear();
        _attachedFileName = null;
        _isUploadingFile = false;
        _uploadProgress = 0.0;
      });
    }
  }
}
