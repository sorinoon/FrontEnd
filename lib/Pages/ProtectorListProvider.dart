import 'package:flutter/material.dart';

class ProtectorListProvider extends ChangeNotifier {
  List<String> _protectorNames = ['최준희'];
  List<String> _contactNotes = ['010-2098-6403'];

  List<String> get protectorNames => _protectorNames;
  List<String> get contactNotes => _contactNotes;

  void moveItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;

    final name = _protectorNames.removeAt(oldIndex);
    _protectorNames.insert(newIndex, name);

    final contact = _contactNotes.removeAt(oldIndex);
    _contactNotes.insert(newIndex, contact);

    notifyListeners();
  }

  void deleteProtector(int index) {
    _protectorNames.removeAt(index);
    _contactNotes.removeAt(index);
    notifyListeners(); // 모든 리스너에게 알림
  }

  void addProtector(String name, String contact) {
    _protectorNames.add(name);
    _contactNotes.add(contact);
    notifyListeners();
  }
}