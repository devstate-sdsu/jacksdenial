import 'package:flutter/material.dart';
import 'package:jackshub/config/router.dart';
import 'package:jackshub/config/theme.dart';



class ServicesCard extends StatefulWidget {
  final String name;
  final String summary;
  final String image;
  final String status;
  final String docId;

  const ServicesCard({
    Key key,
    this.name,
    this.summary,
    this.image,
    this.status,
    this.docId
  }): super(key: key);

  @override
  _ServicesCard createState() => _ServicesCard();
}



class _ServicesCard extends State<ServicesCard> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation _animation;

  int transitionDuration = 1000;  // in milliseconds

  double cardTouchedScale = 0.94;
  double cardRegularScale = 1.0;
  int cardAnimateDuration = 250;  // in milliseconds
  var cardScale = 1.0;

  double cardVerticalSize = 135.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: cardAnimateDuration,
      )
    );
    _animation = Tween(
      begin: cardRegularScale,
      end: cardTouchedScale
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeInQuad
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return GestureDetector(

          onTapDown: (TapDownDetails details) {
            _controller.forward();
          },

          onTapUp: (TapUpDetails details) {
            _controller.reverse();
            Navigator.pushNamed(
              context,
              '/detailedServices',
              arguments: ServicesRoutingParameters(
                widget.name,
                widget.image,
                widget.docId,
              ),
            );
          },

          onTapCancel: () {
            _controller.reverse();
          },

          child: Transform.scale(
            scale: _animation.value,
            child: Container(
              height: cardVerticalSize,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(
                horizontal: AppTheme.cardSideMargin,
                vertical: AppTheme.cardVerticalMargin
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor,
                    blurRadius: AppTheme.shadowBlurRadius,
                    offset: AppTheme.shadowOffset
                  )
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 350,
                    child: Hero(
                      tag: 'servicesCardImg'+widget.docId,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.cardRadius),
                          bottomLeft: Radius.circular(AppTheme.cardRadius)
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                widget.image
                              )
                            )
                          )
                        )
                      )
                    )
                  ),
                  Spacer(
                    flex: 40
                  ),
                  Expanded(
                    flex: 725,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10.0
                        ),
                        Hero(
                          tag: 'servicesCardTitle'+widget.docId,
                          child: Text(
                            widget.name,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.title
                          )
                        ),                            
                        SizedBox(
                          height: 10.0
                        ),
                        Expanded(
                          child: Text(
                            widget.summary,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.caption,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3
                          )
                        ),
                        SizedBox(
                          height: 10.0
                        ),
                        Text(
                          widget.status,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.caption
                        ),
                        SizedBox(
                          height: 10.0
                        )
                      ],
                    )
                  ),
                  Spacer(
                    flex: 20
                  )
                ],
              )
            )
          )
        );
      }
    );
  }
}

