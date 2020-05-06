import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:samachar_hub/data/api/api_provider.dart';
import 'package:samachar_hub/data/dto/news_category_dto.dart';
import 'package:samachar_hub/pages/widgets/news_category_item.dart';
import 'package:samachar_hub/util/news_category.dart';

class NewsCategoryMenuSection extends StatelessWidget {
  final List<NewsCategoryMenu> newsMenus = [
    NewsCategoryMenu('1', newsCategoryNameByCode[NewsCategory.tops],
        FontAwesomeIcons.newspaper),
    NewsCategoryMenu(
        '2', newsCategoryNameByCode[NewsCategory.pltc], Icons.assistant_photo),
    NewsCategoryMenu('3', newsCategoryNameByCode[NewsCategory.sprt],
        FontAwesomeIcons.running),
    NewsCategoryMenu(
        '4', newsCategoryNameByCode[NewsCategory.scte], FontAwesomeIcons.phone),
    NewsCategoryMenu(
        '5', newsCategoryNameByCode[NewsCategory.wrld], FontAwesomeIcons.globe),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: 'Discover',
                  style: Theme.of(context).textTheme.subhead,
                  children: <TextSpan>[
                    TextSpan(text: '\n'),
                    TextSpan(
                        text: 'Get the latest news on your favourite category',
                        style: Theme.of(context).textTheme.subtitle)
                  ],
                ),
              ),
              InputChip(
                onPressed: () => print('View all'),
                backgroundColor: Theme.of(context).accentColor.withOpacity(.1),
                label: Text('View all',
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            height: 100,
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 4,
                  );
                },
                itemCount: newsMenus.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return NewsCategoryMenuItem(
                    category: newsMenus[index],
                  );
                }),
          ),
        ],
      ),
    );
  }
}