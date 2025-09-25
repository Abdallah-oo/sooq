import 'package:flutter/material.dart';
import 'package:market_salla/shared/sectionname.dart';

class Customcategory extends StatefulWidget {
  const Customcategory({super.key, required this.catchindex});
  final Function(int) catchindex;

  @override
  State<Customcategory> createState() => _CustomcategoryState();
}

class _CustomcategoryState extends State<Customcategory> {
  int select = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            "Sections",
            style: TextStyle(
              fontSize: 19,
              color: Color.fromARGB(255, 8, 8, 8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: List.generate(itemslist.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        select = index;
                      });
                      widget.catchindex(index);
                    },
                    child: Container(
                      height: 90,
                      width: 90,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffF6F6F6),
                      ),
                      child: Image.asset(
                        itemslist[index].image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    itemslist[index].name,
                    style: select == index
                        ? TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 38, 199, 6),
                            fontWeight: FontWeight.bold,
                          )
                        : TextStyle(fontSize: 13, color: Color(0xff5a5555)),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
