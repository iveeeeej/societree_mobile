import 'package:get/get.dart';

class StudentDashboardController extends GetxController {
  // Only keep card expansion state here
  final isCardExpanded = false.obs;
  final isMenuOpen = false.obs;

  // Toggle card expansion
  void toggleCardExpansion() {
    isCardExpanded.toggle();
  }

  void toggleMenuState(bool isOpen) {
    isMenuOpen.value = isOpen;
  }
}