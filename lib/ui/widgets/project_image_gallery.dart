import 'package:flutter/material.dart';
import '../../constants/app_urls.dart';
import '../../models/projects/project_model.dart';

class ProjectImageGallery extends StatelessWidget {
  final List<ProjectImageModel> images;

  const ProjectImageGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == images.length - 1 ? 16 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                    '${AppUrls.projectImageUrl}${images[index].path}'),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
