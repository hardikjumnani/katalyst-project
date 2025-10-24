import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shakala/app_classes/skill.dart';
import 'package:shakala/services/api_client.dart';

class EditSkillsSheet extends StatefulWidget {
  final Skill? skill;

  const EditSkillsSheet({super.key, this.skill});

  @override
  State<EditSkillsSheet> createState() => _EditSkillsSheetState();
}

class _EditSkillsSheetState extends State<EditSkillsSheet> {
  late final TextEditingController _skillNameController;
  String? _selectedLevel;

  final List<String> _levelOptions = [
    'Exploring',
    'Learning',
    'Applying',
    'Specializing',
    'Mastering'
  ];

  @override
  void initState() {
    super.initState();
    _skillNameController = TextEditingController(text: widget.skill?.name ?? '');
    _selectedLevel = widget.skill?.level;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
      
            // Textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Skill name
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Color(0xff111111),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: TextField(
                          controller: _skillNameController,
                          maxLines: 2,
                          minLines: 1,
                          maxLength: 32,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
      
                  // Level dropdown
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Color(0xff111111),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLevel,
                            dropdownColor: Color(0xff111111),
                            hint: Text(
                              'Select level',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            iconEnabledColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLevel = newValue;
                              });
                            },
                            items: _levelOptions.map((level) {
                              return DropdownMenuItem<String>(
                                value: level,
                                child: Text(level),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                    onPressed: () async {
                      final skillName = _skillNameController.text.trim();
                      final skillLevel = _selectedLevel;
      
                      if (skillName.isEmpty || skillLevel == null) {
                        showInfoDialog(context, "Please fill all fields.");
                        return;
                      }
      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(child: CircularProgressIndicator()),
                      );
      
                      try {
                        final apiClient = ApiClient();
                        final data = {
                          "name": skillName.replaceAll('\n', ' '),
                          "level": skillLevel.toUpperCase(),
                        };
      
                        dynamic response;
      
                        if (widget.skill != null) {
                          // PATCH existing skill
                          data["skill_id"] = widget.skill!.skillId!;
                          response = await apiClient.patch(
                            '${ApiClient.baseBackendUrl}/skills/update/',
                            data,
                            auth: true,
                          );
                        } else {
                          // POST new skill
                          response = await apiClient.post(
                            '${ApiClient.baseBackendUrl}/skills/create/',
                            'json',
                            data,
                            auth: true,
                          );
                        }
      
                        Navigator.pop(context); // Close loading dialog
      
                        if (response != null) {
                          Navigator.pop(context, true); // Close bottom sheet
                        } else {
                          showInfoDialog(context, 'Failed to save skill');
                        }
      
                      } on DioException catch (e) {
                        Navigator.pop(context, false); // Close loading dialog
      
                        if (e.response != null) {
                          final data = e.response!.data;
                          if (data is Map && data.containsKey("detail")) {
                            showInfoDialog(context, "Error: ${data["detail"]}");
                          } else {
                            showInfoDialog(context, "Something went wrong. Please try again.");
                          }
                        } else {
                          showInfoDialog(context, "Network error. Please try again.");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xffffffff),
                      backgroundColor: Color(0xffa393eb),
                      side: BorderSide(color: Color(0xffa393eb), width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Save'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Warning"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
