import 'package:flutter/material.dart';

class ChildState extends ChangeNotifier {
  int _anakId = 0;
  String _namaAnak = '';
  String _jenisKelamin = '';

  int get anakId => _anakId;
  String get namaAnak => _namaAnak;
  String get jenisKelamin => _jenisKelamin;

  void updateChild(int id, String nama, String jk) {
    _anakId = id;
    _namaAnak = nama;
    _jenisKelamin = jk;
    notifyListeners();
  }
}
