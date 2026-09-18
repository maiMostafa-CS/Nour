import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran_bloc.dart';

/// يعرض dialog "لا يوجد إنترنت".
/// ترجع true لو ضغط المستخدم "إعادة المحاولة".
Future<bool> showNoInternetDialog(
    BuildContext context, {
      String message = 'لا يوجد اتصال بالإنترنت',
      VoidCallback? onRetry,
    }) async {
  final retry = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          icon: const Icon(Icons.wifi_off_rounded, size: 40),
          title: const Text('لا يوجد اتصال بالإنترنت'),
          content: Text(
            '$message\n\nيلزم الاتصال بالإنترنت لتحميل التفسير.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إغلاق'),
            ),
            if (onRetry != null)
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('إعادة المحاولة'),
              ),
          ],
        ),
      );
    },
  );

  if (retry == true) {
    onRetry?.call();
    return true;
  }

  return false;
}

class NoInternetListener extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const NoInternetListener({
    super.key,
    required this.child,
    this.onRetry,
  });

  @override
  State<NoInternetListener> createState() => _NoInternetListenerState();
}

class _NoInternetListenerState extends State<NoInternetListener> {
  StreamSubscription<String>? _subscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<QuranIndexBloc>();

    _subscription = bloc.noInternetStream.listen(_show);

    // لو الخطأ حصل قبل ما الودجت تشتغل
    final pending = bloc.takePendingNoInternet();
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show(pending);
      });
    }
  }

  Future<void> _show(String message) async {
    // لا نفتح أكثر من dialog في نفس الوقت
    if (!mounted || _isDialogShowing) return;

    _isDialogShowing = true;

    await showNoInternetDialog(
      context,
      message: message,
      onRetry: widget.onRetry,
    );

    _isDialogShowing = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}