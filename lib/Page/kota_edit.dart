import 'package:akademik_app/Page/Kota.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class KotaEdit extends StatefulWidget {
  final int Id;
  final String Nama;
  const KotaEdit({super.key, required this.Id, required this.Nama});

  @override
  State<KotaEdit> createState() => _KotaEditState();
}

class _KotaEditState extends State<KotaEdit> {
  final TextEditingController kotaController = TextEditingController();
  var isLoading = false.obs;
  var isLoadingDelete = false.obs;

  Future<void> kotaEdit() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenJwt') ?? '';

    var idKota = widget.Id;

    final url = Uri.parse(
        'http://34.101.154.24/kotaapi/apiedit/$idKota');

    final response = await http.post(
      url,
      body: {
        'nama': kotaController.text,
      },
      headers: {
        'Cookie': token,
      },
    );
    if (response.statusCode == 200) {
      isLoading.value = false;
      Get.snackbar(
        'Sukses',
        "Kota ${widget.Nama} berhasil diupdate",
        colorText: Colors.white,
        backgroundColor: Colors.green[400],
        icon: const Icon(Icons.add_alert),
      );
      Get.to(const Kota());
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Gagal mengupdate data',
        "Error ${response.reasonPhrase}",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
      );
    }
  }

  Future<void> kotaDelete() async {
    isLoadingDelete.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenJwt') ?? '';

    var idKota = widget.Id;

    final url = Uri.parse(
        'http://34.101.154.24/kotaapi/apidelete/$idKota');

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
        "Kota ${widget.Nama} berhasil dihapus",
        colorText: Colors.white,
        backgroundColor: Colors.green[400],
        icon: const Icon(Icons.add_alert),
      );
      Get.to(const Kota());
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
          kotaDelete();
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
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        kotaController.text = widget.Nama;
      });
    }
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
          "Edit Kota Asal",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 22,
            color: Color(0xffffffff),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.to(const Kota());
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
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: () {
                showAlertDialog(context);
              },
              color: const Color(0xffffffff),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
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
                      TextField(
                        controller: kotaController,
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
                          // hintText: "Pasuruan",
                          // hintStyle: TextStyle(
                          //   fontWeight: FontWeight.w400,
                          //   fontStyle: FontStyle.normal,
                          //   fontSize: 14,
                          //   color: Color(0xff000000),
                          // ),
                          filled: true,
                          fillColor: const Color(0xfff2f4f7),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Obx(
                () => MaterialButton(
                  onPressed: () {
                    kotaEdit();
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
    );
  }
}
