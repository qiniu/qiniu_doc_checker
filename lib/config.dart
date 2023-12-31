import 'dart:io';

import 'package:qiniu_doc_checker/logger.dart';
import 'package:yaml/yaml.dart';

class QiniuLoggerConfiguration {
  final LogLevel level;
  final bool showStackTrace;

  QiniuLoggerConfiguration({
    LogLevel? level,
    bool? showStackTrace,
  })  : level = level ?? LogLevel.info,
        showStackTrace = showStackTrace ?? false;
}

class QiniuDocumentCheckerConfiguration {
  final String workingDirectory;
  final List<String> urlList;
  final String userAgent;
  final QiniuLoggerConfiguration logger;

  QiniuDocumentCheckerConfiguration({
    String? workingDirectory,
    List<String>? urlList,
    String? userAgent,
    QiniuLoggerConfiguration? logger,
  })  : workingDirectory = (() {
          final result = workingDirectory ?? '${Directory.current.path}/workdir';
          return result;
        })(),
        urlList = urlList ?? [],
        userAgent = userAgent ??
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4658.0 Safari/537.36',
        logger = logger ?? QiniuLoggerConfiguration();

  static Future<QiniuDocumentCheckerConfiguration> fromYaml(String yaml) async {
    final content = await File(yaml).readAsString();
    final yamlDoc = loadYaml(content);
    return QiniuDocumentCheckerConfiguration(
      workingDirectory: yamlDoc['workingDirectory'],
      urlList: (yamlDoc['urlList'] as YamlList).toList().cast<String>(),
      userAgent: yamlDoc['userAgent'],
      logger: () {
        final map = (yamlDoc['logger'] as YamlMap).cast<String, dynamic>();
        return QiniuLoggerConfiguration(
          level: LogLevel.values.firstWhere(
            (e) => e.name.toUpperCase() == map['level'].toString().toUpperCase(),
          ),
          showStackTrace: map['showStackTrace'],
        );
      }(),
    );
  }
}
