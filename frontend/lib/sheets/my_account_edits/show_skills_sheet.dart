import 'package:flutter/material.dart';
import 'package:shakala/app_classes/skill.dart';
import 'package:shakala/sheets/my_account_edits/edit_skills_sheet.dart';

class ShowSkillsSheet extends StatefulWidget {
  final VoidCallback onUpdated;
  final List<Skill> skillsList;

  const ShowSkillsSheet({
    super.key, 
    required this.onUpdated,
    required this.skillsList
  });

  @override
  State<ShowSkillsSheet> createState() => _ShowSkillsSheetState();
}

class _ShowSkillsSheetState extends State<ShowSkillsSheet> {
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
                  'Skills',
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
                      onPressed: () => _showEditSkillsSheet(context),
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
          SizedBox(
            height: 350,
            child: widget.skillsList.isEmpty
                ? Center(
                    child: Text(
                      'No skills added.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    // children: widget.skillsList.map((skill) {
                    children: List.generate(widget.skillsList.length, (i) {
                      return InkWell(
                        onTap: () {
                          _showEditSkillsSheet(context, skill: widget.skillsList[i]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: Color(0xff444444),
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                           widget.skillsList[i].name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          toCapitalCase( widget.skillsList[i].level),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.skillsList.removeAt(i);
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

  String toCapitalCase(String input) {
    return input
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  void _showEditSkillsSheet(BuildContext context, {Skill? skill}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditSkillsSheet(skill: skill),
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
