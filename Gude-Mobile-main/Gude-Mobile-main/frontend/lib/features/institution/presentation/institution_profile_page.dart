import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/services/user_role_service.dart';

class _C {
  static const primary = Color(0xFFE30613);
  static const dark = Color(0xFF1A1A1A);
  static const grey = Color(0xFF888888);
  static const lightGrey = Color(0xFFF5F5F5);
  static const border = Color(0xFFEEEEEE);
}

class InstitutionProfilePage extends StatefulWidget {
  const InstitutionProfilePage({super.key});

  @override
  State<InstitutionProfilePage> createState() => _InstitutionProfilePageState();
}

class _InstitutionProfilePageState extends State<InstitutionProfilePage> {
  final userService = UserRoleService();
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = userService.institutionName;
    _emailController.text = 'institution@domain.ac.za';
    _regNumberController.text = 'REG2024/12345';
  }

  void _toggleEdit() {
    if (_isEditing) {
      setState(() {
        userService.institutionName = _nameController.text;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'), backgroundColor: _C.primary),
      );
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: _C.dark, size: 18),
          onPressed: () => context.go('/institution/marketplace'),
        ),
        title: const Text('Institution Profile',
            style: TextStyle(
                color: _C.dark, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined,
                color: _C.primary),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.business_center_rounded,
                    size: 50, color: _C.primary),
              ),
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              TextField(
                controller: _nameController,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Institution Name',
                  border: InputBorder.none,
                ),
              )
            else
              Text(
                userService.institutionName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _emailController,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: InputBorder.none,
                ),
              )
            else
              Text(
                _emailController.text,
                style: const TextStyle(fontSize: 14, color: _C.grey),
              ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _regNumberController,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Registration Number',
                  border: InputBorder.none,
                ),
              )
            else
              Text(
                _regNumberController.text,
                style: const TextStyle(fontSize: 14, color: _C.grey),
              ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _C.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verified Information',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          color: _C.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Email Verified', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          color: _C.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Registration Verified',
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
