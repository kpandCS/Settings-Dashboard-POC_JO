import 'package:flutter/material.dart';
import '../model/dashboard_data.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardData _data = DashboardData.mock();
  bool _isRefreshing = false;

  DashboardData get data => _data;
  bool get isRefreshing => _isRefreshing;

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _data = DashboardData.mock();
    _isRefreshing = false;
    notifyListeners();
  }
}
