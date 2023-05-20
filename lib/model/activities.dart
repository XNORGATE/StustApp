import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stust_app/constats/constants.dart';

import 'package:url_launcher/url_launcher.dart';

class ActivitiesScreen extends StatefulWidget {
  final String href, image, topic;
  const ActivitiesScreen({
    Key? key,
    required this.href,
    required this.image,
    required this.topic,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    // print(widget.topic);
    return InkWell(
      onTap: () {
        launchUrl(Uri.parse(widget.href),
            mode: LaunchMode.externalNonBrowserApplication);
      },
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(
            // height: height * .2,
            // width: isMobile(context) ? width * .3 : width * .2,
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: widget.image,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        // Image(
                        //     fit: BoxFit.cover,
                        //     width: 130,
                        //     height: 80,
                        //     image: NetworkImage(widget.image))
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image(
                                      fit: BoxFit.cover,
                                      width: 130,
                                      height: 80,
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
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.topic,
                                style: const TextStyle(
                                    color: Color(0xff323232),
                                    fontSize: 13,
                                    fontFamily: Bold),
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       " ${widget.rating}",
                              //       style: const TextStyle(
                              //           color: Color(0xff323232),
                              //           fontSize: 11,
                              //           fontFamily: Bold),
                              //     ),
                              //     RatingBarIndicator(
                              //       rating: 2.75,
                              //       itemBuilder: (context, index) => const Icon(
                              //         Icons.star,
                              //         color: Colors.amber,
                              //       ),
                              //       itemCount: 1,
                              //       itemSize: 18.0,
                              //       direction: Axis.horizontal,
                              //     ),
                              //     Text(
                              //       "  (${widget.totalRating})",
                              //       style: const TextStyle(
                              //           color: Color(0xffa9a9a9),
                              //           fontSize: 11,
                              //           fontFamily: Light),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                          // const SizedBox(
                          //   height: 3,
                          // ),
                          // const SizedBox(
                          //   height: 3,
                          // ),
                          // Text(
                          //   r"$" "${widget.price} • " + widget.foodType,
                          //   style: const TextStyle(
                          //       color: Color(0xff707070),
                          //       fontSize: 11,
                          //       fontFamily: Regular),
                          // ),
                          // const SizedBox(
                          //   height: 3,
                          // ),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     const Icon(
                          //       Icons.two_wheeler_outlined,
                          //       size: 16,
                          //       color: Color.fromARGB(255, 110, 109, 110),
                          //     ),
                          //     Text(
                          //       "  (${widget.time})",
                          //       style: const TextStyle(
                          //           color: Color(0xff707070),
                          //           fontSize: 11,
                          //           fontFamily: Regular),
                          //     ),
                          //   ],
                          // )
                        ],
                      )
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       widget.name,
                      //       style: const TextStyle(
                      //           color: Color(0xff323232),
                      //           fontSize: 17,
                      //           fontFamily: Bold),
                      //     ),
                      //     Row(
                      //       children: [
                      //         Text(
                      //           " ${widget.rating}",
                      //           style: const TextStyle(
                      //               color: Color(0xff323232),
                      //               fontSize: 15,
                      //               fontFamily: Bold),
                      //         ),
                      //         RatingBarIndicator(
                      //           rating: 2.75,
                      //           itemBuilder: (context, index) => const Icon(
                      //             Icons.star,
                      //             color: Colors.amber,
                      //           ),
                      //           itemCount: 1,
                      //           itemSize: 19.0,
                      //           direction: Axis.horizontal,
                      //         ),

                      //         Text(
                      //           "  (${widget.totalRating})",
                      //           style: const TextStyle(
                      //               color: Color(0xffa9a9a9),
                      //               fontSize: 15,
                      //               fontFamily: Light),
                      //         ),
                      //       ],
                      //     )
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 3,
                      // ),
                      // const SizedBox(
                      //   height: 3,
                      // ),
                      // Text(
                      //   r"$" "${widget.price} • " + widget.foodType,
                      //   style: const TextStyle(
                      //       color: Color(0xff707070),
                      //       fontSize: 15,
                      //       fontFamily: Regular),
                      // ),
                      // const SizedBox(
                      //   height: 3,
                      // ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     const Icon(
                      //       Icons.two_wheeler_outlined,
                      //       size: 20,
                      //       color: Color.fromARGB(255, 110, 109, 110),
                      //     ),
                      //     Text(
                      //       "  (${widget.time})",
                      //       style: const TextStyle(
                      //           color: Color(0xff707070),
                      //           fontSize: 15,
                      //           fontFamily: Regular),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ]),
          )),
    );
  }
}
