import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:samachar_hub/data/dto/feed_dto.dart';
import 'package:samachar_hub/manager/like_manager.dart';
import 'package:samachar_hub/routes/article/article_view_screen.dart';
import 'package:samachar_hub/service/preference_service.dart';
import 'package:samachar_hub/store/article_store.dart';

part 'like_store.g.dart';

class LikeStore = _LikeStore with _$LikeStore;

abstract class _LikeStore with Store {
  final PreferenceService _preferenceService;
  final LikeManager _likeManager;

  _LikeStore(
    this._preferenceService,
    this._likeManager,
  );

  List<Feed> _feedData = List<Feed>();

  static const int DATA_LIMIT = 20;

  bool _hasMoreData = false;
  bool _isLoadingMore = false;
  StreamController<List<Feed>> _feedStreamController =
      StreamController<List<Feed>>.broadcast();

  Stream<List<Feed>> get feedStream => _feedStreamController.stream;

  @observable
  String error;

  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  @action
  Future<void> loadInitialData() async {
    _likeManager
        .fetchFeedActivitiesAsStream()
        .where((data) => data != null)
        .listen((onData) {
      _feedData.clear();
      _feedData.addAll(onData);
      _feedStreamController.add(_feedData);
      _hasMoreData = onData.length == DATA_LIMIT;
    }, onError: (e) => _feedStreamController.addError(e));
  }

  @action
  Future<void> loadMoreData({resetPage = false}) async {
    if (_isLoadingMore) return;
    if (!_hasMoreData) return;
    _isLoadingMore = true;
    await _likeManager.fetchFeedActivity().then((feeds) {
      if (feeds != null && feeds.isNotEmpty) {
        _feedData.addAll(feeds);
        _hasMoreData = feeds.length == DATA_LIMIT;
      } else
        _hasMoreData = true;

      _isLoadingMore = false;
    }).catchError((onError) => error = onError.toString());
  }

  @action
  Future<bool> addLikedFeed({@required Feed feed}) async {
    return await _likeManager
        .addFeedActivity(feedId: feed.uuid, feedData: feed.toJson())
        .then((onValue) => true, onError: (e) {
      error = e.toString();
      return false;
    });
  }

  @action
  Future<bool> removeLikedFeed({@required Feed feed}) async {
    return await _likeManager
        .removeFeedActivity(feedId: feed.uuid)
        .then((onValue) => true, onError: (e) {
      error = e.toString();
      return false;
    });
  }

  @action
  Future<bool> isLikedFeed({@required Feed feed}) async {
    return await _likeManager
        .doesActivityExist(feedId: feed.uuid)
        .then((onValue) => onValue, onError: (e) {
      error = e.toString();
      return false;
    });
  }

  @action
  void retry() {
    _likeManager.resetLastFetchedDocument();
    loadMoreData();
  }

  @action
  Future<void> refresh() async {
    _likeManager.resetLastFetchedDocument();
    return loadMoreData();
  }

  onFeedClick(Feed article, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Provider<ArticleStore>(
          create: (_) => ArticleStore(article),
          child: Consumer<ArticleStore>(
            builder: (context, store, _) => ArticleViewScreen(store),
          ),
        ),
      ),
    );
  }
}