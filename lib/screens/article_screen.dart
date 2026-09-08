import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMMM yyyy').format(article.publishedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, size: 19),
            onPressed: () => Share.share(
              article.shareUrl ?? article.title,
              subject: article.title,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const ArtworkBox(height: 200),
          Padding(
            padding: const EdgeInsets.all(EfcSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UtilityLabel(
                  '${date.toUpperCase()} \u00b7 ${article.category}',
                  color: EfcColors.blood,
                  letterSpacing: 1.8,
                ),
                const SizedBox(height: 10),
                Text(
                  article.title.toUpperCase(),
                  style: EfcText.display(size: 28, height: 1.0),
                ),
                if (article.standfirst != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    article.standfirst!,
                    style: EfcText.body(
                      size: 17,
                      color: EfcColors.bone,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const HairLine(),
                const SizedBox(height: 16),
                Text(article.body, style: EfcText.body(size: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
