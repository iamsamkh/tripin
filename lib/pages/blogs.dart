import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import '../blocs/blog_bloc.dart';
import '../models/blog.dart';
import '../pages/blog_details.dart';
import '../utils/empty.dart';
import '../utils/next_screen.dart';
import '../widgets/custom_cache_image.dart';
import '../utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _orderBy = 'loves';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      controller.addListener(_scrollListener);
      context.read<BlogBloc>().getData(mounted, _orderBy);
    });
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final db = context.read<BlogBloc>();

    if (!db.isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        context.read<BlogBloc>().setLoading(true);
        context.read<BlogBloc>().getData(mounted, _orderBy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bb = context.watch<BlogBloc>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        // automaticallyImplyLeading: false,
        title: const Text('Blogs').tr(),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black,
            
          ),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
              child: const Icon(CupertinoIcons.sort_down),
              //initialValue: 'view',
              itemBuilder: (BuildContext context) {
                return <PopupMenuItem>[
                  const PopupMenuItem(
                    child: Text('Most Recent'),
                    value: 'recent',
                  ),
                  const PopupMenuItem(
                    child: Text('Most Popular'),
                    value: 'popular',
                  )
                ];
              },
              onSelected: (value) {
                setState(() {
                  if (value == 'popular') {
                    _orderBy = 'loves';
                  } else {
                    _orderBy = 'timestamp';
                  }
                });
                bb.afterPopSelection(value, mounted, _orderBy);
              }),
          IconButton(
            // icon: const Icon(Feather.rotate_cw, size: 22,),
            icon: const FaIcon(
              FontAwesomeIcons.rotate,
              size: 22,
            ),
            onPressed: () {
              context.read<BlogBloc>().onRefresh(mounted, _orderBy);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        child: bb.hasData == false
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                  const EmptyPage(
                      icon: FontAwesomeIcons.clipboard,
                      message: 'No blogs found',
                      message1: ''),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(15),
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: bb.data.isNotEmpty ? bb.data.length + 1 : 5,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 15.h,
                ),

                //shrinkWrap: true,
                itemBuilder: (_, int index) {
                  if (index < bb.data.length) {
                    return _ItemList(d: bb.data[index]);
                  }
                  return Opacity(
                    opacity: bb.isLoading ? 1.0 : 0.0,
                    child: bb.lastVisible == null
                        ? LoadingCard(height: 250.h)
                        : Center(
                            child: SizedBox(
                                width: 32.w,
                                height: 32.h,
                                child: const CupertinoActivityIndicator()),
                          ),
                  );
                },
              ),
        onRefresh: () async {
          context.read<BlogBloc>().onRefresh(mounted, _orderBy);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ItemList extends StatelessWidget {
  final Blog d;
  const _ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ]),
          child: Wrap(
            children: [
              Hero(
                tag: 'blog${d.timestamp}',
                child: SizedBox(
                  height: 160.h,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomCacheImage(imageUrl: d.thumbnailImagelUrl)),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                        HtmlUnescape().convert(
                            parse(d.description).documentElement!.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[700])),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        Text(
                          d.date,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        Text(
                          d.loves.toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () => nextScreen(
            context, BlogDetails(blogData: d, tag: 'blog${d.timestamp}')));
  }
}
