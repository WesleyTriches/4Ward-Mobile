import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../models/appointment.dart';
import '../../state/app_dependencies.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/fact.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/status_badge.dart';

/// Cartão de uma consulta, com o cancelamento embutido (como no web).
class AppointmentCard extends StatefulWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.canCancel,
    required this.onCancelled,
  });

  final Appointment appointment;
  final bool canCancel;
  final VoidCallback onCancelled;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  final _reason = TextEditingController();

  bool _cancelling = false;
  bool _busy = false;
  String _error = '';

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Informe o motivo do cancelamento.');
      return;
    }

    final service = AppScope.of(context).appointments;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = '';
    });

    try {
      await service.cancel(widget.appointment.id, reason);
      widget.onCancelled();
    } catch (error) {
      // Ex.: "Cancelamentos só podem ser feitos com 24h de antecedência."
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final reason = appointment.reason?.trim() ?? '';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.physiotherapist.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.physiotherapist.specialty.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(appointment.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Fact(label: 'Data', value: formatDMY(appointment.dateTime)),
              ),
              Expanded(
                child: Fact(
                  label: 'Horário',
                  value: formatTime(appointment.dateTime),
                ),
              ),
              Expanded(
                child: Fact(
                  label: 'Valor',
                  value: formatCurrency(appointment.price),
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'Motivo: ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink700,
                ),
                children: [
                  TextSpan(
                    text: reason,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink600,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (appointment.status == AppointmentStatus.cancelled &&
              (appointment.cancelReason?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            Text(
              'Cancelamento: ${appointment.cancelReason}',
              style: const TextStyle(fontSize: 13, color: AppColors.danger700),
            ),
          ],
          if (widget.canCancel && !_cancelling) ...[
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger600,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _cancelling = true),
              child: const Text('Cancelar consulta'),
            ),
          ],
          if (widget.canCancel && _cancelling) ...[
            const SizedBox(height: 12),
            LabeledField(
              label: 'Motivo do cancelamento',
              controller: _reason,
              maxLines: 2,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              FeedbackBanner.error(_error),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(
                  label: 'Confirmar cancelamento',
                  variant: AppButtonVariant.danger,
                  loading: _busy,
                  onPressed: _confirmCancel,
                ),
                AppButton(
                  label: 'Voltar',
                  variant: AppButtonVariant.ghost,
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _cancelling = false;
                            _error = '';
                          }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
