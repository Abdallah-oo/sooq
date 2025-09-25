import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/screens/icons/cart.dart';

import 'package:market_salla/shared/sectionname.dart';
import 'package:market_salla/widgets/category.dart';
import 'package:market_salla/widgets/dialog_seeall.dart';
import 'package:market_salla/widgets/product.dart';
import 'package:market_salla/widgets/salla/salla.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int reseveindex = 0;
  List<String> banner = [
    "assets/img/panner/Slider 1.png",
    "assets/img/panner/Slider 2.png",
    "assets/img/panner/Slider 3.png",
  ];

  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("assets/img/icons/delivery.png"),
            SizedBox(width: 25),
            Text(
              "61 Hopper street..",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Icon(Icons.keyboard_arrow_down_sharp),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cart()),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    "assets/img/icons/basket.png",
                    color: Color.fromARGB(255, 26, 25, 25),

                    width: 30,
                  ),
                  instance.salla.isNotEmpty
                      ? Positioned(
                          top: -7,
                          right: -3,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 119, 224, 78),
                            ),
                            child: Text(
                              "${instance.salla.length}",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              CarouselSlider.builder(
                itemCount: banner.length,
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) =>
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: Image.asset(
                            banner[index],
                            fit: BoxFit.fill,
                            width: 1000.0,
                          ),
                        ),
                options: CarouselOptions(
                  height: 222,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                ),
              ),
              SizedBox(height: 60),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Customcategory(
                        catchindex: (p) {
                          setState(() {
                            reseveindex = p;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemslist[reseveindex].name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff0A0B0A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Seeall(reseveindex: reseveindex);
                              },
                            );
                          },
                          child: Text(
                            "see all",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0CA201),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Customproduct(selectedIndex: reseveindex),
                        ),
                        Salla(basket: instance.salla),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
