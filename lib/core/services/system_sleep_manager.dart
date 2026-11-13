import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum SystemInhibit { sleep, idle, shutdown }

enum SleepLogLevel { debug, info, warning, error }

class SystemSleepManager {
  SystemSleepManager._();

  static const _who = 'Sound Center';
  static const _readyMarker = 'SOUND_CENTER_READY';

  static const _systemdInhibit = '/usr/bin/systemd-inhibit';

  static const _startupTimeout = Duration(seconds: 5);
  static const _shutdownTimeout = Duration(seconds: 3);

  static Process? _process;

  static bool _enabled = false;

  static Future<void> _queue = Future.value();

  static bool get isEnabled => _enabled;

  static Future<T> _serialize<T>(Future<T> Function() operation) {
    final completer = Completer<T>();

    _queue = _queue.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  static Future<void> preventSleep({
    String reason = 'Playing music',
    Set<SystemInhibit> what = const {SystemInhibit.sleep},
  }) {
    return _serialize(() async {
      if (Platform.isLinux && _process == null) {
        await _start(reason, what);
      }
    });
  }

  static Future<void> _start(String reason, Set<SystemInhibit> what) async {
    final arguments = [
      '--what=${what.map((e) => e.name).join(':')}',
      '--who=$_who',
      '--why=$reason',
      '--mode=block',
      '/bin/sh',
      '-c',
      "printf '%s\\n' '$_readyMarker'; exec cat",
    ];

    Process? process;

    try {
      process = await Process.start(_systemdInhibit, arguments);

      _process = process;

      final stderr = utf8.decoder.bind(process.stderr).join();
      final exitCode = process.exitCode;

      final ready = utf8.decoder
          .bind(process.stdout)
          .transform(const LineSplitter())
          .firstWhere((line) => line == _readyMarker);

      await Future.any<void>([
        ready,
        exitCode.then<void>((code) async {
          throw StateError(
            'systemd-inhibit exited with code $code. '
            'stderr=${(await stderr).trim()}',
          );
        }),
      ]).timeout(_startupTimeout);

      if (!identical(_process, process)) {
        throw StateError('Process is no longer active.');
      }

      _enabled = true;

      unawaited(
        exitCode.then((code) {
          if (!identical(_process, process)) return;
          _process = null;
          _enabled = false;
        }),
      );
    } catch (error) {
      if (process != null) {
        await _stopProcess(process);
      }

      if (identical(_process, process)) {
        _process = null;
      }

      _enabled = false;

      rethrow;
    }
  }

  static Future<void> allowSleep() {
    return _serialize(() async {
      if (!Platform.isLinux) return;
      await _stop();
    });
  }

  static Future<void> _stop() async {
    final process = _process;

    if (process == null) {
      _enabled = false;
      return;
    }

    try {
      await _stopProcess(process);
    } catch (error) {
      rethrow;
    } finally {
      if (identical(_process, process)) {
        _process = null;
      }

      _enabled = false;
    }
  }

  static Future<void> _stopProcess(Process process) async {
    try {
      await process.stdin.close();
    } catch (_) {}

    try {
      await process.exitCode.timeout(_shutdownTimeout);
    } on TimeoutException {
      process.kill();
      await process.exitCode.timeout(_shutdownTimeout);
    }
  }

  static Future<void> dispose() {
    return _serialize(() async {
      await _stop();
    });
  }
}
