import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnlockCard {
  static const MethodChannel _ch = MethodChannel('prayer_app/unlock_card');

  static Future<void> showTest() {
    return _ch.invokeMethod('showTestCard');
  }

  static Future<bool> hasOverlayPermission() async {
    return await _ch.invokeMethod<bool>(
          'hasOverlayPermission',
        ) ??
        false;
  }

  static Future<void> requestOverlayPermission() {
    return _ch.invokeMethod('requestOverlayPermission');
  }

  static Future<bool> start() async {
    final result = await _ch.invokeMethod<bool>('startService');

    return result ?? false;
  }

  static Future<bool> stop() async {
    final result = await _ch.invokeMethod<bool>('stopService');

    return result ?? false;
  }

  static Future<bool> isEnabled() async {
    return await _ch.invokeMethod<bool>(
          'isEnabled',
        ) ??
        false;
  }

  static Future<void> savePrayers(
    List<MapEntry<String, DateTime>> prayers,
  ) {
    final data = prayers
        .map(
          (e) => '${e.key}|${e.value.millisecondsSinceEpoch}',
        )
        .join(';');

    return _ch.invokeMethod(
      'savePrayers',
      {'data': data},
    );
  }
}

class UnlockAyahSwitch extends StatefulWidget {
  const UnlockAyahSwitch({super.key});

  @override
  State<UnlockAyahSwitch> createState() => _UnlockAyahSwitchState();
}

class _UnlockAyahSwitchState extends State<UnlockAyahSwitch> {
  bool enabled = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final value = await UnlockCard.isEnabled();

    if (!mounted) return;

    setState(() {
      enabled = value;
    });
  }

  Future<void> _toggle(bool value) async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      if (value) {
// ==================================================
// 1. التأكد من صلاحية الظهور فوق التطبيقات
// ==================================================

        final hasPermission = await UnlockCard.hasOverlayPermission();

        if (!hasPermission) {
          await UnlockCard.requestOverlayPermission();

          if (!mounted) return;

          setState(() {
            enabled = false;
          });

          return;
        }

// ==================================================
// 2. تشغيل خدمة كارد الآية
// ==================================================

        final started = await UnlockCard.start();

        if (!mounted) return;

        setState(() {
          enabled = started;
        });
      } else {
// ==================================================
// إيقاف الخدمة
// ==================================================

        final stopped = await UnlockCard.stop();

        if (!mounted) return;

        setState(() {
          enabled = !stopped;
        });
      }
    } on PlatformException catch (e) {
      debugPrint(
        'UnlockCard PlatformException: '
        '${e.code} - ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        enabled = false;
      });
    } catch (e) {
      debugPrint(
        'UnlockCard ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        enabled = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text(
        'آية عند فتح الهاتف',
      ),
      subtitle: Text(
        loading
            ? 'جاري التحديث...'
            : enabled
                ? 'مفعلة'
                : 'متوقفة',
      ),
      value: enabled,
      onChanged: loading ? null : _toggle,
    );
  }
}
