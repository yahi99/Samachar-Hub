import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:samachar_hub/data/api.dart';
import 'package:samachar_hub/data/model/api_error.dart';
import 'package:samachar_hub/routes/home/pages/topheadlines/logic/top_headlines_store.dart';
import 'package:samachar_hub/routes/home/pages/topheadlines/top_headlines_category_view.dart';

class TopHeadlinesPage extends StatefulWidget {
  @override
  _TopHeadlinesPageState createState() => _TopHeadlinesPageState();
}

class _TopHeadlinesPageState extends State<TopHeadlinesPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Reaction disposers
  List<ReactionDisposer> _disposers;
  TabController _tabController;
  final List<Tab> _tabs = <Tab>[
    Tab(key: ValueKey<NewsCategory>(NewsCategory.general), text: 'General'),
    Tab(key: ValueKey<NewsCategory>(NewsCategory.business), text: 'Business'),
    Tab(
        key: ValueKey<NewsCategory>(NewsCategory.entertainment),
        text: 'Entertainment'),
    Tab(key: ValueKey<NewsCategory>(NewsCategory.health), text: 'Health'),
    Tab(key: ValueKey<NewsCategory>(NewsCategory.science), text: 'Science'),
    Tab(
        key: ValueKey<NewsCategory>(NewsCategory.technology),
        text: 'Technology'),
    Tab(key: ValueKey<NewsCategory>(NewsCategory.sports), text: 'Sports'),
  ];

  @override
  void initState() {
    final store = Provider.of<TopHeadlinesStore>(context, listen: false);
    _setupObserver(store);
    _tabController = TabController(
      initialIndex: store.activeTabIndex,
      vsync: this,
      length: _tabs.length,
    );
    _tabController.addListener(() {
      store.setActiveTab(_tabController.index);
      store.fetchTopHeadlines(
          (_tabs[_tabController.index].key as ValueKey<NewsCategory>).value);
    });
    super.initState();
  }

  @override
  void dispose() {
    // Dispose reactions
    for (final d in _disposers) {
      d();
    }
    _tabController.dispose();
    super.dispose();
  }

  _showMessage(String message) {
    if (null != message)
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  _showErrorDialog(APIError apiError) {
    if (null != apiError)
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'API Error - ${apiError.code}',
              style: Theme.of(context).textTheme.subhead,
            ),
            content: SingleChildScrollView(
              child: Text(
                apiError.message,
                style: Theme.of(context).textTheme.body1,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }

  _setupObserver(store) {
    _disposers = [
      // Listens for error message
      autorun((_) {
        final String message = store.error;
        _showMessage(message);
      }),
      // Listens for API error
      autorun((_) {
        final APIError error = store.apiError;
        _showErrorDialog(error);
      })
    ];
  }

  Widget _newsPopupMenuItem(icon, color, title, value) {
    return PopupMenuItem<MenuItem>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(icon, color: color),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              title,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<TopHeadlinesStore>(
        builder: (context, topHeadlinesStore, child) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 24, bottom: 8, left: 8, right: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Top Headlines',
                          style: Theme.of(context).textTheme.headline),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Opacity(
                          opacity: 0.65, child: Icon(FontAwesomeIcons.search)),
                    ),
                    Opacity(
                      opacity: 0.65,
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: PopupMenuButton<MenuItem>(
                          icon: Icon(FontAwesomeIcons.ellipsisV),
                          onSelected: topHeadlinesStore.setView,
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<MenuItem>>[
                            //Todo: Create a separate widget for PopupMenuItem
                            _newsPopupMenuItem(
                                FontAwesomeIcons.list,
                                topHeadlinesStore.view == MenuItem.LIST_VIEW
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context).iconTheme.color,
                                'List View',
                                MenuItem.LIST_VIEW),
                            _newsPopupMenuItem(
                                FontAwesomeIcons.addressCard,
                                topHeadlinesStore.view ==
                                        MenuItem.THUMBNAIL_VIEW
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context).iconTheme.color,
                                'Thumbnail View',
                                MenuItem.THUMBNAIL_VIEW),
                            _newsPopupMenuItem(
                                FontAwesomeIcons.image,
                                topHeadlinesStore.view == MenuItem.COMPACT_VIEW
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context).iconTheme.color,
                                'Compact View',
                                MenuItem.COMPACT_VIEW),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: _tabs,
                isScrollable: true,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    TopHeadlinesCategoryView(NewsCategory.general),
                    TopHeadlinesCategoryView(NewsCategory.business),
                    TopHeadlinesCategoryView(NewsCategory.entertainment),
                    TopHeadlinesCategoryView(NewsCategory.health),
                    TopHeadlinesCategoryView(NewsCategory.science),
                    TopHeadlinesCategoryView(NewsCategory.technology),
                    TopHeadlinesCategoryView(NewsCategory.sports),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

enum MenuItem {
  LIST_VIEW,
  THUMBNAIL_VIEW,
  COMPACT_VIEW,
}