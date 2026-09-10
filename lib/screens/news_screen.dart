import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/layout_b.dart';
import 'article_screen.dart';
import 'screen_scaffold.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  static const _months = [
    'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'
  ];

  static String _shortDate(DateTime? d) =>
      d == null ? '' : '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.status == LoadStatus.loading && state.articles.isEmpty) {
      return const Column(
        children: [
          EfcHeader(title: 'News'),
          Expanded(child: LoadingState()),
        ],
      );
    }

    final articles = state.sortedArticles;

    return Column(
      children: [
        EfcHeader(
          title: 'News',
          meta: state.push.isAvailable ? 'Push on' : 'Push off',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: state.refresh,
            color: EfcColors.blood,
            backgroundColor: EfcColors.steel,
            child: articles.isEmpty
                ? ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: EmptyState(
                          title: 'No stories yet',
                          body: 'Announcements published in the CMS land here.',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: articles.length,
                    itemBuilder: (_, i) {
                      final a = articles[i];
                      void open() => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ArticleScreen(article: a),
                            ),
                          );
                      // First story anchors the screen; the rest are rows.
                      if (i == 0) {
                        return LeadCard(
                          title: a.title,
                          meta: _shortDate(a.publishedAt),
                          imageUrl: a.heroImageUrl,
                          height: 186,
                          onTap: open,
                        );
                      }
                      return ThumbRow(
                        title: a.title,
                        meta: _shortDate(a.publishedAt),
                        imageUrl: a.heroImageUrl,
                        onTap: open,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
