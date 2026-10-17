// lib/features/tasbih/view/tasbih_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/tasbih_bloc.dart';
import '../bloc/tasbih_event.dart';
import '../bloc/tasbih_state.dart';
import '../widgets/edit_target_dialog.dart';
import '../widgets/tasbih_counter_widget.dart';
import '../widgets/tasbih_dhikr_card.dart';
import '../widgets/tasbih_dhikr_selector.dart';
import '../widgets/tasbih_progress_widget.dart';
import '../widgets/tasbih_stats_row.dart';
import 'add_dhikr_dialog.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TasbihBloc>()..add(const TasbihLoadRequested()),
      child: const _TasbihView(),
    );
  }
}

class _TasbihView extends StatelessWidget {
  const _TasbihView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'electronic_tasbih'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          tooltip: 'reset_all'.tr(),
          onPressed: () => _confirmResetAll(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.tealAccent),
            tooltip: 'add_dhikr'.tr(),
            onPressed: () => _showAddDhikrDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'reset_counter'.tr(),
            onPressed: () =>
                context.read<TasbihBloc>().add(const TasbihReset()),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<TasbihBloc, TasbihState>(
          listenWhen: (prev, curr) =>
          prev.justCompletedRound != curr.justCompletedRound &&
              curr.justCompletedRound,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 3),
                  content: Row(
                    children: [
                      const Icon(Icons.celebration, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ما شاء الله! أتممت ${state.targetCount} من الذكر',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );

            context
                .read<TasbihBloc>()
                .add(const TasbihRoundCompletedConsumed());
          },
          builder: (context, state) {
            if (state.status == TasbihStatus.loading ||
                state.status == TasbihStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  TasbihStatsRow(
                    completedRounds: state.completedRounds,
                    totalCount: state.totalCount,
                    currentIndex: state.currentDhikrIndex,
                    totalAdhkar: state.totalAdhkar,
                  ),
                  const SizedBox(height: 20),

                  Stack(
                    children: [
                      TasbihDhikrCard(
                        text: state.currentDhikrText,
                        virtue: state.currentDhikrVirtue,
                      ),
                      // ✨ Edit count button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: Colors.tealAccent,
                            size: 20,
                          ),
                          tooltip: 'تعديل العدد المستهدف',
                          onPressed: () =>
                              _showEditTargetDialog(context, state.targetCount),
                        ),
                      ),
                      if (state.currentDhikr?.isCustom ?? false)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            tooltip: 'حذف الذكر',
                            onPressed: () => _confirmDeleteDhikr(
                              context,
                              state.currentDhikr!.id,
                              state.currentDhikr!.text,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TasbihProgressWidget(
                    progress: state.progress,
                    current: state.currentCount,
                    target: state.targetCount,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 30),

                  TasbihCounterWidget(
                    enabled: !state.isCompleted,
                    onTap: () => context
                        .read<TasbihBloc>()
                        .add(const TasbihIncremented()),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _navButton(
                          context,
                          icon: Icons.arrow_back_ios_new,
                          label: 'previous'.tr(),
                          onTap: () => context
                              .read<TasbihBloc>()
                              .add(const TasbihPreviousDhikr()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _navButton(
                          context,
                          icon: Icons.arrow_forward_ios,
                          label: 'next'.tr(),
                          onTap: () => context
                              .read<TasbihBloc>()
                              .add(const TasbihNextDhikr()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TasbihDhikrSelector(
                    selectedIndex: state.currentDhikrIndex,
                    adhkar: state.adhkar,
                    onSelect: (i) => context
                        .read<TasbihBloc>()
                        .add(TasbihDhikrSelected(i)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _navButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _showAddDhikrDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddDhikrDialog(),
    );

    if (result == null || !context.mounted) return;

    context.read<TasbihBloc>().add(
      TasbihCustomDhikrAdded(
        text: result['text'] as String? ?? '',
        virtue: result['virtue'] as String?,
        targetCount: result['targetCount'] as int? ?? 100,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.teal,
        content: Text('dhikr_added_success'.tr()),
      ),
    );
  }

  Future<void> _showEditTargetDialog(
      BuildContext context,
      int currentTarget,
      )
  async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => EditTargetDialog(currentTarget: currentTarget),
    );

    if (result == null || !context.mounted) return;

    context.read<TasbihBloc>().add(TasbihTargetCountChanged(result));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.teal,
        content: Text('target_updated_success'.tr(args: ['$result'])),
      ),
    );
  }

  void _confirmDeleteDhikr(BuildContext context, int id, String text) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('delete'.tr(),
            style: const TextStyle(color: Colors.white)),
        content: Text(
          'delete_dhikr_confirm'.tr(args: [text]),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
            Text('cancel'.tr(), style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              context.read<TasbihBloc>().add(TasbihCustomDhikrDeleted(id));
              Navigator.pop(dialogContext);
            },
            child:
            Text('delete'.tr(), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmResetAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('reset_all'.tr()),
        content: Text('confirm_reset_all'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<TasbihBloc>().add(const TasbihResetAll());
              Navigator.pop(dialogContext);
            },
            child: Text('yes'.tr()),
          ),
        ],
      ),
    );
  }
}