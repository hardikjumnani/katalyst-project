import 'package:flutter/material.dart';
import 'package:shakala/app_classes/current_workings.dart';
import 'package:shakala/sheets/my_account_edits/edit_current_workings_sheet.dart';

class ShowCurrentWorkingsSheet extends StatefulWidget {
  final VoidCallback onUpdated;
  final List<CurrentWorking> currentWorkingsList;


  const ShowCurrentWorkingsSheet({
    super.key,
    required this.onUpdated,
    required this.currentWorkingsList,
  });

  @override
  State<ShowCurrentWorkingsSheet> createState() =>
      _ShowCurrentWorkingsSheetState();
}

class _ShowCurrentWorkingsSheetState extends State<ShowCurrentWorkingsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xff222222),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Top bar with close button
          Padding(
            padding: EdgeInsets.fromLTRB(15, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Workings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showEditCurrentWorkingsSheet(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              height: 350,
              child: widget.currentWorkingsList.isEmpty
                  ? Center(
                      child: Text(
                        'No current workings added.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      // children: widget.currentWorkingsList.map((working) {
                      children: List.generate(widget.currentWorkingsList.length, (i) {
                        return InkWell(
                          onTap: () {
                            _showEditCurrentWorkingsSheet(
                              context,
                              currentWorking: widget.currentWorkingsList[i],
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: const Color(0xff444444),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.currentWorkingsList[i].title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                            softWrap: true,
                                          ),
                                          Text(
                                            widget.currentWorkingsList[i].description,
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 14,
                                            ),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          widget.currentWorkingsList.removeAt(i);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: const Color.fromARGB(255,255,156,156),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),

          // Search Button
          SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
              height: 45,
              width: 180,
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xffffffff),
                    backgroundColor: Color(0xffa393eb),
                    side: BorderSide(color: Color(0xffa393eb), width: 2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Done'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCurrentWorkingsSheet(BuildContext context, {CurrentWorking? currentWorking}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditCurrentWorkingsSheet(currentWorking: currentWorking),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    if (result == true) {
      widget.onUpdated();
      Navigator.pop(context); // close this sheet
    }
  }
}
