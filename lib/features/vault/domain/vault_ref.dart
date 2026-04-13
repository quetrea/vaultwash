import 'package:path/path.dart' as p;

class VaultRef {
  const VaultRef({required this.absolutePath, required this.name});

  factory VaultRef.fromPath(String path) {
    final normalizedPath = p.normalize(path);
    final name = p.basename(normalizedPath);

    return VaultRef(
      absolutePath: normalizedPath,
      name: name.isEmpty ? normalizedPath : name,
    );
  }

  final String absolutePath;
  final String name;
}
