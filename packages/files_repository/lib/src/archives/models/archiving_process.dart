class ArchivingProcess {
  final int pid;
  final Future<String> archivingFuture;

  ArchivingProcess({
    required this.pid,
    required this.archivingFuture,
  });
}
