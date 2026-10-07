class ContactPermissionDenied implements Exception {
  const ContactPermissionDenied({required this.permanent});

  final bool permanent;
}
