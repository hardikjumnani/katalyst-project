import 'package:flutter/material.dart';
import 'package:shakala/app_classes/experience.dart';
import 'package:shakala/sheets/my_account_edits/edit_experiences_sheet.dart';

class ShowExperiencesSheet extends StatefulWidget {
  final VoidCallback onUpdated;
  final List<Experience> experiencesList;

  const ShowExperiencesSheet({
    super.key, 
    required this.onUpdated,
    required this.experiencesList
  });

  @override
  State<ShowExperiencesSheet> createState() => _ShowExperiencesSheetState();
}

class _ShowExperiencesSheetState extends State<ShowExperiencesSheet> {
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
                  'Experiences',
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
                      onPressed: () => _showEditExperiencesSheet(context),
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
              child: widget.experiencesList.isEmpty
                  ? Center(
                      child: Text(
                        'No experiences added.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView(
                      // children: widget.experiencesList.map((exp) {
                      children: List.generate(widget.experiencesList.length, (i) {
                        final bool isRemote = widget.experiencesList[i].cityOrOnline == "<ONLINE>";
                        final String location = isRemote
                            ? 'Remote opportunity'
                            : '${widget.experiencesList[i].cityOrOnline}, ${widget.experiencesList[i].state}, ${widget.experiencesList[i].country}';
            
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: const Color(0xff444444),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: InkWell(
                                onTap: () => _showEditExperiencesSheet(
                                  context,
                                  experience: widget.experiencesList[i],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.experiencesList[i].title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              height: 1.0,
                                            ),
                                          ),
                                          Text(
                                            widget.experiencesList[i].companyName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${widget.experiencesList[i].startDate} - ${widget.experiencesList[i].endDate}',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            location,
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (widget.experiencesList[i].description != null &&
                                              widget.experiencesList[i].description!.trim().isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.experiencesList[i].description!,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          widget.experiencesList.removeAt(i);
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

          // Save Button
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

  void _showEditExperiencesSheet(BuildContext context, {Experience? experience}) async{
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditExperiencesSheet(experience: experience),
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
