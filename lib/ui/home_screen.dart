import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/travel_bloc.dart';
import '../data/models/location_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TravelBloc travelBloc = TravelBloc();

  @override
  void initState() {
    super.initState();
    travelBloc.add(GetLocationList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        backgroundColor: Colors.teal,
        title: const Text(
          'Explore routes',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: buildLocationList(),
    );
  }

  Widget buildLocationList() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: BlocProvider(
        create: (_) => travelBloc,
        child: BlocListener<TravelBloc, TravelState>(
          listener: (context, state) {
            if (state is TravelErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                ),
              );
            }
          },
          child: BlocBuilder<TravelBloc, TravelState>(
            builder: (context, state) {
              if (state is TravelInitialState) {
                return const LoadingWidget();
              } else if (state is TravelLoadingState) {
                return const LoadingWidget();
              } else if (state is TravelLoadedState) {
                return LocationWidget(
                  locationModel: state.locations,
                  travelBloc: travelBloc,
                );
              } else if (state is TravelErrorState) {
                return Container();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class LocationWidget extends StatefulWidget {
  final LocationModel locationModel;
  final TravelBloc travelBloc;
  const LocationWidget(
      {super.key, required this.locationModel, required this.travelBloc});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  bool showMoreNearByTours = false;
  bool showMorePopularTours = false;
  int viewLocation = 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Near by
            widget.locationModel.data!.nearby!.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Routes',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' nearby',
                              style: TextStyle(
                                color: Colors.teal,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                widget.locationModel.data!.nearby!.length,
                            itemBuilder: (context, index) {
                              Nearby nearbyData =
                                  widget.locationModel.data!.nearby![index];
                              return LocationDetailsCardWidget(
                                imagePath: nearbyData.coverImage!,
                                name: nearbyData.name!,
                                location: nearbyData.location!,
                                averageRating: nearbyData.averageRating!,
                                duration: nearbyData.duration!.toString(),
                                price: nearbyData.price!,
                                distance: nearbyData.distance!.toString(),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 10);
                            },
                          ),
                          const SizedBox(height: 5),
                          widget.locationModel.data!.nearby!.length > 2
                              ? OutlinedButton(
                                  onPressed: () {
                                    widget.travelBloc.add(GetLocationList());
                                    setState(() {
                                      if (viewLocation <
                                          widget.locationModel.data!.nearby!
                                              .length) {
                                        viewLocation = viewLocation + 2;
                                      }
                                      if (viewLocation >=
                                          widget.locationModel.data!.nearby!
                                              .length) {
                                        showMoreNearByTours =
                                            !showMoreNearByTours;
                                        if (showMoreNearByTours == false) {
                                          viewLocation = 2;
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    showMoreNearByTours
                                        ? 'Load Less'
                                        : 'Load More',
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 10),
            // Popular tours
            widget.locationModel.data!.popular!.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Popular',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' tours',
                              style: TextStyle(
                                color: Colors.teal,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: widget.locationModel.data!.popular!
                                .take(viewLocation)
                                .length,
                            itemBuilder: (context, index) {
                              Popular popularData =
                                  widget.locationModel.data!.popular![index];
                              return LocationDetailsCardWidget(
                                imagePath: popularData.coverImage!,
                                name: popularData.name!,
                                location: popularData.location!,
                                averageRating: popularData.averageRating!,
                                duration: popularData.duration!.toString(),
                                price: popularData.price!,
                                distance: popularData.distance!.toString(),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 10);
                            },
                          ),
                          const SizedBox(height: 5),
                          widget.locationModel.data!.popular!.length > 2
                              ? OutlinedButton(
                                  onPressed: () {
                                    widget.travelBloc.add(GetLocationList());
                                    setState(() {
                                      if (viewLocation <
                                          widget.locationModel.data!.popular!
                                              .length) {
                                        viewLocation = viewLocation + 2;
                                      }
                                      if (viewLocation >=
                                          widget.locationModel.data!.popular!
                                              .length) {
                                        showMorePopularTours =
                                            !showMorePopularTours;
                                        if (showMorePopularTours == false) {
                                          viewLocation = 2;
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    showMorePopularTours
                                        ? 'Load Less'
                                        : 'Load More',
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class LocationDetailsCardWidget extends StatelessWidget {
  const LocationDetailsCardWidget({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.averageRating,
    required this.duration,
    required this.price,
    required this.distance,
  });

  final String imagePath;
  final String name;
  final String location;
  final String averageRating;
  final String duration;
  final String price;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imagePath,
              cacheHeight: 100,
              cacheWidth: 100,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            const VerticalDivider(
                              indent: 8,
                              endIndent: 8,
                              color: Colors.grey,
                            ),
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber,
                            ),
                            Text(
                              ' ${double.parse(averageRating).toStringAsFixed(1)}/5',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    indent: 0,
                    endIndent: 0,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconWithTextWidget(
                          icon: Icons.access_time_rounded,
                          title: '${duration}m',
                        ),
                        const VerticalDivider(
                          indent: 5,
                          endIndent: 5,
                          color: Colors.grey,
                        ),
                        IconWithTextWidget(
                          icon: Icons.account_balance_wallet_rounded,
                          title: '\$ $price',
                        ),
                        const VerticalDivider(
                          indent: 5,
                          endIndent: 5,
                          color: Colors.grey,
                        ),
                        IconWithTextWidget(
                          icon: Icons.compare_arrows_rounded,
                          title: '${distance}km',
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconWithTextWidget extends StatelessWidget {
  const IconWithTextWidget({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
