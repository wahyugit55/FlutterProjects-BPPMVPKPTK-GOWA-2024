import 'dart:convert';
import 'package:akademik_app/Page/dashboard.dart';
import 'package:akademik_app/Page/kota_edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'kota_tambah.dart';

class Kota extends StatefulWidget {
  const Kota({super.key});

  @override
  State<Kota> createState() => _KotaState();
}

class KotaData {
  final int id;
  final String nama;

  KotaData({required this.id, required this.nama});

  factory KotaData.fromJson(Map<String, dynamic> json) {
    return KotaData(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama'],
    );
  }
}

class _KotaState extends State<Kota> {
  final TextEditingController searchController = TextEditingController();
  List<KotaData> searchData = [];
  Widget loadingListView = const Center(
    child: CircularProgressIndicator(),
  );

  void fetchDataKota(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenJwt') ?? '';

    setState(() {
      loadingListView = const Center(
        child: CircularProgressIndicator(),
      );
    });

    try {
      final response = await http.get(
        Uri.parse("http://34.101.154.24/kotaapi/apilist?search=$query"),
        headers: {
          'Cookie': token,
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          List<KotaData> newDataList =
              decodedData.map((item) => KotaData.fromJson(item)).toList();
          if (mounted) {
            setState(() {
              searchData = newDataList;
              if (newDataList.isEmpty) {
                Get.snackbar(
                  'Kosong',
                  "Data tersebut tidak ada",
                  colorText: Colors.white,
                  backgroundColor: Colors.orange,
                  icon: const Icon(Icons.add_alert),
                );
                loadingListView = ListView(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  children: [
                    Card(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      color: const Color(0xff3b57e6),
                      shadowColor: const Color(0x4d939393),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Color(0x4d9e9e9e), width: 1),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Kota tidak ditemukan",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xffffffff),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xffffffff),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                loadingListView = ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    // searchData.sort((a, b) => a.nama.compareTo(b.nama));
                    return GestureDetector(
                      onTap: () {
                        Get.to(KotaEdit(
                          Id: searchData[index].id,
                          Nama: searchData[index].nama,
                        ));
                      },
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        color: const Color(0xff3b57e6),
                        shadowColor: const Color(0x4d939393),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                              color: Color(0x4d9e9e9e), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                searchData[index].nama,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  color: Color(0xffffffff),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xffffffff),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: searchData.length,
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                );
              }
            });
          }
        } else {
          Get.snackbar(
            'Gagal mencari data',
            "Invalid Data Format",
            colorText: Colors.white,
            backgroundColor: Colors.red,
            icon: const Icon(Icons.add_alert),
          );
        }
      } else {
        Get.snackbar(
          'Gagal mencari',
          "Error ${response.reasonPhrase}",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.add_alert),
        );
      }
    } catch (e) {
      if (e
          .toString()
          .contains("Connection closed before full header was received")) {
        // Handle the specific error condition here
        // You can add custom handling logic for this case
        Get.snackbar(
          'Gagal meload data',
          "Error:{$e} Connection closed before full header was received",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.add_alert),
        );
      }
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataKota("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff3b58ec),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "Kota",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 22,
            color: Color(0xffffffff),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.to(DashboardScreen());
          },
          child: const Icon(
            Icons.arrow_back,
            color: Color(0xffffffff),
            size: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
                onTap: () {
                  Get.to(KotaTambah());
                },
                child: const Icon(
                  Icons.add_circle,
                  color: Color(0xffffffff),
                  size: 24,
                )),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: TextField(
                  controller: searchController,
                  obscureText: false,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    var query = searchController.text;
                    fetchDataKota(query);
                  },
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide:
                          const BorderSide(color: Color(0xffa9aec3), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide:
                          const BorderSide(color: Color(0xffa9aec3), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide:
                          const BorderSide(color: Color(0xffa9aec3), width: 1),
                    ),
                    hintText: "Pencarian",
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xffabb0c4),
                    ),
                    filled: true,
                    fillColor: const Color(0xfff2f4f7),
                    isDense: false,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 24,
                      ),
                      onPressed: () {
                        var query = searchController.text;
                        fetchDataKota(query);
                      },
                      color: const Color(0xffa9aec2),
                    ),
                  ),
                ),
              ),
              loadingListView,
              // ListView(
              //   scrollDirection: Axis.vertical,
              //   padding: const EdgeInsets.all(0),
              //   shrinkWrap: true,
              //   physics: const ScrollPhysics(),
              //   children: [
              //     Card(
              //       margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              //       color: const Color(0xff3b57e6),
              //       shadowColor: const Color(0x4d939393),
              //       elevation: 1,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //         side:
              //             const BorderSide(color: Color(0x4d9e9e9e), width: 1),
              //       ),
              //       child: const Padding(
              //         padding: EdgeInsets.all(7),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisSize: MainAxisSize.max,
              //           children: [
              //             Text(
              //               "Pasuruan",
              //               textAlign: TextAlign.start,
              //               overflow: TextOverflow.clip,
              //               style: TextStyle(
              //                 fontWeight: FontWeight.w500,
              //                 fontStyle: FontStyle.normal,
              //                 fontSize: 16,
              //                 color: Color(0xffffffff),
              //               ),
              //             ),
              //             Icon(
              //               Icons.arrow_forward_ios,
              //               color: Color(0xffffffff),
              //               size: 24,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     Card(
              //       margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              //       color: const Color(0xff3a57e9),
              //       shadowColor: const Color(0xff000000),
              //       elevation: 1,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //         side:
              //             const BorderSide(color: Color(0x4d9e9e9e), width: 1),
              //       ),
              //       child: const Padding(
              //         padding: EdgeInsets.all(7),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisSize: MainAxisSize.max,
              //           children: [
              //             Text(
              //               "Surabaya",
              //               textAlign: TextAlign.start,
              //               overflow: TextOverflow.clip,
              //               style: TextStyle(
              //                 fontWeight: FontWeight.w500,
              //                 fontStyle: FontStyle.normal,
              //                 fontSize: 16,
              //                 color: Color(0xffffffff),
              //               ),
              //             ),
              //             Icon(
              //               Icons.arrow_forward_ios,
              //               color: Color(0xffffffff),
              //               size: 24,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(KotaTambah());
        },
        hoverElevation: 40,
        hoverColor: const Color(0xFFF9F871),
        backgroundColor: const Color(0xFFFFC253),
        child: const Icon(
          Icons.add,
          size: 24,
          color: Colors.black,
        ),
      ),
    );
  }
}
