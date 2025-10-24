import 'package:flutter/material.dart';
import 'package:shakala/app_classes/education.dart';
import 'package:shakala/sheets/my_account_edits/edit_educations_sheet.dart';

class ShowEducationsSheet extends StatefulWidget {
  final VoidCallback onUpdated;
  final List<Education> educationsList;

  const ShowEducationsSheet({
    super.key, 
    required this.onUpdated,
    required this.educationsList
  });

  @override
  State<ShowEducationsSheet> createState() => _ShowEducationsSheetState();
}

class _ShowEducationsSheetState extends State<ShowEducationsSheet> {
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
                  'Educations',
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
                      onPressed: () => _showEditEducationsSheet(context),
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
              child: widget.educationsList.isEmpty
                  ? Center(
                      child: Text(
                        'No educations added.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      // children: widget.educationsList.map((edu) {
                      children: List.generate(widget.educationsList.length, (i) {
                        return InkWell(
                          onTap: () {
                            _showEditEducationsSheet(context, education: widget.educationsList[i]);
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
                                            widget.educationsList[i].school.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              height: 1.0,
                                            ),
                                          ),
                                          Text(
                                            widget.educationsList[i].degree.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${widget.educationsList[i].startDate} - ${widget.educationsList[i].endDate}',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            widget.educationsList[i].fieldOfStudy.name,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                              height: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          widget.educationsList.removeAt(i);
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

          // Done Button
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

  void _showEditEducationsSheet(BuildContext context, {Education? education}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditEducationsSheet(education: education),
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
