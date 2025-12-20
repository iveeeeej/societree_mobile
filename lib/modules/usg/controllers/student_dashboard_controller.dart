import 'package:get/get.dart';

class StudentDashboardController extends GetxController {
  // Reactive variables
  final isCardExpanded = false.obs;
  final isMenuOpen = false.obs;

  // Actions
  void toggleCardExpansion() {
    isCardExpanded.toggle();
  }

  void toggleMenuState(bool isOpen) {
    isMenuOpen.value = isOpen;
  }
}