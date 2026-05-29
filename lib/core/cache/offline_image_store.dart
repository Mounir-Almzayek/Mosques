import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Abstraction over network image fetching, so the store is testable.
abstract class ImageDownloader {
  Future<Uint8List> download(String url);
}

class HttpImageDownloader implements ImageDownloader {
  @override
  Future<Uint8List> download(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Image download failed: ${res.statusCode}');
    }
    return res.bodyBytes;
  }
}

/// Persists data-tied images permanently under
/// `<appDocuments>/offline_images/`. Files are NOT auto-evicted; they only
/// disappear when [prune] removes URLs no longer present in the data, or via
/// [clear].
class OfflineImageStore {
  final ImageDownloader _downloader;
  final Directory? _baseDirOverride;
  Directory? _dir;
  OfflineImageStore({ImageDownloader? downloader, Directory? baseDirOverride})
      : _downloader = downloader ?? HttpImageDownloader(),
        _baseDirOverride = baseDirOverride;
  Future<void> init() async {
    final base = _baseDirOverride ?? await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/offline_images');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
  }
  Directory get _directory {
    final d = _dir;
    if (d == null) throw StateError('OfflineImageStore.init() must be called first');
    return d;
  }
  String _fileName(String url) {
    final hash = sha1.convert(utf8.encode(url)).toString();
    final ext = _extensionOf(url);
    return ext.isEmpty ? hash : '$hash$ext';
  }
  String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    final ext = path.substring(dot);
    return ext.length <= 5 ? ext : '';
  }
  File _fileObject(String url) => File('${_directory.path}/${_fileName(url)}');
  Future<File?> fileFor(String url) async {
    final f = _fileObject(url);
    return await f.exists() ? f : null;
  }
  Future<File> fetchAndStore(String url) async {
    final existing = await fileFor(url);
    if (existing != null) return existing;
    final bytes = await _downloader.download(url);
    final f = _fileObject(url);
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }
  Future<void> prune(Set<String> keepUrls) async {
    final keepNames = keepUrls.map(_fileName).toSet();
    if (!await _directory.exists()) return;
    await for (final entity in _directory.list()) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (!keepNames.contains(name)) {
          try { await entity.delete(); } catch (_) {}
        }
      }
    }
  }
  Future<void> clear() async {
    if (!await _directory.exists()) return;
    await for (final entity in _directory.list()) {
      if (entity is File) {
        try { await entity.delete(); } catch (_) {}
      }
    }
  }
}
