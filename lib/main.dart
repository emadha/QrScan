import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'color_schemes.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const MyHomePage(title: 'QR Code Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController urlInputController = TextEditingController(text: "");
  final TextEditingController phoneInputController = TextEditingController(text: "");
  final TextEditingController textInputController = TextEditingController(text: "");
  final TextEditingController emailInputController = TextEditingController(text: "");
  final TextEditingController appInputController = TextEditingController(text: "");
  final TextEditingController twitterInputController = TextEditingController(text: "");

  /// * Location input Controller *
  final TextEditingController locationLongInputController = TextEditingController(text: "");
  final TextEditingController locationLatInputController = TextEditingController(text: "");

  /// * Wifi input Controller *
  final TextEditingController wifiSSIDInputController = TextEditingController(text: "");
  final TextEditingController wifiPasswordInputController = TextEditingController(text: "");
  final TextEditingController wifiEncTypeInputController = TextEditingController(text: "");

  final TextEditingController finalInputController = TextEditingController(text: "");

  final CarouselController itemsCarouselController = CarouselController();
  int selectedType = 0;

  final GlobalKey qrKey = GlobalKey();

  final List<String> qrCodeFormats = [
    "URL",
    "WIFI",
    "PHONE",
    "EMAIL",
    "TEXT",
    "CONTACT",
    "CALENDAR",
    "VCARD",
    "ISBN",
    "UPC",
    "LOCATION",
    "TWITTER",
    "APP",
  ];

  static const int TYPE_URL = 0;
  static const int TYPE_WIFI = 1;
  static const int TYPE_PHONE = 2;
  static const int TYPE_EMAIL = 3;
  static const int TYPE_TEXT = 4;
  static const int TYPE_CONTACT = 5;
  static const int TYPE_CALENDAR = 6;
  static const int TYPE_VCARD = 7;
  static const int TYPE_ISBN = 8;
  static const int TYPE_UPC = 9;
  static const int TYPE_LOCATION = 10;
  static const int TYPE_TWITTER = 11;
  static const int TYPE_APP = 12;

  List<Widget> getInputsForType({required int type}) {
    List<Widget> widgetsList = [];

    switch (type) {
      case TYPE_URL:
        {
          widgetsList.add(TextFormField(
            controller: urlInputController,
            enableSuggestions: true,
            onChanged: (value) => setState(() {}),
            decoration:
                const InputDecoration(labelText: "URL here", hintText: "Enter URL value here", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          break;
        }
      case TYPE_WIFI:
        {
          widgetsList.add(TextFormField(
            maxLines: 1,
            controller: wifiSSIDInputController,
            onChanged: (value) => setState(() {}),
            decoration:
                const InputDecoration(hintText: "SSID (Your network name)", labelText: "SSID", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          widgetsList.add(const SizedBox(height: 10));
          widgetsList.add(TextFormField(
            controller: wifiPasswordInputController,
            onChanged: (value) => setState(() {}),
            decoration: const InputDecoration(hintText: "Password", labelText: "Password", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));

          break;
        }
      case TYPE_PHONE:
        {
          widgetsList.add(TextFormField(
            keyboardType: TextInputType.phone,
            controller: phoneInputController,
            onChanged: (value) => setState(() {
              finalInputController.text = "tel:$value";
            }),
            decoration: const InputDecoration(hintText: "Phone Number", labelText: "Phone", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          break;
        }
      case TYPE_EMAIL:
        {
          widgetsList.add(TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailInputController,
            onChanged: (value) => setState(() {
              finalInputController.text = "mailto:$value";
            }),
            decoration:
                const InputDecoration(hintText: "Enter e-mail address", labelText: "E-Mail", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          break;
        }
      case TYPE_TEXT:
        {
          widgetsList.add(TextFormField(
            maxLines: 5,
            keyboardType: TextInputType.emailAddress,
            controller: emailInputController,
            onChanged: (value) => setState(() {
              finalInputController.text = value;
            }),
            decoration: const InputDecoration(
                hintText: "Enter text content here...", labelText: "Content", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          break;
        }
      case TYPE_APP:
        {
          widgetsList.add(TextFormField(
            controller: appInputController,
            onChanged: (value) => setState(() {
              finalInputController.text = "market://$value";
            }),
            decoration: const InputDecoration(
                hintText: "Enter the name identifier of the app",
                labelText: "Identifier (e.g. com.example.app)",
                border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          break;
        }
      case TYPE_TWITTER:
        {
          widgetsList.add(TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: twitterInputController,
            onChanged: (value) => setState(() {
              finalInputController.text = "twitter://user?screen_name=$value";
            }),
            decoration:
                const InputDecoration(hintText: "Twitter username...", labelText: "Username", border: OutlineInputBorder(borderSide: BorderSide())),
            style: const TextStyle(),
          ));
          break;
        }
      default:
        {}
    }

    return widgetsList;
  }

  @override
  Widget build(BuildContext context) {
    print(qrCodeFormats);
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 100, left: 50),
              child: Text("",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w100,
                    fontSize: 20,
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  QrImageView(
                    data: finalInputController.text,
                    version: QrVersions.auto,
                    dataModuleStyle: const QrDataModuleStyle(color: Colors.white70),
                    eyeStyle: const QrEyeStyle(
                      color: Colors.white60,
                      eyeShape: QrEyeShape.square,
                    ),
                    gapless: true,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    child: CarouselSlider(
                      carouselController: itemsCarouselController,
                      options: CarouselOptions(
                          onPageChanged: (index, reason) {
                            setState(() {
                              selectedType = index;
                            });
                          },
                          height: 32.0,
                          enlargeCenterPage: true,
                          viewportFraction: .4),
                      items: qrCodeFormats.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  i,
                                  style: GoogleFonts.poppins(
                                      fontSize: 23, fontWeight: (i == qrCodeFormats[selectedType] ? FontWeight.w900 : FontWeight.w300)),
                                ));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(children: getInputsForType(type: selectedType)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 50, top: 50),
              decoration: const BoxDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () {},
                        shape: const Border(bottom: BorderSide(color: Colors.white30)),
                        textColor: Colors.white,
                        child: const Text("Generate"),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        shape: const Border(bottom: BorderSide(color: Colors.black54)),
                        textColor: Colors.white,
                        child: const Text("Scan"),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
