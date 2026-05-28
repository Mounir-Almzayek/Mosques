import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/enums/update/update_status.dart';

part 'update_event.dart';
part 'update_state.dart';

// --- Bloc ---
class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  UpdateBloc() : super(const UpdateState()) {
    on<DownloadUpdateRequested>(_onDownload);
    on<InstallUpdateRequested>(_onInstall);
  }

  Future<void> _onDownload(
    DownloadUpdateRequested event,
    Emitter<UpdateState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UpdateStatus.downloading,
        progress: 0,
        error: null,
      ),
    );
    try {
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

      emit(state.copyWith(status: UpdateStatus.success, localPath: savePath));
      add(InstallUpdateRequested());
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateStatus.failure,
          error: 'Download failed: $e',
        ),
      );
    }
  }

  Future<void> _onInstall(
    InstallUpdateRequested event,
    Emitter<UpdateState> emit,
  ) async {
    if (state.localPath == null) return;
    try {
      final result = await OpenFilex.open(state.localPath!);
      if (result.type != ResultType.done) {
        emit(
          state.copyWith(
            status: UpdateStatus.failure,
            error: 'Install failed: ${result.message}',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateStatus.failure,
          error: 'Install error: $e',
        ),
      );
    }
  }
}
