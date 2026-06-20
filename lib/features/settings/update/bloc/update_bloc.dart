import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/enums/update/update_status.dart';
import '../../../../core/utils/async_runner.dart';

part 'update_event.dart';
part 'update_state.dart';

// --- Bloc ---
class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final AsyncRunner<String> _downloadRunner = AsyncRunner();
  final AsyncRunner<void> _installRunner = AsyncRunner();

  UpdateBloc() : super(const UpdateState()) {
    on<DownloadUpdateRequested>(_onDownload);
    on<InstallUpdateRequested>(_onInstall);
  }

  Future<void> _onDownload(
    DownloadUpdateRequested event,
    Emitter<UpdateState> emit,
  ) async {
    await _downloadRunner.run(
      checkConnectivity: false,
      onlineTask: (_) async {
        final tempDir = await getTemporaryDirectory();
        final fileName = event.url.split('/').last.split('?').first;
        final savePath = '${tempDir.path}/$fileName';

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(event.url));
          final response = await request.close();

          final contentLength = response.contentLength;
          int received = 0;

          final file = File(savePath);
          final sink = file.openWrite();
          await for (final chunk in response) {
            sink.add(chunk);
            received += chunk.length;
            if (contentLength > 0) {
              emit(state.copyWith(progress: received / contentLength));
            }
          }
          await sink.close();
        } finally {
          client.close();
        }
        return savePath;
      },
      onStart: () => emit(
        state.copyWith(
          status: UpdateStatus.downloading,
          progress: 0,
          error: null,
        ),
      ),
      onSuccess: (savePath) {
        emit(state.copyWith(status: UpdateStatus.success, localPath: savePath));
        add(InstallUpdateRequested());
      },
      // The UI falls back to a generic message when [error] is null.
      onError: (_) =>
          emit(state.copyWith(status: UpdateStatus.failure, error: null)),
    );
  }

  Future<void> _onInstall(
    InstallUpdateRequested event,
    Emitter<UpdateState> emit,
  ) async {
    final path = state.localPath;
    if (path == null) return;
    await _installRunner.run(
      checkConnectivity: false,
      onlineTask: (_) async {
        final result = await OpenFilex.open(path);
        if (result.type != ResultType.done) {
          throw Exception('Unable to open installer: ${result.message}');
        }
      },
      // The UI falls back to a generic message when [error] is null.
      onError: (_) =>
          emit(state.copyWith(status: UpdateStatus.failure, error: null)),
    );
  }

  @override
  Future<void> close() {
    _downloadRunner.cancel();
    _installRunner.cancel();
    return super.close();
  }
}
