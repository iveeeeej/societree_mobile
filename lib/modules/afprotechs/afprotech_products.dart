import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AfprotechProductsScreen extends StatefulWidget {
  final bool showHeader;

  const AfprotechProductsScreen({super.key, this.showHeader = true});

  @override
  State<AfprotechProductsScreen> createState() => _AfprotechProductsScreenState();
}

class _AfprotechProductsScreenState extends State<AfprotechProductsScreen> {
  final Color navyBlue = const Color(0xFF000080);
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    Color scaffoldBg = isDarkMode ? Colors.black : Colors.white;
    Color mainColor = isDarkMode ? Colors.white : navyBlue;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    Widget content = widget.showHeader
        ? SafeArea(
            child: Column(
              children: [
                // HEADER AREA
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button (arrow)
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: navyBlue),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Logo & Title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ASSOCIATION OF FOOD PROCESSING",
                            style: TextStyle(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "AND TECHNOLOGY STUDENTS",
                            style: TextStyle(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // MAIN CONTENT SCROLL
                Expanded(child: _buildContent(textColor, mainColor)),
              ],
            ),
          )
        : _buildContent(textColor, mainColor);

    return Scaffold(backgroundColor: scaffoldBg, body: content);
  }

  Widget _buildContent(Color textColor, Color mainColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSearchBar(textColor, mainColor),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _buildCartIcon(textColor, mainColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular Products",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('See more Popular Products coming soon!'),
                        backgroundColor: mainColor,
                      ),
                    );
                  },
                  child: Text(
                    "See More",
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProductGrid(textColor, mainColor),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Desserts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('See more Desserts coming soon!'),
                        backgroundColor: mainColor,
                      ),
                    );
                  },
                  child: Text(
                    "See More",
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDessertsGrid(textColor, mainColor),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Snacks / Merienda",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('See more Snacks / Merienda coming soon!'),
                        backgroundColor: mainColor,
                      ),
                    );
                  },
                  child: Text(
                    "See More",
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSnacksGrid(textColor, mainColor),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Drinks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('See more Drinks coming soon!'),
                        backgroundColor: mainColor,
                      ),
                    );
                  },
                  child: Text(
                    "See More",
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDrinksGrid(textColor, mainColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Search products...",
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: mainColor,
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: mainColor,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Filter functionality coming soon!'),
                  backgroundColor: mainColor,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          // Handle search functionality
          // This can be implemented later with actual product filtering
        },
      ),
    );
  }

  Widget _buildProductGrid(Color textColor, Color mainColor) {
    // Featured product data (only 4 items)
    final List<Map<String, String>> products = [
      {
        'name': 'Product 1',
        'price': '₱299.00',
        'image': '🍎',
      },
      {
        'name': 'Product 2',
        'price': '₱199.00',
        'image': '🥖',
      },
      {
        'name': 'Product 3',
        'price': '₱399.00',
        'image': '🧀',
      },
      {
        'name': 'Product 4',
        'price': '₱149.00',
        'image': '🥛',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 16,
              right: index == products.length - 1 ? 0 : 0,
            ),
            child: SizedBox(
              width: 180,
              child: _buildProductCard(product, textColor, mainColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product, Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildDessertsGrid(Color textColor, Color mainColor) {
    // Dessert product data
    final List<Map<String, String>> desserts = [
      {
        'name': 'Dessert 1',
        'price': '₱150.00',
        'image': '🍰',
      },
      {
        'name': 'Dessert 2',
        'price': '₱120.00',
        'image': '🧁',
      },
      {
        'name': 'Dessert 3',
        'price': '₱180.00',
        'image': '🍪',
      },
      {
        'name': 'Dessert 4',
        'price': '₱200.00',
        'image': '🍩',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: desserts.length,
        itemBuilder: (context, index) {
          final dessert = desserts[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 16,
              right: index == desserts.length - 1 ? 0 : 0,
            ),
            child: SizedBox(
              width: 180,
              child: _buildDessertCard(dessert, textColor, mainColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDessertCard(Map<String, String> dessert, Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildSnacksGrid(Color textColor, Color mainColor) {
    // Snacks/Merienda product data
    final List<Map<String, String>> snacks = [
      {
        'name': 'Chips',
        'price': '₱25.00',
        'image': '🍟',
      },
      {
        'name': 'Crackers',
        'price': '₱30.00',
        'image': '🍘',
      },
      {
        'name': 'Nuts',
        'price': '₱45.00',
        'image': '🥜',
      },
      {
        'name': 'Popcorn',
        'price': '₱35.00',
        'image': '🍿',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: snacks.length,
        itemBuilder: (context, index) {
          final snack = snacks[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 16,
              right: index == snacks.length - 1 ? 0 : 0,
            ),
            child: SizedBox(
              width: 180,
              child: _buildSnackCard(snack, textColor, mainColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSnackCard(Map<String, String> snack, Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildDrinksGrid(Color textColor, Color mainColor) {
    // Drinks product data
    final List<Map<String, String>> drinks = [
      {
        'name': 'Coffee',
        'price': '₱50.00',
        'image': '☕',
      },
      {
        'name': 'Juice',
        'price': '₱40.00',
        'image': '🧃',
      },
      {
        'name': 'Soda',
        'price': '₱35.00',
        'image': '🥤',
      },
      {
        'name': 'Water',
        'price': '₱20.00',
        'image': '💧',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: drinks.length,
        itemBuilder: (context, index) {
          final drink = drinks[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 16,
              right: index == drinks.length - 1 ? 0 : 0,
            ),
            child: SizedBox(
              width: 180,
              child: _buildDrinkCard(drink, textColor, mainColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrinkCard(Map<String, String> drink, Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildCartIcon(Color textColor, Color mainColor) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cart feature coming soon!'),
            backgroundColor: mainColor,
          ),
        );
      },
      child: FaIcon(
        FontAwesomeIcons.cartShopping,
        color: mainColor,
        size: 24,
      ),
    );
  }
}