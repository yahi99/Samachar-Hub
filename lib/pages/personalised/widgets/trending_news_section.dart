import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:samachar_hub/data/models/models.dart';
import 'package:samachar_hub/pages/widgets/news_compact_view.dart';
import 'package:samachar_hub/pages/widgets/section_heading.dart';
import 'package:samachar_hub/services/navigation_service.dart';

class TrendingNewsSection extends StatefulWidget {
  final List<NewsFeedModel> feeds;

  const TrendingNewsSection({Key key, this.feeds}) : super(key: key);
  @override
  _TrendingNewsSectionState createState() => _TrendingNewsSectionState();
}

class _TrendingNewsSectionState extends State<TrendingNewsSection>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _currentCarouselIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentCarouselIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<NavigationService>(
      builder: (_, NavigationService navigationService, Widget child) {
        List<Widget> widgets = List<Widget>.generate(
          widget.feeds.length,
          (index) => NewsCompactView(widget.feeds[index]),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SectionHeadingView(
              title: 'Trending News',
              subtitle: 'Current trending stories around you',
              onTap: () => navigationService.toTrendingNews(context),
            ),
            CarouselSlider(
                items: widgets,
                options: CarouselOptions(
                    viewportFraction: 1,
                    initialPage: _currentCarouselIndex.value,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 10),
                    enlargeCenterPage: false,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      _currentCarouselIndex.value = index;
                    })),
            ValueListenableBuilder(
              valueListenable: _currentCarouselIndex,
              builder: (_, int carouselIndex, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    widgets.length,
                    (index) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: carouselIndex == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
