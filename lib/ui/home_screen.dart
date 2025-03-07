import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:students_attendace_with_mlkit/ui/absent/absent_screen.dart';
import 'package:students_attendace_with_mlkit/ui/attend/attend_screen.dart';
import 'package:students_attendace_with_mlkit/ui/attendance_history/attendance_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Absensi",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildMenuItem(
                context,
                "Absen Kehadiran",
                "Catat kehadiranmu di sini",
                "assets/images/ic_absen.png",
                const AttendScreen(),
              ),
              _buildMenuItem(
                context,
                "Cuti / Izin",
                "Ajukan izin atau cuti",
                "assets/images/ic_leave.png",
                const AbsentScreen(),
              ),
              _buildMenuItem(
                context,
                "Riwayat Absensi",
                "Lihat data absensi",
                "assets/images/ic_history.png",
                const AttendanceHistoryScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String subtitle, String imagePath, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 60, width: 60),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah kamu ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }
}
