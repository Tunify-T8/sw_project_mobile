import 'package:flutter/material.dart';

PreferredSizeWidget editScreenAppBar({
  required String title,
  required VoidCallback onClose,
  required VoidCallback onSave,
  bool isBusy = false,
  bool saveEnabled = true,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    backgroundColor: Colors.black,
    leading: IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: onClose,
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: isBusy
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: saveEnabled ? onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white24,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ),
    ],
    bottom: bottom,
  );
}
