import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jackshub/config/theme.dart';
import 'package:jackshub/globals/globals.dart';
import 'package:jackshub/src/blocs/events_scroll/events_scroll_bloc.dart';
import 'package:jackshub/src/blocs/filter_tabs/filter_tabs_bloc.dart';
import 'package:jackshub/src/blocs/saved_events/index.dart';
import 'package:jackshub/widgets/ColorLoader.dart';
import 'package:jackshub/widgets/index.dart';
import 'package:jackshub/widgets/saved-events.dart';


class EventsToggle extends StatefulWidget {
  @override
  _EventsToggleState createState() => _EventsToggleState();
}

class _EventsToggleState extends State<EventsToggle> with TickerProviderStateMixin {
  AnimationController _filterTabsAppearController;
  Animation _filterTabsAppearAnimation;
  final double filterTabsHeight = 60.0;
  final double filterTabsBottomPadding = 50.0;
  double filterTabsOpacity = 1;
  int selectedTabIndex = 0;
  List filterIcons = [
    Icons.zoom_out_map,
    Icons.group,
    Icons.directions_run,
    Icons.favorite,
  ];
  List filterDisplayNames = [
    'All',
    'Clubs',
    'Sporting',
    'Favorites'
  ];
  List<String> filterTagNames = [
    'all',
    'clubs',
    'sporting'
  ];

  initState() {
    super.initState();
    _filterTabsAppearController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: AppTheme.detailedScreenAnimateDuration
      )
    );
    _filterTabsAppearAnimation = Tween(
      begin: -AppTheme.detailedScreenAnimateOffset,
      end: 0.0
    ).animate(
      CurvedAnimation(
        parent: _filterTabsAppearController,
        curve: AppTheme.detailedScreenCurve
      )
    );
    _filterTabsAppearController.forward();
  }

  @override
  Widget build(BuildContext eventsToggleContext) {
    return Stack(
      children: <Widget>[
        MultiBlocListener(
          listeners: [
            BlocListener<EventsScrollBloc, EventsScrollState>(
              listener: (context, state) {
                if (state is EventsScrollingDown) {
                  // print("listener state: SCROLLING DOWN: ");
                  if (state.opacity == 0) {
                    _filterTabsAppearController.reset();
                  }
                  filterTabsOpacity = state.opacity;
                } else if (state is EventsScrollingUp) {
                  _filterTabsAppearController.forward();
                  filterTabsOpacity = state.opacity;
                } else {
                  // print("listener state: ELSE");
                  filterTabsOpacity = state.opacity;
                }
              }
            ),
            BlocListener<FilterTabsBloc, FilterTabsState>(
              listener: (context, state) {
                if (state is FilterTabsInitial) {
                  selectedTabIndex = 0;
                } else if (state is FilterTabSelected) {
                  selectedTabIndex = state.selectedTabIndex;
                }
              }
            ),
          ],
          child: BlocBuilder<FilterTabsBloc, FilterTabsState>(
            builder: (context, state) {
              return buildStackOfEventsLists(eventsToggleContext)[this.selectedTabIndex];
            } 
          )
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: AnimatedBuilder(
            animation: _filterTabsAppearController,
            builder: (_, __) => BlocBuilder<EventsScrollBloc, EventsScrollState>(
              builder: (context, state) {
                return filterTabsOpacity > 0 ? Opacity(
                  opacity: filterTabsOpacity,
                  child: Transform.translate(
                    offset: Offset(0.0, -_filterTabsAppearAnimation.value),
                    child: buildFilterTabs(eventsToggleContext)
                  )
                ) : Container();
              },
            ),
          ),
        )
      ],
    );
  }

  Widget buildFilterTabs(blocContext) {
    double screenWidth = MediaQuery.of(blocContext).size.width;
    FilterTabsBloc filterTabsBloc = BlocProvider.of<FilterTabsBloc>(blocContext);
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, filterTabsBottomPadding),
      child: Container(
        height: filterTabsHeight,
        width: screenWidth,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: filterIcons.length,
          itemBuilder: (context, index) {
            return FlatButton(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                filterTabsBloc.add(SelectFilterTab(tabIndex: index));
              },
              child: Container(
                height: filterTabsHeight,
                width: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                  ),
                  color: Colors.pink,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Icon(
                          filterIcons[index],
                          color: Colors.white,
                          size: 24.0
                        ),
                      ),
                      Expanded(
                        child: Text(
                          filterDisplayNames[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          )
                        ),
                      )
                    ],
                  ),
                )
              ),
            );
          }
        ),
      ),
    );
  }

  List<Widget> buildStackOfEventsLists(blocContext) {
    List<Widget> masterList = <Widget>[];
    filterTagNames.forEach((filterName) {
      masterList.add(EventsScreen(filter: filterName, scrollBlocContext: blocContext));
    });
    masterList.add(SavedEvents());
    return masterList;
  }
}

class EventsScreen extends StatefulWidget {
  final String filter;
  final BuildContext scrollBlocContext;
  EventsScreen({this.filter, this.scrollBlocContext});


  _EventsScreenState createState() => _EventsScreenState();


  static Widget buildEventsListItem(DocumentSnapshot doc, bool favorite) {
    final tags = doc['tags'];
    if (
      tags.contains('sporting')
      ) {
      return EventsSmallCard(
        name: doc['name'],
        image: doc['image'],
        bigLocation: doc['big_location'],
        littleLocation: doc['tiny_location'],
        startTime: doc['start_time'],
        endTime: doc['end_time'],
        favorite: favorite,
        docId: doc.documentID
      );
    } else {
      return EventsCard(
        name: doc['name'],
        image: doc['image'],
        description: doc['description'],
        bigLocation: doc['big_location'],
        littleLocation: doc['tiny_location'],
        startTime: doc['start_time'],
        endTime: doc['end_time'],
        favorite: favorite,
        docId: doc.documentID
      );
    }
  }
}

class _EventsScreenState extends State<EventsScreen> {
  ScrollController _scrollController;
  EventsScrollBloc eventsScrollBloc;

  _scrollListener() {
    eventsScrollBloc.add(ScrollPositionChanged(_scrollController.position.pixels));
  }

  @override
  initState() {
    eventsScrollBloc = BlocProvider.of<EventsScrollBloc>(widget.scrollBlocContext);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedEventsBloc, SavedEventsState>(
      builder: (context, state) {
        if (state is SavedEventsIdsLoaded || state is SavedEventsInfoLoaded) {
          Map ultimateDocIds = state.savedEventsIdsMap;
          return StreamBuilder<QuerySnapshot>(
            stream: widget.filter == 'all' ? 
              Firestore.instance.collection('eventsCol').orderBy('start_time').snapshots() :
              Firestore.instance.collection('eventsCol').where('tags', arrayContains: widget.filter).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: ColorLoader5()
                );
              }
              return Container(
                color: Theme.of(context).backgroundColor,
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: AVOID_FILTER_TABS_HEIGHT
                  ),
                  controller: _scrollController,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    bool favorite = ultimateDocIds.containsKey(snapshot.data.documents[index].documentID);
                    return EventsScreen.buildEventsListItem(snapshot.data.documents[index], favorite);
                  }
                )
              );
            }
          ); 
        }
        return Center(
          child: ColorLoader5()
        );
      },
    );
    
   
  }
}
