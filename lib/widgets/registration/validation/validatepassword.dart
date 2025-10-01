import 'package:flutter/material.dart';

class Checkpassword extends StatelessWidget {
  final bool iseightcharcter;
  final bool special;
  final bool upper;
  final bool lower;
  final bool onenumber;
  const Checkpassword(
    this.iseightcharcter,
    this.special,
    this.upper,
    this.lower,
    this.onenumber, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iseightcharcter
                    ? const Color.fromARGB(255, 4, 170, 45)
                    : const Color.fromARGB(255, 255, 255, 255), //change this
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 153, 148, 148),
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Color.fromARGB(255, 252, 252, 252),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'At Least 8 characters',
              style: TextStyle(
                fontSize: 10,
                color: Color.fromARGB(255, 229, 243, 37),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: special ? Colors.white : Colors.green, //changethis
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 153, 148, 148),
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Color.fromARGB(255, 252, 252, 252),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Has Special Character',
              style: TextStyle(
                fontSize: 10,
                color: Color.fromARGB(255, 229, 243, 37),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: upper ? Colors.white : Colors.green, //changethis
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 153, 148, 148),
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Color.fromARGB(255, 252, 252, 252),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Has Upper Case',
              style: TextStyle(
                fontSize: 10,
                color: Color.fromARGB(255, 229, 243, 37),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: lower ? Colors.white : Colors.green, //change this
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 153, 148, 148),
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Color.fromARGB(255, 252, 252, 252),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Has Lower Case',
              style: TextStyle(
                fontSize: 10,
                color: Color.fromARGB(255, 229, 243, 37),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: onenumber ? Colors.white : Colors.green, //change this
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 153, 148, 148),
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Color.fromARGB(255, 252, 252, 252),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Has One Number',
              style: TextStyle(
                fontSize: 10,
                color: Color.fromARGB(255, 229, 243, 37),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
