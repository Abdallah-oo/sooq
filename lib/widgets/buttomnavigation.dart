import 'package:flutter/material.dart';

class ButtomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ButtomNavigation(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, IconData>> icons = [
      {"select": Icons.home_filled, "unselect": Icons.home_outlined},
      {"select": Icons.favorite, "unselect": Icons.favorite_outline},
      {"select": Icons.search, "unselect": Icons.search_outlined},
      {"select": Icons.person, "unselect": Icons.person_outline_sharp},
      {"select": Icons.menu, "unselect": Icons.menu_outlined},
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(15, 17, 15, 0),
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 248, 248),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(icons.length, (index) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  onItemTapped(index);
                },
                icon: Icon(
                  selectedIndex == index
                      ? icons[index]["select"]
                      : icons[index]["unselect"],
                  size: 28,
                  color: selectedIndex == index
                      ? const Color.fromARGB(255, 32, 184, 18)
                      : Colors.black,
                ),
              ),
              selectedIndex == index
                  ? Positioned(
                      left: 5,
                      top: -20,
                      child: Container(
                        height: 3,
                        width: 40,
                        color: const Color.fromARGB(255, 19, 192, 34),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          );
        }),
      ),
    );
  }
}
