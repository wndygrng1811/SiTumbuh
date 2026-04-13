import 'package:flutter/material.dart';

class EditProfilOrangtua extends StatefulWidget {
  const EditProfilOrangtua({super.key});

  @override
  State<EditProfilOrangtua> createState() => _EditProfilOrangtuaState();
}

class _EditProfilOrangtuaState extends State<EditProfilOrangtua> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFE85D75),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      /// BUTTON BACK
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "Edit Profil",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// FOTO PROFIL
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFFE85D75),
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Color(0xFFE85D75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// FORM CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 8, color: Colors.black12),
                  ],
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// NAMA
                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// EMAIL
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// NOMOR HP
                      TextFormField(
                        controller: hpController,
                        decoration: InputDecoration(
                          labelText: "Nomor HP",
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ALAMAT
                      TextFormField(
                        controller: alamatController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Alamat",
                          prefixIcon: const Icon(Icons.location_on),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// BUTTON SIMPAN
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profil berhasil diperbarui"),
                              ),
                            );
                          },

                          child: const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
