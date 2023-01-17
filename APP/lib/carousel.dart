import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// 메인 페이지의 하단 광고바를 구성하는 위젯
class carousel extends StatelessWidget {
  carousel({Key? key}) : super(key: key);

  final imageList = [
    Image.asset('assets/image1.jpg', fit: BoxFit.cover),
    Image.asset('assets/image2.jpg', fit: BoxFit.cover),
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: false,
        initialPage: 0,
        viewportFraction: 1.0,
        //enlargeFactor: 1.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
      ),
      items: imageList.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: image,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
