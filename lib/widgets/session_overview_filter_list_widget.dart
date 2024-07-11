import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class SessionOverviewFilterListWidget extends StatefulWidget {
  const SessionOverviewFilterListWidget({Key? key}) : super(key: key);

  @override
  State<SessionOverviewFilterListWidget> createState() =>
      _SessionOverviewFilterListWidgetState();
}

class _SessionOverviewFilterListWidgetState
    extends State<SessionOverviewFilterListWidget> {
  final GlobalKey _one = GlobalKey();

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => ShowCaseWidget.of(context).startShowCase([_one]),
    // );
  }

  @override
  Widget build(BuildContext A) {
    final filters = Provider.of<SessionOverviewProvider>(context).filters!;

    return SizedBox(
      height: MediaQuery.of(context).size.height / 16,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 5.0, bottom: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                filters.removeAt(index);
              });
              Provider.of<SessionOverviewProvider>(
                context,
                listen: false,
              ).filter();
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 1),
                  ),
                ],
                color: const Color.fromARGB(255, 204, 170, 49),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(child: Text(filters[index])),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
