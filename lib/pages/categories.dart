import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../blocs/blog_bloc.dart';
import '../blocs/categories_bloc.dart';
import '../models/colors.dart';
import '../models/category.dart';
import '../pages/state_based_places.dart';
import '../utils/empty.dart';
import '../utils/next_screen.dart';
import '../widgets/custom_cache_image.dart';
import '../utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with AutomaticKeepAliveClientMixin {
      // late ScrollController controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // controller.addListener(_scrollListener);
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      context.read<CategoriesBloc>().getData(mounted);
    });
  }

  @override
  void dispose() {
    // controller.removeListener(_scrollListener);
    super.dispose();
  }

  // void _scrollListener() {
  //   final db = context.read<BlogBloc>();

  //   if (!db.isLoading) {
  //     if (controller.position.pixels == controller.position.maxScrollExtent) {
  //       context.read<CategoriesBloc>().setLoading(true);
  //       context.read<CategoriesBloc>().getData(mounted);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sb = context.watch<CategoriesBloc>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('Categories').tr(),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black,
            
          ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.rotateRight,
              size: 22,
            ),
            onPressed: () {
              context.read<CategoriesBloc>().onReload(mounted);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        child: sb.hasData == false
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                  const EmptyPage(
                      icon: FontAwesomeIcons.clipboard,
                      message: 'No Categories found',
                      message1: ''),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(15),
                // controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: sb.data.isNotEmpty ? sb.data.length + 1 : 8,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 10.h,
                ),

                //shrinkWrap: true,
                itemBuilder: (_, int index) {
                  if (index < sb.data.length) {
                    return _ItemList(d: sb.data[index]);
                  }
                  return Opacity(
                    opacity: sb.isLoading ? 1.0 : 0.0,
                    child: LoadingCard(height: 140.h)
                  );
                },
              ),
        onRefresh: () async {
          context.read<CategoriesBloc>().onRefresh(mounted);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ItemList extends StatelessWidget {
  final CategoriesModel d;
  const _ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          height: 140,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CustomCacheImage(
                      imageUrl: d.thumbnailUrl,
                    )),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  d.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              )
            ],
          )),
      onTap: () => nextScreen(
          context,
          CategoriesBasedPlaces(
            categoryId: d.id,
            categoryName: d.name,
            color: (ColorList().randomColors..shuffle()).first,
          )),
    );
  }
}
