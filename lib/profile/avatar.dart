import 'package:dogre/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  child: Center(
                    child: Text("Image"),
                  ),
                ),
        ),
        TextButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image == null) {
                return;
              }
              final imageBytes = await image.readAsBytes();
              final userId = supabase.auth.currentUser!.id;
              final String pathName = '/$userId/profile';
              await supabase.storage
                  .from('users avatar')
                  .uploadBinary(pathName, imageBytes);
              final imageUrl =
                  supabase.storage.from('users avatar').getPublicUrl(pathName);
              onUpload(imageUrl);
            },
            child: Text('Upload'))
      ],
    );
  }
}
