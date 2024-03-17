import 'package:akademik_app/Page/akun_daftar.dart';
import 'package:akademik_app/Page/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AkunLogin extends StatefulWidget {
  const AkunLogin({super.key});

  @override
  State<AkunLogin> createState() => _AkunLoginState();
}

class _AkunLoginState extends State<AkunLogin> {
  //method login
  var isLoading = false.obs;
  Future<void> login() async {
    isLoading.value = true;
    final dynamic apiUrl = Uri.parse('http://34.101.154.24/indexapi/login');
    Map<String, String> postData = {
      'username': emailController.text,
      'password': passwordController.text
    };
    try {
      final response = await http.post(apiUrl,
          body: postData,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'});
      Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        final String? cookies = response.headers['set-cookie'];

        final List<String> arrCookies = cookies!.split(';');

        String? phpSessionId;

        for (String cookie in arrCookies) {
          if (cookie.trim().startsWith('PHPSESSID=')) {
            phpSessionId = cookie.trim();
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('tokenJwt', phpSessionId);
            break;
          }
        }
        Get.snackbar('Sukses', 'Login Berhasil',
            colorText: Colors.white,
            backgroundColor: Colors.green,
            icon: const Icon(Icons.add_alert));
        isLoading.value = false;
        Get.to(() => const DashboardScreen());
      } else {
        Get.snackbar('Error', 'Login Gagal',
            colorText: Colors.white,
            backgroundColor: Colors.red,
            icon: const Icon(Icons.add_alert));
        isLoading.value = false;
      }
    } catch (error) {
      Get.snackbar('error', 'Error : $error',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.add_alert));
      isLoading.value = false;
    }
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final passwordVisibility = true.obs;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6e6e6),
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.35000000000000003,
            decoration: BoxDecoration(
              color: const Color(0xff3a57e8),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.52,
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ///***If you have exported images you must have to copy those images in assets/images directory.
                      Image(
                        // ignore: prefer_const_constructors
                        image: AssetImage("assets/LogoApp.png"),
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                      const Text(
                        "SMK UBIG MALANG",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: 20,
                          color: Color(0xff3a57e8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: TextFormField(
                          controller: emailController,
                          obscureText: false,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'email tidak boleh kosong';
                            }
                            return null;
                          },
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
                            hintText: "Email",
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F4F8),
                            isDense: false,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                        child: Obx(
                          () => TextFormField(
                            controller: passwordController,
                            obscureText: passwordVisibility.value,
                            textAlign: TextAlign.start,
                            autofillHints: const [AutofillHints.password],
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'password tidak boleh kosong';
                              }
                              return null;
                            },
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
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F4F8),
                              isDense: false,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  passwordVisibility.value =
                                      !passwordVisibility.value;
                                },
                                child: Icon(
                                  passwordVisibility.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xff212435),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              login();
                            }
                          },
                          color: const Color(0xff3a57e8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(16),
                          textColor: const Color(0xffffffff),
                          height: 40,
                          minWidth: MediaQuery.of(context).size.width,
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
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 17, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              "Belum punya akun? ",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(const AkunDaftar());
                              },
                              child: const Text(
                                "Daftar Disini!",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13,
                                  color: Color(0xff3b58e8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
