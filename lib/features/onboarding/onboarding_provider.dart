import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  final int _totalPages = 3;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLastPage => _currentPage == _totalPages - 1;

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void reset() {
    _currentPage = 0;
    notifyListeners();
  }
}
