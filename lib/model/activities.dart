import 'package:flutter/material.dart';
import 'package:stust_app/constats/constants.dart';

import 'package:url_launcher/url_launcher.dart';
import '../rwd_module/responsive.dart';

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
            height: height * .2,
            width: isMobile(context) ? width * .3 : width * .2,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                        fit: BoxFit.scaleDown,
                        height: height * .13,
                        image: NetworkImage(widget.image))),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.topic,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 137, 36, 36),
                      fontSize: 12.5,
                      fontFamily: Bold),
                ),
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
          )),
    );
  }
}
