import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:samachar_hub/data/api/api.dart';
import 'package:samachar_hub/data/models/models.dart';
import 'package:samachar_hub/pages/news/sources/news_source_item.dart';
import 'package:samachar_hub/pages/news/sources/news_source_store.dart';
import 'package:samachar_hub/pages/widgets/api_error_dialog.dart';
import 'package:samachar_hub/pages/widgets/empty_data_widget.dart';
import 'package:samachar_hub/pages/widgets/error_data_widget.dart';
import 'package:samachar_hub/pages/widgets/page_heading_widget.dart';
import 'package:samachar_hub/pages/widgets/progress_widget.dart';

class NewsSourceScreen extends StatefulWidget {
  @override
  _NewsSourceScreenState createState() => _NewsSourceScreenState();
}

class _NewsSourceScreenState extends State<NewsSourceScreen> {
  // Reaction disposers
  List<ReactionDisposer> _disposers;

  @override
  void initState() {
    final store = Provider.of<NewsSourceStore>(context, listen: false);
    _setupObserver(store);
    store.loadInitialData();

    super.initState();
  }

  @override
  void dispose() {
    // Dispose reactions
    for (final d in _disposers) {
      d();
    }
    super.dispose();
  }

  _showMessage(String message) {
    if (null != message)
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  _showErrorDialog(APIException apiError) {
    if (null != apiError)
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return ApiErrorDialog(
            apiError: apiError,
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
        final APIException error = store.apiError;
        _showErrorDialog(error);
      })
    ];
  }

  Widget _buildList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Consumer<NewsSourceStore>(
        builder: (context, sourceStore, child) {
          return StreamBuilder<List<NewsSourceModel>>(
            stream: sourceStore.dataStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<NewsSourceModel>> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: ErrorDataView(
                    onRetry: () => sourceStore.retry(),
                  ),
                );
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: ProgressView());
                default:
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Center(
                      child: EmptyDataView(
                        onRetry: () => sourceStore.retry(),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 16 / 9,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return NewsSourceItem(context: context, source: snapshot.data[index]);
                    },
                  );
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  BackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  PageHeading(
                    title: 'News Sources',
                  ),
                ],
              ),
              Expanded(
                child: _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}