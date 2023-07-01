import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/_http/_io/_file_decoder_io.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ScreenGenerate extends StatefulWidget {
  const ScreenGenerate({Key? key}) : super(key: key);

  @override
  State<ScreenGenerate> createState() => _ScreenGenerateState();
}

class _ScreenGenerateState extends State<ScreenGenerate> with TickerProviderStateMixin {
  final List<String> dataTypes = [
    "TEXT",
    "WIFI",
    "PHONE",
    "EMAIL",
    "URL",
    "CONTACT",
    "CALENDAR",
//    "VCARD",
    "ISBN",
    "LOCATION",
  ];

  final List<IconData> dataTypeIcons = [
    Icons.text_decrease,
    Icons.wifi,
    Icons.phone,
    Icons.email_outlined,
    Icons.link,
    Icons.contact_page_outlined,
    Icons.calendar_month,
    Icons.card_giftcard,
    Icons.golf_course_outlined,
    Icons.location_pin,
  ];
  late TabController _tabController;
  late TabController _dataTabController;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _dataTabController = TabController(length: dataTypes.length, vsync: this);
    super.initState();
  }

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  final TextEditingController urlInputController = TextEditingController(text: "");
  final TextEditingController isbnInputController = TextEditingController(text: "");
  final TextEditingController phoneInputController = TextEditingController(text: "");
  final TextEditingController textInputController = TextEditingController(text: "");
  final TextEditingController emailInputController = TextEditingController(text: "");
  final TextEditingController appInputController = TextEditingController(text: "");
  final TextEditingController twitterInputController = TextEditingController(text: "");
  final TextEditingController _contactNameInputController = TextEditingController(text: "");
  final TextEditingController _contactNumberInputController = TextEditingController(text: "");

  /// * Location input Controller *
  final TextEditingController locationLongInputController = TextEditingController(text: "");
  final TextEditingController locationLatInputController = TextEditingController(text: "");

  /// * Wifi input Controller *
  final TextEditingController wifiNetworkNameInputController = TextEditingController(text: "");
  final TextEditingController wifiPasswordInputController = TextEditingController(text: "");
  final TextEditingController wifiAuthenticationTypeInputController = TextEditingController(text: "nopass");
  late bool wifiHiddenNetworkInputController = false;

  final TextEditingController finalInputController = TextEditingController(text: "Welcome!");

  int selectedType = 0;
  int qrErrorCorrectLevel = QrErrorCorrectLevel.M;
  QrEyeShape qrEyeShape = QrEyeShape.square;
  QrDataModuleShape qrDataModuleShape = QrDataModuleShape.square;

  final GlobalKey qrKey = GlobalKey();
  bool _isShareProcessing = false;
  final Map<String, String> TYPES_FORMATS = {
    'WIFI': 'WIFI:S:<network_name>;T:<authentication_type>;P:<password>;H:<hidden_network>',
  };

  static const int TYPE_TEXT = 0;
  static const int TYPE_WIFI = 1;
  static const int TYPE_PHONE = 2;
  static const int TYPE_EMAIL = 3;
  static const int TYPE_URL = 4;
  static const int TYPE_CONTACT = 5;
  static const int TYPE_CALENDAR = 6;

  //static const int TYPE_VCARD = 7;
  static const int TYPE_ISBN = 8;
  static const int TYPE_LOCATION = 9;

  void buildQrForWifi(value, String type) {
    String finalCode = TYPES_FORMATS["WIFI"]!
        .replaceFirst('S:<network_name>', "S:${wifiNetworkNameInputController.text}")
        .replaceFirst('T:<authentication_type>', "T:${wifiAuthenticationTypeInputController.text}")
        .replaceFirst('P:<password>', "P:${wifiPasswordInputController.text}")
        .replaceFirst('H:<hidden_network>', "H:${wifiHiddenNetworkInputController.toString()}");

    setState(() {
      print(finalCode);
      finalInputController.text = finalCode;
    });
  }

  Widget _createScrollViewForDataView({required String title, required String description, required Widget content}) {
    List<Widget> widgetsList = [];

    /*** Title */
    widgetsList.add(Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 25)));
    /*** Description */
    widgetsList.add(Text(description, style: GoogleFonts.poppins(fontSize: 12)));
    /*** Divider */
    widgetsList.add(const SizedBox(height: 15));
    /*** Content */
    widgetsList.add(content);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetsList.toList(),
      ),
    );
  }

  Widget getInputsForType({required int type}) {
    List<Widget> widgetsList = [];

    switch (type) {
      case TYPE_URL:
        _buildWidgetsListItemForTypeURL(widgetsList);
        break;

      case TYPE_WIFI:
        _buildWidgetsListItemForTypeWifi(widgetsList);
        break;

      case TYPE_PHONE:
        _buildWidgetsListItemForTypePhone(widgetsList);
        break;

      case TYPE_EMAIL:
        _buildWidgetsListItemForTypeEmail(widgetsList);
        break;

      case TYPE_TEXT:
        _buildWidgetsListItemForTypeText(widgetsList);
        break;
      case TYPE_CONTACT:
        _buildWidgetsListItemForTypeContact(widgetsList);
        break;
      case TYPE_CALENDAR:
        _buildWidgetsListItemForTypeCalendar(widgetsList);
        break;
      // case TYPE_VCARD:
      //   _buildWidgetsListItemForTypeVCard(widgetsList);
      //   break;
      case TYPE_ISBN:
        _buildWidgetsListItemForTypeISBN(widgetsList);
        break;
      case TYPE_LOCATION:
        _buildWidgetsListItemForTypeLocation(widgetsList);
        break;
      default:
        {}
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(children: widgetsList),
    );
  }

  void _buildWidgetsListItemForTypeText(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "Text",
        description: "Create a Raw Text QR Code, Text based QR code is the simplest mode of encryption, it has no features and no actions.",
        content: TextFormField(
          maxLines: 5,
          controller: textInputController,
          onChanged: (value) => setState(() {
            finalInputController.text = value;
          }),
          decoration: const InputDecoration(
              hintText: "Content",
              labelText: "Write some text here...",
              border: OutlineInputBorder(borderSide: BorderSide()),
              floatingLabelAlignment: FloatingLabelAlignment.start),
          style: const TextStyle(),
        )));
  }

  void _buildWidgetsListItemForTypeWifi(List widgetsList) {
    List<Widget> wifiWidgetData = [
      TextFormField(
        controller: wifiNetworkNameInputController,
        onChanged: (value) => buildQrForWifi(value, 'network_name'),
        decoration:
            const InputDecoration(hintText: "SSID (Your network name)", labelText: "SSID", border: OutlineInputBorder(borderSide: BorderSide())),
        style: const TextStyle(),
      ),
      const SizedBox(height: 20),
      DropdownButtonFormField(
        value: "nopass",
        decoration: const InputDecoration(
          labelText: "Encryption Type",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        items: const [
          DropdownMenuItem(value: "WEP", child: Text("WEP")),
          DropdownMenuItem(value: "WPA", child: Text("WPA")),
          DropdownMenuItem(value: "WPA2", child: Text("WPA2")),
          DropdownMenuItem(value: "WPA3", child: Text("WPA3")),
          DropdownMenuItem(value: "nopass", child: Text("No Password")),
        ],
        onChanged: (value) {
          wifiAuthenticationTypeInputController.text = value.toString();

          if (value == "nopass") {
            wifiPasswordInputController.text = "";
          }

          buildQrForWifi(value, 'authentication_type');
        },
      ),
      const SizedBox(height: 20)
    ];

    if (wifiAuthenticationTypeInputController.text != 'nopass') {
      wifiWidgetData.add(TextFormField(
        controller: wifiPasswordInputController,
        onChanged: (value) => buildQrForWifi(value, 'password'),
        decoration: const InputDecoration(hintText: "Password", labelText: "Password", border: OutlineInputBorder(borderSide: BorderSide())),
        style: const TextStyle(),
      ));
      wifiWidgetData.add(const SizedBox(height: 20));
    }

    wifiWidgetData.add(
      SizedBox(
        child: CheckboxListTile(
          title: const Text("Is that network hidden?"),
          value: wifiHiddenNetworkInputController,
          onChanged: (bool? value) {
            setState(() {
              wifiHiddenNetworkInputController = value!;
              buildQrForWifi(value!, 'hidden_network');
            });
          },
        ),
      ),
    );

    widgetsList.add(_createScrollViewForDataView(
      title: "Wifi",
      description: "Wifi Format QR Code is a special type of QR Code made for sharing Wifi Credentials with other, an action such as "
          "Saving the connection could be available with the scanner to save the connection information.",
      content: Column(children: wifiWidgetData),
    ));
  }

  void _buildWidgetsListItemForTypePhone(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "Phone",
        description: "Easily share contacts with QR codes in phone format, Contacts QR Code is made specifically "
            "to share contacts by using QR codes, the scanner will contain actions specifically for contacts, such as Call or Save...",
        content: TextFormField(
          keyboardType: TextInputType.phone,
          controller: phoneInputController,
          onChanged: (value) => setState(() {
            finalInputController.text = "tel:$value";
          }),
          decoration: InputDecoration(
              prefixText: "tel:",
              suffix: TextButton(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                clipBehavior: Clip.hardEdge,
                onPressed: () async {
                  Contact? contact = await _contactPicker.selectContact();
                  setState(() {
                    if (contact != null) {
                      phoneInputController.text = contact.phoneNumbers![0];
                      finalInputController.text = "tel:${phoneInputController.text}";
                    }
                  });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Select from Contacts"),
                    Icon(
                      Icons.contacts,
                      size: 14,
                    ),
                  ],
                ),
              ),
              hintText: "Phone Number",
              labelText: "Phone",
              border: const OutlineInputBorder(
                borderSide: BorderSide(),
              )),
          style: const TextStyle(),
        )));
  }

  void _buildWidgetsListItemForTypeEmail(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "E-mail",
        description: "E-mail QR Code is a shortner for maileto:email, you can use to order the qr scanner apps to run a mailto action.",
        content: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailInputController,
          onChanged: (value) => setState(() {
            finalInputController.text = "mailto:$value";
          }),
          decoration:
              const InputDecoration(hintText: "Enter e-mail address", labelText: "E-Mail", border: OutlineInputBorder(borderSide: BorderSide())),
          style: const TextStyle(),
        )));
  }

  void _buildWidgetsListItemForTypeURL(List widgetsList) {
    widgetsList.add(
      _createScrollViewForDataView(
          title: "URL",
          description:
              "URL QR Codes were meant to share link through qr, a scanner will read and send the user to the link specified in the qr code.",
          content: Column(
            children: [
              TextFormField(
                controller: urlInputController,
                onChanged: (value) => setState(() => finalInputController.text = value),
                decoration: const InputDecoration(
                  labelText: "URL here",
                  hintText: "https://example.com",
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
                style: const TextStyle(),
              )
            ],
          )),
    );
  }

  void _buildWidgetsListItemForTypeContact(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "Contact",
        description:
            "Create a QR for one of your contacts, or any contact, by either choosing one of your phone contacts, or by manually providing the information. ",
        content: Column(
          children: [
            TextFormField(
              controller: _contactNameInputController,
              onChanged: (value) => setState(() {
                _contactNameInputController.text = value;
                finalInputController.text = "BEGIN:VCARD\n"
                    "VERSION:3.0\n"
                    "FN:${_contactNameInputController.text}\n"
                    "TEL;TYPE=home:${_contactNumberInputController.text}\n"
                    "END:VCARD";
              }),
              decoration: InputDecoration(
                labelText: "Name",
                hintText: "Joe Biden",
                border: const OutlineInputBorder(borderSide: BorderSide()),
                suffix: TextButton(
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  clipBehavior: Clip.hardEdge,
                  onPressed: () async {
                    Contact? contact = await _contactPicker.selectContact();
                    setState(() {
                      if (contact != null) {
                        _contactNameInputController.text = contact.fullName!;
                        _contactNumberInputController.text = contact.phoneNumbers![0];
                        finalInputController.text = "BEGIN:VCARD\n"
                            "VERSION:3.0\n"
                            "FN:${_contactNameInputController.text}\n"
                            "TEL;TYPE=home:${_contactNumberInputController.text}\n"
                            "END:VCARD";
                      }
                    });
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Select from Contacts"),
                      Icon(
                        Icons.contacts,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              style: const TextStyle(),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _contactNumberInputController,
              onChanged: (value) => setState(() {
                _contactNumberInputController.text = value;
                finalInputController.text = "BEGIN:VCARD\n"
                    "VERSION:3.0\n"
                    "FN:${_contactNameInputController.text}\n"
                    "TEL;TYPE=home:${_contactNumberInputController.text}\n"
                    "END:VCARD";
              }),
              decoration: const InputDecoration(
                labelText: "Number",
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
              style: const TextStyle(),
            ),
          ],
        )));
  }

  void _buildWidgetsListItemForTypeCalendar(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "Calendar", description: "Turn an event or a reminder into a Calendar item easily!", content: const Text("Contact")));
  }

  void _buildWidgetsListItemForTypeVCard(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "VCARD",
        description:
            "Create a QR for one of your contacts, or any contact, by either choosing one of your phone contacts, or by manually providing the information. ",
        content: const Text("Contact")));
  }

  void _buildWidgetsListItemForTypeISBN(List widgetsList) {
    widgetsList.add(
      _createScrollViewForDataView(
        title: "ISBN",
        description:
            " ISBN (International Standard Book Number) barcodes, the data format typically follows the structure of the ISBN itself. ISBNs are used to uniquely identify books and related products.",
        content: Column(
          children: [
            TextFormField(
              controller: isbnInputController,
              onChanged: (value) => setState(() => finalInputController.text = "ISBN:$value"),
              decoration: const InputDecoration(
                labelText: "ISBN (group-identifier-publisher-title-checksum)",
                hintText: "e.g. (xxx-x-xxxx-xxxx-x)",
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
              style: const TextStyle(),
            )
          ],
        ),
      ),
    );
  }

  void _buildWidgetsListItemForTypeApp(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "App",
        description: "Create QR Code which forwards to the app's store link.",
        content: TextFormField(
          controller: appInputController,
          onChanged: (value) => setState(() {
            finalInputController.text = "market://$value";
          }),
          decoration: const InputDecoration(
              hintText: "Enter the name identifier of the app",
              labelText: "Identifier (e.g. com.example.app)",
              border: OutlineInputBorder(borderSide: BorderSide())),
          style: const TextStyle(),
        )));
  }

  void _buildWidgetsListItemForTypeTwitter(List widgetsList) {
    widgetsList.add(_createScrollViewForDataView(
        title: "Twitter",
        description: "Create twitter profile forwarding link QR Code.",
        content: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: twitterInputController,
          onChanged: (value) => setState(() {
            finalInputController.text = "twitter://user?screen_name=$value";
          }),
          decoration:
              const InputDecoration(hintText: "Twitter username...", labelText: "Username", border: OutlineInputBorder(borderSide: BorderSide())),
          style: const TextStyle(),
        )));
  }

  void _buildWidgetsListItemForTypeLocation(List widgetsList) {
    return widgetsList.add(_createScrollViewForDataView(
        title: "Location",
        description:
            "Create Location pinpoint QR code easily, either by providing manual Longitude and Latitude values, or by selecting from the map.",
        content: Column(
          children: [
            TextFormField(
              controller: locationLongInputController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return "null";
              },
              onChanged: (value) => setState(() {
                finalInputController.text = "geo://${locationLatInputController.text},$value";
              }),
              decoration: const InputDecoration(hintText: "Longitude", labelText: "Longitude", border: OutlineInputBorder(borderSide: BorderSide())),
              style: const TextStyle(),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: locationLatInputController,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                finalInputController.text = "geo://$value,${locationLongInputController.text}";
              }),
              decoration: const InputDecoration(hintText: "Latitude", labelText: "Latitude", border: OutlineInputBorder(borderSide: BorderSide())),
              style: const TextStyle(),
            ),
          ],
        )));
  }

  final FlutterContactPicker _contactPicker = new FlutterContactPicker();

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(top:70,bottom: 30),
                color: Colors.black.withOpacity(.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [const BoxShadow(offset: Offset(0, 0), blurRadius: 2, color: Color(0x2F421400))],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Container(
                          color: Colors.white,
                          child: QrImageView(
                            data: finalInputController.text,
                            version: QrVersions.auto,
                            errorCorrectionLevel: qrErrorCorrectLevel,
                            dataModuleStyle: QrDataModuleStyle(
                              color: Get.isPlatformDarkMode ? Colors.white54 : Colors.black,
                              dataModuleShape: qrDataModuleShape,
                            ),
                            eyeStyle: QrEyeStyle(
                              color: Get.isPlatformDarkMode ? Colors.white70 : Colors.black,
                              eyeShape: qrEyeShape,
                            ),
                            gapless: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    MaterialButton(
                        onPressed: () async {
                          setState(() {
                            _isShareProcessing = true;
                          });

                          RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                          var image = await boundary.toImage(pixelRatio: 20);
                          ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                          Uint8List? pngBytes = byteData?.buffer.asUint8List();
                          Directory tempDir = await getTemporaryDirectory();
                          final ts = DateTime.now().millisecondsSinceEpoch.toString();
                          String path = "${tempDir.path}/$ts.jpg";
                          final file = await File(path).create();
                          await file.writeAsBytes(pngBytes!).then((value) async {
                            setState(() => _isShareProcessing = false);
                            await Share.shareXFiles(<XFile>[
                              XFile(
                                file.path,
                                bytes: pngBytes,
                                length: pngBytes.length,
                                mimeType: "image/png",
                                name: "QR",
                              )
                            ]);
                          }).whenComplete(() {});
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isShareProcessing
                                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator())
                                : Icon(
                                    Icons.share,
                                    color: Get.isPlatformDarkMode ? Colors.white : Colors.black,
                                    size: 20,
                                  ),
                            const SizedBox(width: 10),
                            Text(
                              "Share",
                              style: GoogleFonts.poppins(
                                color: Get.isPlatformDarkMode ? Colors.white : Colors.black,
                                fontSize: 32,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TabBar(
                  enableFeedback: true,
                  controller: _tabController,
                  indicatorWeight: .2,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  tabs: [
                    Row(children: [
                      Icon(Icons.data_array_rounded, color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
                      const SizedBox(
                        width: 10,
                        height: 40,
                      ),
                      Text(
                        "Data",
                        style: GoogleFonts.poppins(color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
                      )
                    ]),
                    Row(children: [
                      Icon(Icons.dashboard_customize, color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
                      const SizedBox(
                        width: 10,
                        height: 40,
                      ),
                      Text(
                        "Customize",
                        style: GoogleFonts.poppins(color: Get.isPlatformDarkMode ? Colors.white : Colors.black),
                      )
                    ]),
                  ],
                ),
              ),
              SizedBox(
                height: Get.height,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TabBar(
                            controller: _dataTabController,
                            isScrollable: true,
                            physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                            tabs: dataTypes
                                .map((e) => Row(children: [
                                      Icon(dataTypeIcons[dataTypes.indexOf(e)], size: 13),
                                      const SizedBox(
                                        width: 5,
                                        height: 25,
                                      ),
                                      Text(e, style: GoogleFonts.poppins(fontSize: 12)),
                                    ]))
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _dataTabController,
                            children: dataTypes.map((e) {
                              return getInputsForType(type: dataTypes.indexOf(e));
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                width: 170,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Eye Shape",
                                      softWrap: true,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    const Text(
                                      "Choose Eye shape from circular or square",
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: DropdownButtonFormField(
                                  value: qrEyeShape,
                                  items: const [
                                    DropdownMenuItem(child: Text("Circle"), value: QrEyeShape.circle),
                                    DropdownMenuItem(child: Text("Square"), value: QrEyeShape.square),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      qrEyeShape = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Eye Shape",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                width: 170,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Data Shape",
                                      softWrap: true,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    const Text(
                                      "Choose Data shape from circular or square",
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: DropdownButtonFormField(
                                  value: qrDataModuleShape,
                                  items: const [
                                    DropdownMenuItem(child: Text("Circle"), value: QrDataModuleShape.circle),
                                    DropdownMenuItem(child: Text("Square"), value: QrDataModuleShape.square),
                                  ],
                                  onChanged: (value) {
                                    setState(() => qrDataModuleShape = value!);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Data Shape",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                width: 170,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Error Correction Level",
                                      softWrap: true,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    const Text(
                                      "Choose the Error Correction Level. ",
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: DropdownButtonFormField(
                                  value: qrErrorCorrectLevel,
                                  items: [
                                    DropdownMenuItem(child: Text(QrErrorCorrectLevel.getName(QrErrorCorrectLevel.L)), value: QrErrorCorrectLevel.L),
                                    DropdownMenuItem(child: Text(QrErrorCorrectLevel.getName(QrErrorCorrectLevel.M)), value: QrErrorCorrectLevel.M),
                                    DropdownMenuItem(child: Text(QrErrorCorrectLevel.getName(QrErrorCorrectLevel.Q)), value: QrErrorCorrectLevel.Q),
                                    DropdownMenuItem(child: Text(QrErrorCorrectLevel.getName(QrErrorCorrectLevel.H)), value: QrErrorCorrectLevel.H)
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      qrErrorCorrectLevel = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Correction Level",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
