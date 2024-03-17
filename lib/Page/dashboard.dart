import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akademik_app/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

//Model Data Dashboard
class JenkelData {
  final int total;
  final String jeniskelamin;

  JenkelData({required this.total, required this.jeniskelamin});

  factory JenkelData.fromJson(Map<String, dynamic> json) {
    return JenkelData(
      total: json['total_siswa'],
      jeniskelamin: json['jenis_kelamin'],
    );
  }
}

class KotaData {
  final String total;
  final String nama;

  KotaData({required this.total, required this.nama});

  factory KotaData.fromJson(Map<String, dynamic> json) {
    return KotaData(
      total: json['total_siswa'],
      nama: json['nama'],
    );
  }
}

class ProfileData {
  final String nama;
  final String email;

  ProfileData({required this.nama, required this.email});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      nama: json['nama'],
      email: json['email'],
    );
  }
}

class TahunData {
  final String total;
  final String tahun;

  TahunData({required this.total, required this.tahun});

  factory TahunData.fromJson(Map<String, dynamic> json) {
    return TahunData(
      total: json['total_siswa'],
      tahun: json['tahun'].toString(),
    );
  }
}

//Fetch Data For Dashboard Chart
Future<int> fetchTotalSiswa() async {
  final dynamic apiUrl =
      Uri.parse('http://34.101.154.24/dashboardapi/countsiswa');
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenJwt') ?? '';
  try {
    final response = await http.get(apiUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': token,
    });
    if (response.statusCode == 200) {
      // API mengembalikan respons dengan kode status 200 (OK).
      // Ubah respons JSON ke integer (total siswa).
      int totalSiswa = int.parse(response.body);
      return totalSiswa;
    } else {
      // Tangani kesalahan jika respons tidak berhasil.
      throw Exception('Gagal mengambil data total siswa');
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

Future<List<JenkelData>> fetchJenkelData() async {
  final dynamic apiUrl =
      Uri.parse('http://34.101.154.24/dashboardapi/countjenkel');
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenJwt') ?? '';
  try {
    final response = await http.get(apiUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': token,
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<JenkelData> genderData =
          jsonData.map((jsonItem) => JenkelData.fromJson(jsonItem)).toList();
      return genderData;
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
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

//Request API Kota Asal
Future<List<KotaData>> fetchKota() async {
  final dynamic apiUrl =
      Uri.parse('http://34.101.154.24/dashboardapi/countsiswabykota');
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenJwt') ?? '';
  try {
    final response = await http.get(apiUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': token,
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final kotaData = data.map((item) => KotaData.fromJson(item)).toList();

      return kotaData;
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
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

//fetch profil
void fetchProfile(void Function(List<ProfileData>) onSuccess,
    void Function(String) onError) async {
  final dynamic apiUrl = Uri.parse('http://34.101.154.24/account/getaccount');
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenJwt') ?? '';

  try {
    final response = await http.get(
      apiUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': token,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final profileData = ProfileData.fromJson(data);
      onSuccess([profileData]);
    } else {
      onError('Gagal mengambil data: ${response.statusCode}');
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

Future<List<TahunData>> fetchTahunKel() async {
  final dynamic apiUrl =
      Uri.parse('http://34.101.154.24/dashboardapi/countsiswabyyear');
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenJwt') ?? '';
  try {
    final response = await http.get(apiUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': token,
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final tahunData = data.map((item) => TahunData.fromJson(item)).toList();
      return tahunData;
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
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

class _DashboardScreenState extends State<DashboardScreen> {
  String namaUser = 'Loading....';
  String emailUser = 'Loading....';
  late TooltipBehavior _tooltipBehaviorJenkel;
  late TooltipBehavior _tooltipBehaviorKota;
  late TooltipBehavior _tooltipBehaviorTahun;
  @override
  void initState() {
    super.initState();
    _tooltipBehaviorJenkel = TooltipBehavior(enable: true);
    _tooltipBehaviorKota = TooltipBehavior(enable: true);
    _tooltipBehaviorTahun = TooltipBehavior(enable: true);
    //fetchProfile
    fetchProfile((List<ProfileData> profileDataList) {
      ProfileData profileData = profileDataList[0];
      if (mounted) {
        setState(() {
          namaUser = profileData.nama;
          emailUser = profileData.email;
        });
      }
    }, (String error) {
      // Menangani kesalahan
      print(error);
      Get.snackbar(
        'Gagal',
        "Error: $error",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    void openDialogProfile() {
      Get.dialog(
        AlertDialog(
          title: const Text('Informasi Pengguna'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Nama : '),
                  Expanded(
                    child: Text(
                      namaUser,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Email : '),
                  Expanded(
                    child: Text(
                      emailUser,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xff3b59eb),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          namaUser,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 22,
            color: Color(0xffffffff),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: GestureDetector(
              onTap: () {
                openDialogProfile();
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user.png'),
                radius: 20,
              ),
            ),
          )
        ],
      ),
      drawer: const Drawer(
        width: 278,
        child: AppDrawer(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          GridView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            children: [
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff3a57e9),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<int>(
                      future: fetchTotalSiswa(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          return Text(
                            snapshot.data.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 30,
                              color: Color(0xffa5dff2),
                            ),
                          );
                        }
                      },
                    ),
                    const Text(
                      "Total Siswa",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff3956e8),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<List<JenkelData>>(
                      future: fetchJenkelData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          return Text(
                            snapshot.data![0].total.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 30,
                              color: Color(0xffa4ddf0),
                            ),
                          );
                        }
                      },
                    ),
                    const Text(
                      "Laki-Laki",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff3956e9),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<List<JenkelData>>(
                      future: fetchJenkelData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          return Text(
                            snapshot.data![1].total.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 30,
                              color: Color(0xffa4ddf0),
                            ),
                          );
                        }
                      },
                    ),
                    const Text(
                      "Perempuan",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GridView(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            children: [
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff3956e8),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Jenis Kelamin",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xffffffff),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<JenkelData>>(
                        future: fetchJenkelData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            List<JenkelData> jenkel = snapshot.data!;

                            return SfCircularChart(
                              palette: const <Color>[
                                Colors.amber,
                                Colors.lightBlue,
                              ],
                              tooltipBehavior: _tooltipBehaviorJenkel,
                              // legend: Legend(
                              //   isVisible: true,
                              //   overflowMode: LegendItemOverflowMode.wrap,
                              // ),
                              series: <CircularSeries>[
                                PieSeries<JenkelData, String>(
                                  dataSource: jenkel,
                                  xValueMapper: (JenkelData data, _) =>
                                      data.jeniskelamin,
                                  yValueMapper: (JenkelData data, _) =>
                                      data.total,
                                  dataLabelSettings:
                                      const DataLabelSettings(isVisible: true),
                                  enableTooltip: true,
                                  sortingOrder: SortingOrder.descending,
                                )
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff3956e8),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        "Kota Siswa",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xffffffff),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: fetchKota(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            List<KotaData> kota = snapshot.data!;
                            return SfCircularChart(
                              palette: const <Color>[
                                Colors.amber,
                                Colors.orange,
                                Colors.cyan,
                                Colors.redAccent,
                                Colors.lightBlue,
                                Colors.limeAccent,
                              ],

                              tooltipBehavior: _tooltipBehaviorKota,
                              // legend: Legend(
                              //   isVisible: true,
                              //   overflowMode: LegendItemOverflowMode.wrap,
                              // ),
                              series: <CircularSeries>[
                                PieSeries<KotaData, String>(
                                  dataSource: kota,
                                  xValueMapper: (KotaData data, _) => data.nama,
                                  yValueMapper: (KotaData data, _) =>
                                      int.tryParse(data.total),
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                  ),
                                  enableTooltip: true,
                                )
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: GridView(
              padding: const EdgeInsets.all(10),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 2,
                childAspectRatio: 1.4,
              ),
              children: [
                Container(
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xff3a57e8),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16.0),
                    border:
                        Border.all(color: const Color(0x4d9e9e9e), width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 0,
                        ),
                        child: Text(
                          "Tahun Kelahiran",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xffffffff),
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: FutureBuilder(
                          future: fetchTahunKel(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              List<TahunData> tahun = snapshot.data!;
                              return SfCartesianChart(
                                primaryXAxis: CategoryAxis(
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                primaryYAxis: NumericAxis(
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                legend: const Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                tooltipBehavior: _tooltipBehaviorTahun,
                                series: <CartesianSeries<TahunData, String>>[
                                  ColumnSeries<TahunData, String>(
                                    name: "Tahun",
                                    dataSource: tahun,
                                    color: Colors.amber,
                                    xValueMapper: (TahunData data, _) =>
                                        data.tahun,
                                    yValueMapper: (TahunData data, _) =>
                                        int.tryParse(data.total),
                                    dataLabelSettings: const DataLabelSettings(
                                      color: Colors.white,
                                      isVisible: true,
                                    ),
                                    enableTooltip: true,
                                  )
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
