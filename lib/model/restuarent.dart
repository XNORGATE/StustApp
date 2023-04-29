import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:stust_app/constats/constants.dart';

import 'package:url_launcher/url_launcher.dart';
import '../rwd_module/responsive.dart';
class RestuarentScreen extends StatefulWidget {
  final String name, image, time, foodType, rating, link, totalRating, price;
  const RestuarentScreen(
      {Key? key,
      required this.name,
      required this.image,
      required this.time,
      required this.rating,
      required this.link,
      required this.totalRating,
      required this.foodType,
      required this.price})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestuarentScreenState createState() => _RestuarentScreenState();
}

class _RestuarentScreenState extends State<RestuarentScreen> {
 
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return InkWell(
      onTap: ()  {
       launchUrl(Uri.parse(widget.link));
   
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: SizedBox(
            height: height * .2,
            width: isMobile(context) ? width * .3 : width * .2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(
                                fit: BoxFit.fill,
                                height: height * .13,
                                image: NetworkImage(widget.image))),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 15),
                        //   child: Container(
                        //     decoration: const BoxDecoration(
                        //         color: MyColors.primaryColor,
                        //         borderRadius: BorderRadius.only(
                        //           topRight: Radius.circular(20),
                        //           bottomRight: Radius.circular(20),
                        //         )),
                        //     child: const Padding(
                        //       padding: EdgeInsets.only(
                        //           top: 7, left: 5, right: 10, bottom: 7),
                        //       child: Text(
                        //         "Flash 20% OFF",
                        //         style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 12,
                        //             fontFamily: Bold),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xfffffcff),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(
                                  widget.time,
                                  style: const TextStyle(
                                      color: blackColor,
                                      fontSize: 15,
                                      fontFamily: Bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                              color: Color(0xff323232),
                              fontSize: 17,
                              fontFamily: Bold),
                        ),
                        Row(
                          children: [
                            Text(
                              " ${widget.rating}",
                              style: const TextStyle(
                                  color: Color(0xff323232),
                                  fontSize: 15,
                                  fontFamily: Bold),
                            ),
                            RatingBarIndicator(
                              rating: 2.75,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 1,
                              itemSize: 19.0,
                              direction: Axis.horizontal,
                            ),
                            
                            Text(
                              "  (${widget.totalRating})",
                              style: const TextStyle(
                                  color: Color(0xffa9a9a9),
                                  fontSize: 15,
                                  fontFamily: Light),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      r"$" "${widget.price} • " + widget.foodType,
                      style: const TextStyle(
                          color: Color(0xff707070),
                          fontSize: 15,
                          fontFamily: Regular),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.two_wheeler_outlined,
                          size: 20,
                          color: Color.fromARGB(255, 110, 109, 110),
                        ),
                        Text(
                          "  (${widget.time})",
                          style: const TextStyle(
                              color: Color(0xff707070),
                              fontSize: 15,
                              fontFamily: Regular),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
