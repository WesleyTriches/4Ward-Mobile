import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/physiotherapist.dart';
import '../../models/service_mode.dart';
import '../../models/specialty.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_box.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/page_header.dart';
import '../appointments/booking_screen.dart';
import 'physio_card.dart';
import 'physio_detail_screen.dart';

/// Aba "Fisioterapeutas": busca por cidade, especialidade e modalidade.
class PhysiosScreen extends StatefulWidget {
  const PhysiosScreen({super.key});

  @override
  State<PhysiosScreen> createState() => _PhysiosScreenState();
}

class _PhysiosScreenState extends State<PhysiosScreen> {
  final _city = TextEditingController();

  List<Physiotherapist> _physios = [];
  List<Specialty> _specialties = [];
  int? _specialtyId;
  ServiceMode? _serviceMode;

  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadSpecialties();
      _search();
    });
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    final service = AppScope.of(context).specialties;
    try {
      final list = await service.list();
      list.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() => _specialties = list);
    } catch (_) {
      // Sem a lista só some o filtro por especialidade; a busca segue valendo.
    }
  }

  Future<void> _search() async {
    final service = AppScope.of(context).physiotherapists;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final list = await service.list(
        city: _city.text,
        specialtyId: _specialtyId,
        serviceMode: _serviceMode,
      );
      if (mounted) setState(() => _physios = list);
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(Physiotherapist physio) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhysioDetailScreen(physio: physio),
      ),
    );
  }

  void _book(Physiotherapist physio) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingScreen(initialPhysio: physio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _search,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const PageHeader(
              title: 'Encontre seu fisioterapeuta',
              subtitle: 'Busque profissionais por cidade, especialidade '
                  'ou modalidade.',
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              FeedbackBanner.error(_error),
            ],
            const SizedBox(height: 16),
            _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LabeledField(
            label: 'Cidade',
            controller: _city,
            hint: 'Ex.: Passo Fundo',
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          _FilterDropdown<int?>(
            label: 'Especialidade',
            value: _specialtyId,
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Todas')),
              for (final specialty in _specialties)
                DropdownMenuItem<int?>(
                  value: specialty.id,
                  child: Text(specialty.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) => setState(() => _specialtyId = value),
          ),
          const SizedBox(height: 12),
          _FilterDropdown<ServiceMode?>(
            label: 'Modalidade',
            value: _serviceMode,
            items: [
              const DropdownMenuItem<ServiceMode?>(
                value: null,
                child: Text('Todas'),
              ),
              for (final mode in ServiceMode.values)
                DropdownMenuItem<ServiceMode?>(
                  value: mode,
                  child: Text(mode.label),
                ),
            ],
            onChanged: (value) => setState(() => _serviceMode = value),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Buscar',
            icon: Icons.search,
            expanded: true,
            loading: _loading,
            onPressed: _search,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading && _physios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.brand600),
        ),
      );
    }

    if (_physios.isEmpty) {
      return const EmptyBox('Nenhum fisioterapeuta encontrado.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _physios.length == 1
              ? '1 profissional encontrado'
              : '${_physios.length} profissionais encontrados',
          style: const TextStyle(fontSize: 14, color: AppColors.ink500),
        ),
        const SizedBox(height: 8),
        for (final physio in _physios) ...[
          PhysioCard(
            physio: physio,
            onOpen: () => _open(physio),
            onBook: () => _book(physio),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Lista suspensa com o rótulo em cima, no estilo dos campos de texto.
class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.ink700,
          ),
        ),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: const InputDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              isDense: true,
              value: value,
              items: items,
              style: const TextStyle(fontSize: 14, color: AppColors.ink900),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
