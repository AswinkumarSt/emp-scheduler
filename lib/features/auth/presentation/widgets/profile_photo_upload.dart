import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoUpload extends StatefulWidget {
  final Function(XFile?)? onPhotoSelected;

  const ProfilePhotoUpload({super.key, this.onPhotoSelected});

  @override
  State<ProfilePhotoUpload> createState() => _ProfilePhotoUploadState();
}

class _ProfilePhotoUploadState extends State<ProfilePhotoUpload> {
  XFile? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _isUploading = true;
        });

        widget.onPhotoSelected?.call(image);

        await Future.delayed(const Duration(seconds: 1));
        
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
    });
    widget.onPhotoSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: _selectedImage != null 
                      ? Colors.blue.shade300 
                      : Colors.grey.shade300,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _buildPhotoContent(),
              ),
            ),
            

            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            
        
            if (!_isUploading)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _selectedImage != null ? _removePhoto : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedImage != null 
                          ? Colors.red.shade500 
                          : Colors.blue.shade500,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _selectedImage != null ? Icons.close : Icons.add_a_photo,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
     
        Column(
          children: [
            Text(
              _selectedImage != null ? 'Profile Photo Added' : 'Add Profile Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _selectedImage != null 
                    ? Colors.green.shade600 
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_selectedImage == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  _buildUploadButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: Colors.blue,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 12),
                  
        
                  _buildUploadButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: Colors.green,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
            
            if (_selectedImage != null) 
              _buildUploadButton(
                icon: Icons.change_circle,
                label: 'Change Photo',
                color: Colors.orange,
                onPressed: () => _showImageSourceDialog(),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPhotoContent() {
    if (_selectedImage != null) {
      
      return Image.network(
        _selectedImage!.path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
   
      return _buildPlaceholder();
    }
  }
  
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.person,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
  
  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: _isUploading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Photo'),
        content: const Text('Choose photo source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}