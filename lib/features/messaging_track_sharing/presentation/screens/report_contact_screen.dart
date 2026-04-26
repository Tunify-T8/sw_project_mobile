import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ReportContactScreen extends ConsumerStatefulWidget {
  const ReportContactScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  final String conversationId;
  final String otherUserName;

  @override
  ConsumerState<ReportContactScreen> createState() =>
      _ReportContactScreenState();
}

class _ReportContactScreenState extends ConsumerState<ReportContactScreen> {
  static const List<String> _reasons = [
    "It's hate speech",
    "It's terrorist or extremist content",
    "It's graphic or violent",
    "It's abuse/ harassment",
    "It contains nudity or pornographic content",
    'Protection of minors',
    'It promotes or glorifies self-harm',
    "It's a privacy violation",
    "It's misrepresentation or misleading",
    "It's selling restricted items",
    'Something else',
    "I just don't like it",
  ];

  static const List<String> _violationTargets = [
    'Audio',
    'Image',
    'Text',
    'Account holder',
    'Direct message',
  ];

  String? _selectedReason;
  final Set<String> _selectedTargets = <String>{};
  bool _goodFaithChecked = false;

  late final TextEditingController _detailsController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();

    final authUser = ref.read(authControllerProvider).value;
    _detailsController = TextEditingController();
    _nameController = TextEditingController(
      text: authUser?.username ?? '',
    );
    _emailController = TextEditingController(
      text: authUser?.email ?? '',
    );
    _urlController = TextEditingController(
      text: 'tunify://messages/${widget.conversationId}',
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedReason != null &&
      _goodFaithChecked &&
      _detailsController.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the required report fields.'),
          backgroundColor: Color(0xFF2A2A2A),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted.'),
        backgroundColor: Color(0xFF2A2A2A),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Report Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Reason for Reporting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ..._reasons.map(_buildReasonTile),
              const SizedBox(height: 26),
              const Text(
                "Please provide more detail as to why you're reporting this content",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _detailsController,
                hint: 'Content report details',
                maxLines: 2,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 22),
              const Text(
                'Your Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _nameController,
                hint: 'Name',
              ),
              const SizedBox(height: 22),
              const Text(
                'Your email address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _emailController,
                hint: 'Email address',
              ),
              const SizedBox(height: 22),
              const Text(
                'Please provide a link (URL) to the piece of content on SoundCloud that you want to report. Please only input one link per report.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _urlController,
                hint: 'URL',
              ),
              const SizedBox(height: 22),
              const Text(
                'Select where the violation occurs (select as many as necessary)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              ..._violationTargets.map(_buildTargetTile),
              const SizedBox(height: 18),
              InkWell(
                onTap: () {
                  setState(() {
                    _goodFaithChecked = !_goodFaithChecked;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SquareCheck(
                      checked: _goodFaithChecked,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'I hereby state that I have a good faith belief that the information and allegations I have submitted are accurate and complete.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Submit report',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile(String label) {
    final selected = _selectedReason == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedReason = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _RadioCircle(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTile(String label) {
    final checked = _selectedTargets.contains(label);

    return InkWell(
      onTap: () {
        setState(() {
          if (checked) {
            _selectedTargets.remove(label);
          } else {
            _selectedTargets.add(label);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            _SquareCheck(checked: checked),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.white : Colors.white54,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(
                radius: 4,
                backgroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}

class _SquareCheck extends StatelessWidget {
  const _SquareCheck({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: checked ? Colors.white : Colors.transparent,
        border: Border.all(
          color: checked ? Colors.white : Colors.white54,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: checked
          ? const Icon(
              Icons.check,
              size: 13,
              color: Colors.black,
            )
          : null,
    );
  }
}
