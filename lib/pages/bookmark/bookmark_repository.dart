import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:samachar_hub/data/mappers/mappers.dart';
import 'package:samachar_hub/data/models/models.dart';
import 'package:samachar_hub/data/models/user_model.dart';
import 'package:samachar_hub/pages/bookmark/bookmark_firestore_service.dart';
import 'package:samachar_hub/repository/post_meta_repository.dart';
import 'package:samachar_hub/services/services.dart';

class BookmarkRepository {
  final BookmarkFirestoreService _bookmarkService;
  final AnalyticsService _analyticsService;
  final PostMetaRepository _postMetaRepository;
  final PreferenceService _preferenceService;

  static const int DATA_LIMIT = 20;

  BookmarkRepository(this._bookmarkService, this._postMetaRepository,
      this._analyticsService, this._preferenceService);

  String generateBookmarkId(String postId, String userId) => '$postId:$userId';

  Future<void> postBookmark(
      {@required String postId,
      @required UserModel user,
      @required NewsFeedModel bookmarkFeed}) {
    var metaData = {
      'bookmark_count': FieldValue.increment(1),
    };
    var activityId =
        _postMetaRepository.generateActivityId(postId, user.uId, 'bookmark');
    var metaActivityData = {
      'id': activityId,
      'meta_name': 'bookmark',
      'post_id': postId,
      'user': user.toJson(),
      'timestamp': FieldValue.serverTimestamp(),
    };
    var bookmarkId = generateBookmarkId(postId, user.uId);

    var data = bookmarkFeed.toJson();
    data['user_id'] = user.uId;
    data['timestamp'] = DateTime.now().toString();
    data.remove('related');
    return _bookmarkService
        .addBookmark(
            bookmarkId: bookmarkId,
            metaActivityData: metaActivityData,
            metaData: metaData,
            bookmarkData: data,
            metaActivityDocumentRef: _postMetaRepository
                .metaActivityCollectionReference(postId)
                .document(activityId),
            metaDocumentRef:
                _postMetaRepository.metaCollectionReference.document(postId))
        .then((value) {
      var bookmarks = _preferenceService.bookmarkedFeeds;
      bookmarks.add(postId);
      _preferenceService.bookmarkedFeeds = bookmarks;
      _analyticsService.logFeedBookmarkAdded(feedId: postId);
    });
  }

  Future<void> removeBookmark({
    @required String postId,
    @required String userId,
  }) async {
    var data = {'bookmark_count': FieldValue.increment(-1)};
    var bookmarkId = generateBookmarkId(postId, userId);
    var activityId =
        _postMetaRepository.generateActivityId(postId, userId, 'bookmark');
    return _bookmarkService
        .removeBookmark(
            bookmarkId: bookmarkId,
            metaActivityDocumentRef: _postMetaRepository
                .metaActivityCollectionReference(postId)
                .document(activityId),
            metaDocumentRef:
                _postMetaRepository.metaCollectionReference.document(postId),
            metaData: data)
        .then((value) {
      var bookmarks = _preferenceService.bookmarkedFeeds;
      bookmarks.remove(postId);
      _preferenceService.bookmarkedFeeds = bookmarks;
      _analyticsService.logFeedBookmarkRemoved(feedId: postId);
    });
  }

  Future<bool> doesBookmarkExist(
      {@required String postId, @required String userId}) async {
    return await _bookmarkService.doesBookmarkExist(
        bookmarkId: generateBookmarkId(postId, userId));
  }

  Future<List<NewsFeedModel>> getBookmarks(
      {@required String userId, String after}) {
    return _bookmarkService
        .fetchBookmarks(userId: userId, limit: DATA_LIMIT, after: after)
        .then((value) {
      if (value != null && value.isNotEmpty) {
        return value
            .map((response) => NewsMapper.fromBookmarkFeed(response))
            .toList();
      }
      return List<NewsFeedModel>();
    }).then((value) {
      _analyticsService.logFeedBookmarkFetched(page: after);
      return value;
    });
  }

  Stream<List<NewsFeedModel>> getBookmarksAsStream({@required String userId}) {
    return _bookmarkService
        .fetchBookmarksAsStream(userId: userId, limit: DATA_LIMIT)
        .map((value) {
      if (value != null && value.isNotEmpty) {
        return value
            .map((response) => NewsMapper.fromBookmarkFeed(response))
            .toList();
      }
      return List<NewsFeedModel>();
    }).map((value) {
      _analyticsService.logFeedBookmarkFetched(page: '0');
      return value;
    });
  }
}
