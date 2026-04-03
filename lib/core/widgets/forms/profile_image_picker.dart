import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../styles/app_colors.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';

class ProfileImagePicker extends StatefulWidget {
  final Function(XFile?) onImageSelected;
  final XFile? initialImage;
  final double? size;
  final String? uploadText;

  const ProfileImagePicker({
    super.key,
    required this.onImageSelected,
    this.initialImage,
    this.size,
    this.uploadText,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  @override
  Widget build(BuildContext context) {
    final double size =
        widget.size ?? context.responsive(100.w, tablet: 120.w, desktop: 140.w);

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryStart.withOpacityCompat(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.secondaryGradient,
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                        File(_selectedImage!.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultIcon(size);
                        },
                      )
                    : _buildDefaultContent(size),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryStart.withOpacityCompat(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: size * 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon(double size) {
    return Icon(
      Icons.person_rounded,
      size: size * 0.5,
      color: AppColors.primary,
    );
  }

  Widget _buildDefaultContent(double size) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: AppColors.primaryStart.withOpacityCompat(0.5),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      widget.onImageSelected(image);
    }
  }
}
