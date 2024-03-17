import 'dart:convert';

import 'package:akademik_app/Page/siswa.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SiswaEdit extends StatefulWidget {
  final int Id;
  final String Nama;
  final String Nis;
  final String Alamat;
  final String tgl_lahir;
  final int jenkel;
  final int kota_id;
  final String nmKota;

  const SiswaEdit(
      {super.key,
      required this.Id,
      required this.Nama,
      required this.Nis,
      required this.Alamat,
      required this.tgl_lahir,
      required this.jenkel,
      required this.kota_id,
      required this.nmKota});

  @override
  State<SiswaEdit> createState() => _SiswaEditState();
}

class _SiswaEditState extends State<SiswaEdit> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nisController = TextEditingController();
  final TextEditingController tglLahirController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  var isLoading = false.obs;
  var isLoadingDelete = false.obs;
  var isLoadingShowKota = false.obs;

  int? gender = 1;

  List<Map<String, dynamic>> dropdownItems = [];
  Map<String, dynamic>? selectedDropdownItem;

  @override
  void initState() {
    super.initState();
    fetchKota().then((data) {
      if (mounted) {
        setState(() {
          dropdownItems = data;
          selectedDropdownItem =
              getDefaultDropdownItem(widget.kota_id, widget.nmKota);
          isLoadingShowKota.value = true;
        });
      }
    });
    if (mounted) {
      setState(() {
        namaController.text = widget.Nama;
        nisController.text = widget.Nis;
        tglLahirController.text = widget.tgl_lahir;
        gender = widget.jenkel;
        alamatController.text = widget.Alamat;
      });
    }
  }

  Map<String, dynamic>? getDefaultDropdownItem(int kotaId, String nmKota) {
    for (Map<String, dynamic> item in dropdownItems) {
      if (item['id'] == kotaId && item['nama'] == nmKota) {
        isLoadingShowKota.value = true;
        return item;
      }
    }
    return null;
  }

  // REQUEST GET KOTA
  Future<List<Map<String, dynamic>>> fetchKota() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenJwt') ?? '';

    final response = await http.get(
      Uri.parse('http://34.101.154.24/kotaapi/apilist'),
      headers: {
        'Cookie': token,
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Map<String, dynamic>> data =
          jsonResponse.cast<Map<String, dynamic>>();
      return data;
    } else {
      Get.snackbar(
        'Gagal mengambil data kota dari database',
        "Error ${response.reasonPhrase}",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
      );
      throw Exception("Gagal mengambil data kota dari database");
    }
  }

  // REQUEST UPDATE SISWA
  Future<void> siswaEdit() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenJwt') ?? '';
    final IdSiswa = widget.Id;

    final response = await http.post(
      Uri.parse(
          'http://34.101.154.24/siswaapi/apiedit/$IdSiswa'),
      body: {
        'nis': nisController.text,
        'nama': namaController.text,
        'tgl_lahir': tglLahirController.text,
        'alamat': alamatController.text,
        'jenkel': gender.toString(),
        'kota_id': selectedDropdownItem?['id'].toString(),
        'nm_kota': selectedDropdownItem?['nama'].toString(),
      },
      headers: {
        'Cookie': token,
      },
    );
    if (response.statusCode == 200) {
      isLoading.value = false;
      Get.snackbar(
        'Sukses',
        "Siswa ${namaController.text} berhasil diupdate",
        colorText: Colors.white,
        backgroundColor: Colors.green[400],
        icon: const Icon(Icons.add_alert),
      );
      Get.to(Siswa());
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Gagal mengirim data',
        "Error ${response.reasonPhrase}",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
      );
    }
  }

  Future<void> siswaDelete() async {
    isLoadingDelete.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenJwt') ?? '';

    var idSiswa = widget.Id;

    final url = Uri.parse(
        'http://34.101.154.24/siswaapi/apidelete/$idSiswa');

    final response = await http.post(
      url,
      headers: {
        'Cookie': token,
      },
    );
    if (response.statusCode == 200) {
      isLoadingDelete.value = false;
      Get.snackbar(
        'Sukses',
        "Siswa ${widget.Nama} berhasil dihapus",
        colorText: Colors.white,
        backgroundColor: Colors.green[400],
        icon: const Icon(Icons.add_alert),
      );
      Get.to(const Siswa());
    } else {
      isLoadingDelete.value = false;
      Get.snackbar(
        'Gagal menghapus data',
        "Error ${response.reasonPhrase}",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
      );
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      onPressed: () {
        Get.back();
      },
      child: const Text("Batal"),
    );
    Widget continueButton = Obx(
      () => TextButton(
        onPressed: () {
          isLoadingDelete.value = true;
          siswaDelete();
        },
        child: Stack(
          children: [
            isLoadingDelete.value
                ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 4.0,
                    ),
                  )
                : const Text(
                    "Hapus",
                  ),
          ],
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Konfirmasi"),
      content: const Text("Apakah anda yakin ingin menghapus data ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "Edit Siswa",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 22,
            color: Color(0xffffffff),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.to(const Siswa());
          },
          child: const Icon(
            Icons.arrow_back,
            color: Color(0xffffffff),
            size: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete,
              ),
              onPressed: () {
                showAlertDialog(context);
              },
              color: Color(0xffffffff),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Nama",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          TextFormField(
                            controller: namaController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              // hintText: "Nama",
                              // hintStyle: const TextStyle(
                              //   fontWeight: FontWeight.w400,
                              //   fontStyle: FontStyle.normal,
                              //   fontSize: 14,
                              //   color: Color(0xff000000),
                              // ),
                              filled: true,
                              fillColor: const Color(0xfff1f4f9),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "NIS",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          TextFormField(
                            controller: nisController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'nis tidak boleh kosong';
                            //   }
                            //   return null;
                            // },
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              // hintText: "NIS",
                              // hintStyle: const TextStyle(
                              //   fontWeight: FontWeight.w400,
                              //   fontStyle: FontStyle.normal,
                              //   fontSize: 14,
                              //   color: Color(0xff000000),
                              // ),
                              filled: true,
                              fillColor: const Color(0xfff2f5f9),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Tanggal Lahir",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          TextFormField(
                            controller: tglLahirController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'tanggal lahir tidak boleh kosong';
                            //   }
                            //   return null;
                            // },
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              // hintText: "Tanggal Lahir",
                              // hintStyle: const TextStyle(
                              //   fontWeight: FontWeight.w400,
                              //   fontStyle: FontStyle.normal,
                              //   fontSize: 14,
                              //   color: Color(0xff000000),
                              // ),
                              filled: true,
                              fillColor: const Color(0xfff3f6fa),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(3000),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      tglLahirController.text =
                                          DateFormat("yyyy-MM-dd")
                                              .format(pickedDate);
                                    });
                                  }
                                },
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xff212435),
                                  size: 20,
                                ),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(3000),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  tglLahirController.text =
                                      DateFormat("yyyy-MM-dd")
                                          .format(pickedDate);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Jenis Kelamin",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Radio(
                                value: 1,
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                                activeColor: const Color(0xff3a57e8),
                                autofocus: false,
                                splashRadius: 20,
                                hoverColor: const Color(0x42000000),
                              ),
                              const Text(
                                "Laki-Laki",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                              Radio(
                                value: 2,
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                                activeColor: const Color(0xff3a57e8),
                                autofocus: false,
                                splashRadius: 20,
                                hoverColor: const Color(0x42000000),
                              ),
                              const Text(
                                "Perempuan",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
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
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Alamat",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          TextFormField(
                            controller: alamatController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'alamat lahir tidak boleh kosong';
                            //   }
                            //   return null;
                            // },
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00000000), width: 1),
                              ),
                              // hintText: "Alamat",
                              // hintStyle: const TextStyle(
                              //   fontWeight: FontWeight.w400,
                              //   fontStyle: FontStyle.normal,
                              //   fontSize: 14,
                              //   color: Color(0xff000000),
                              // ),
                              filled: true,
                              fillColor: const Color(0xfff0f3f7),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Kota Asal",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: 130,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F4F8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isLoadingShowKota.value
                                      ? DropdownButtonHideUnderline(
                                          child: DropdownButtonFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'kota tidak boleh kosong';
                                              }
                                              return null;
                                            },
                                            value: selectedDropdownItem,
                                            items: dropdownItems.map<
                                                    DropdownMenuItem<
                                                        Map<String, dynamic>>>(
                                                (item) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value: item,
                                                child: Text(item['nama']),
                                              );
                                            }).toList(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                            onChanged: (Map<String, dynamic>?
                                                newValue) {
                                              setState(() {
                                                selectedDropdownItem = newValue;
                                              });
                                            },
                                            elevation: 8,
                                            isExpanded: true,
                                            hint: const Text("Pilih data"),
                                          ),
                                        )
                                      : const Center(
                                          child: SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4.0,
                                            ),
                                          ),
                                        ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Obx(
                  () => MaterialButton(
                    onPressed: () {
                      siswaEdit();
                    },
                    color: const Color(0xff3a57e8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(16),
                    textColor: const Color(0xffffffff),
                    height: 40,
                    minWidth: 140,
                    child: Stack(
                      children: [
                        isLoading.value
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4.0,
                                ),
                              )
                            : const Text(
                                "Simpan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
