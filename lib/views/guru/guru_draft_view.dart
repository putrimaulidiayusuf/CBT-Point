import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/draft_model.dart';
import '../../models/user_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/search_field.dart';
import '../widgets/glass_container.dart';

class GuruDraftView extends StatefulWidget {
  final int initialTab;
  const GuruDraftView({super.key, this.initialTab = 0});

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

  // Simulated file upload states
  String? _attachedFileName;
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
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
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(104), // Double size for TabBar
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              title: const Text(
                'Kelola Draf & Kirim Surat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F0C29).withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF6C63FF),
                unselectedLabelColor: Colors.white54,
                indicatorColor: const Color(0xFF6C63FF),
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'Daftar Draft'),
                  Tab(text: 'Kirim Pesan'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
  children: [
    // Background Glows
    Positioned(
      top: 150,
      right: -100,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ),
    ),
    Positioned(
      bottom: 80,
      left: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF2E93).withValues(alpha: 0.05),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
          child: Container(color: Colors.transparent),
        ),
      ),
    ),

    // ✅ FIX OVERFLOW DI SINI
    Positioned.fill(
      child: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDraftTab(context),
            _buildPesanTab(context),
          ],
        ),
      ),
    ),
  ],
),
    );
  }

  // ===== BUILD TAB DRAFT =====
  Widget _buildDraftTab(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);

    if (guruVm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }

    if (guruVm.drafts.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF6C63FF),
        backgroundColor: const Color(0xFF151233),
        onRefresh: () => guruVm.refreshData(),
        child: ListView(
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
                    child: Icon(Icons.assignment_outlined, size: 56, color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada draft tersimpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Draf pencatatan poin akan tersimpan di sini.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
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
      color: const Color(0xFF6C63FF),
      backgroundColor: const Color(0xFF151233),
      onRefresh: () => guruVm.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    final color = isApresiasi ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Draft Poin
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '${isApresiasi ? "+" : ""}${draft.poin}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
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
                    const SizedBox(height: 2),
                    Text(
                      draft.detailPoin,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                draft.createdAt.split(' ').first,
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45)),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),

          // Daftar Penerima (Siswa)
          const Text(
            'Daftar Penerima Poin:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
const SizedBox(height: 10),

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
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
          side: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    },
  ),
),
          const SizedBox(height: 8),
          Text(
            '* Ketuk siswa di atas untuk memproses/menghapus secara individu.',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), fontStyle: FontStyle.italic),
          ),
          const Divider(color: Colors.white10, height: 24),

          // Tombol Aksi Draft
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => vm.hapusDraft(draft.id),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF2E93), size: 18),
                label: const Text('Hapus Draft', style: TextStyle(color: Color(0xFFFF2E93), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showEditDraftDialog(context, draft, vm),
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF00F2FE), size: 20),
                label: const Text('Edit Siswa', style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  await vm.prosesDraft(draft);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Draf berhasil diproses ke ${draft.daftarSiswa.length} siswa!'),
                      backgroundColor: color,
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 14),

label: const Text(
  'Proses Semua',
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
),

style: ElevatedButton.styleFrom(
  backgroundColor: color,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  minimumSize: const Size(0, 34),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStudentActionSheet(
      BuildContext context, Draft draft, Siswa siswa, GuruViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF151233).withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa.nama,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Kelas: ${siswa.kelas} • NIS: ${siswa.nis}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00FF87)),
                  title: const Text('Proses Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Kirim poin ke siswa ini saja dan keluarkan dari draf', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onTap: () async {
                    Navigator.pop(context);
                    await vm.prosesDraftSatuSiswa(draft, siswa);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Poin berhasil dicatat untuk ${siswa.nama}!'),
                        backgroundColor: const Color(0xFF00FF87),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF2E93)),
                  title: const Text('Hapus dari Draf', style: TextStyle(color: Color(0xFFFF2E93), fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Keluarkan siswa ini dari daftar penerima draf', style: TextStyle(color: Colors.white54, fontSize: 11)),
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
                      const SnackBar(
                        content: Text('Siswa berhasil dikeluarkan dari draf'),
                        backgroundColor: Color(0xFFFF2E93),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDraftDialog(BuildContext context, Draft draft, GuruViewModel vm) {
    List<Siswa> tempSelected = List<Siswa>.from(draft.daftarSiswa);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AlertDialog(
                backgroundColor: const Color(0xFF151233).withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                ),
                title: const Text(
                  'Edit Penerima Draf',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 350,
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pilih siswa yang akan dipertahankan di draf ini:',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: vm.getAllSiswa().length,
                          itemBuilder: (context, index) {
                            final s = vm.getAllSiswa()[index];
                            final isChecked = tempSelected.any((siswa) => siswa.nis == s.nis);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isChecked 
                                    ? const Color(0xFF6C63FF).withValues(alpha: 0.08) 
                                    : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked 
                                      ? const Color(0xFF6C63FF) 
                                      : Colors.white.withValues(alpha: 0.05)
                                ),
                              ),
                              child: CheckboxListTile(
                                activeColor: const Color(0xFF6C63FF),
                                checkColor: Colors.white,
                                title: Text(s.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                subtitle: Text('${s.kelas} • NIS: ${s.nis}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                                value: isChecked,
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      tempSelected.add(s);
                                    } else {
                                      tempSelected.removeWhere((siswa) => siswa.nis == s.nis);
                                    }
                                  });
                                },
                              ),
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
                    child: Text('Batal', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                  ),
                  ElevatedButton(
                    onPressed: tempSelected.isEmpty
                        ? null
                        : () async {
                            Navigator.pop(context);
                            await vm.updateDraft(draft.copyWith(daftarSiswa: tempSelected));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Draf berhasil diperbarui!'),
                                backgroundColor: Color(0xFF00FF87),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===== BUILD TAB KIRIM PESAN =====
  Widget _buildPesanTab(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: GlassContainer(
        color: Colors.white.withValues(alpha: 0.03),
        borderColor: Colors.white.withValues(alpha: 0.08),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _messageFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kirim Surat & Pesan Peringatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Surat ini akan dikirimkan langsung ke inbox dashboard siswa yang bersangkutan.',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
              ),
              const SizedBox(height: 20),

              // Penerima Siswa Selector
              const Text(
                'Penerima Siswa *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 8),
              _buildRecipientSelector(context, guruVm),
              const SizedBox(height: 16),

              // Judul Pesan / Subjek
              _buildFormTextField(
                controller: _titleController,
                label: 'Subjek / Judul Surat *',
                hint: 'Contoh: Surat Peringatan I (Disiplin Terlambat)',
                icon: Icons.mail_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Subjek tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Isi Pesan
              _buildFormTextField(
                controller: _bodyController,
                label: 'Isi Surat / Pesan *',
                hint: 'Tuliskan rincian pelanggaran, peringatan, atau pembinaan secara detail...',
                icon: Icons.notes_rounded,
                maxLines: 5,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Isi surat tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Catatan Tambahan (Optional)
              _buildFormTextField(
                controller: _catatanController,
                label: 'Catatan Tambahan (Opsional)',
                hint: 'Contoh: Harus menghadap Wali Kelas besok jam 08.00 WIB',
                icon: Icons.note_alt_outlined,
              ),
              const SizedBox(height: 20),

              // Section input file / Lampiran Dokumen
              const Text(
                'Lampiran Surat Peringatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 8),
              _buildFileUploaderSection(),
              const SizedBox(height: 28),

              // Tombol Kirim Pesan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleKirimPesan(context, guruVm),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Kirim Surat Peringatan', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2E93),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFFFF2E93).withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13.5),
      cursorColor: const Color(0xFF6C63FF),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12.5),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.45), size: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFF2E93), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFF2E93), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildFileUploaderSection() {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withValues(alpha: 0.02),
      borderColor: Colors.white.withValues(alpha: 0.06),
      child: Column(
        children: [
          if (_attachedFileName == null)
            GestureDetector(
              onTap: () => _showFilePickerMockDialog(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.white.withValues(alpha: 0.35)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih File Lampiran (PDF, JPG, PNG)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ukuran maksimal 5 MB',
                      style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF6C63FF), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _attachedFileName!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      _isUploadingFile
                          ? Text(
                              'Mengunggah: ${(_uploadProgress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                            )
                          : Text(
                              'Berhasil dilampirkan',
                              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.45)),
                            ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF2E93), size: 20),
                  onPressed: () => _removeAttachedFile(),
                ),
              ],
            ),
            if (_isUploadingFile) ...[
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 6,
                    width: (MediaQuery.of(context).size.width - 80) * _uploadProgress,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ],
      ),
    );
  }

  void _showFilePickerMockDialog() {
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
          title: const Text('Pilih File Simulasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMockFileItem('surat_peringatan_terlambat.pdf'),
              _buildMockFileItem('foto_pelanggaran_atribut.jpg'),
              _buildMockFileItem('laporan_piket_bersih.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockFileItem(String filename) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.attach_file_rounded, color: Color(0xFF00F2FE), size: 20),
        title: Text(filename, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        onTap: () {
          Navigator.pop(context);
          _simulateFileUpload(filename);
        },
      ),
    );
  }

  Widget _buildRecipientSelector(BuildContext context, GuruViewModel vm) {
    return GestureDetector(
      onTap: () => _showRecipientSearchDialog(context, vm),
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: Colors.white.withValues(alpha: 0.02),
        borderColor: Colors.white.withValues(alpha: 0.12),
        child: Row(
          children: [
            Expanded(
              child: _selectedRecipients.isEmpty
                  ? Text(
                      'Pilih satu atau beberapa siswa...',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedRecipients.map((s) {
                        return InputChip(
                          label: Text(s.nama, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                          side: BorderSide(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                          onDeleted: () {
                            setState(() {
                              _selectedRecipients.removeWhere((siswa) => siswa.nis == s.nis);
                            });
                          },
                          deleteIconColor: Colors.white70,
                        );
                      }).toList(),
                    ),
            ),
            Icon(Icons.add_circle_outline_rounded, color: Colors.white.withValues(alpha: 0.45), size: 22),
          ],
        ),
      ),
    );
  }

  void _showRecipientSearchDialog(BuildContext context, GuruViewModel vm) {
    List<Siswa> tempSelected = List<Siswa>.from(_selectedRecipients);
    List<Siswa> tempResults = vm.getAllSiswa();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AlertDialog(
                backgroundColor: const Color(0xFF151233).withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                ),
                title: const Text('Pilih Penerima Surat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 380,
                  child: Column(
                    children: [
                      SearchField(
                        hintText: 'Cari nama, kelas, atau NIS...',
                        onChanged: (val) {
                          setDialogState(() {
                            tempResults = vm.searchSiswa(val);
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tempResults.length,
                          itemBuilder: (context, index) {
                            final s = tempResults[index];
                            final isChecked = tempSelected.any((siswa) => siswa.nis == s.nis);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isChecked 
                                    ? const Color(0xFF6C63FF).withValues(alpha: 0.08) 
                                    : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked 
                                      ? const Color(0xFF6C63FF) 
                                      : Colors.white.withValues(alpha: 0.05)
                                ),
                              ),
                              child: CheckboxListTile(
                                activeColor: const Color(0xFF6C63FF),
                                checkColor: Colors.white,
                                title: Text(s.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                subtitle: Text('${s.kelas} • NIS: ${s.nis}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                                value: isChecked,
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      tempSelected.add(s);
                                    } else {
                                      tempSelected.removeWhere((siswa) => siswa.nis == s.nis);
                                    }
                                  });
                                },
                              ),
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
                    child: Text('Batal', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRecipients = tempSelected;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Pilih'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleKirimPesan(BuildContext context, GuruViewModel vm) async {
    if (_selectedRecipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penerima wajib dipilih minimal 1 siswa!'),
          backgroundColor: Color(0xFFFF2E93),
        ),
      );
      return;
    }

    if (_messageFormKey.currentState!.validate()) {
      await vm.kirimPesan(
        judul: _titleController.text.trim(),
        isiPesan: _bodyController.text.trim(),
        tujuan: _selectedRecipients,
        catatan: _catatanController.text.trim().isEmpty ? null : _catatanController.text.trim(),
        lampiran: _lampiranController.text.trim().isEmpty ? null : _lampiranController.text.trim(),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surat Peringatan berhasil dikirim ke ${_selectedRecipients.length} siswa!'),
          backgroundColor: const Color(0xFF00FF87),
        ),
      );

      // Reset form
      _titleController.clear();
      _bodyController.clear();
      _catatanController.clear();
      _lampiranController.clear();
      setState(() {
        _selectedRecipients.clear();
        _attachedFileName = null;
      });
    }
  }
}
