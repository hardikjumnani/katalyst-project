import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shakala/app_classes/education.dart';
import 'package:shakala/services/api_client.dart';

class EditEducationsSheet extends StatefulWidget {
  final Education? education;

  const EditEducationsSheet({super.key, this.education});

  @override
  State<EditEducationsSheet> createState() => _EditEducationsSheetState();
}

class _EditEducationsSheetState extends State<EditEducationsSheet> {
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isPresent = false;

  @override
  void initState() {
    super.initState();

    final edu = widget.education;
    if (edu != null) {
      _schoolNameController.text = edu.school.name;
      _degreeController.text = edu.degree.name;
      _fieldOfStudyController.text = edu.fieldOfStudy.name;
      _startDateController.text = edu.startDate;
      _endDateController.text = edu.endDate ?? "";
    }
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
                    'Educations',
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
      
            // School Name field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Color(0xff111111),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: TextField(
                          maxLines: 1,
                          maxLength: 128,
                          controller: _schoolNameController,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'School Name',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Color(0xff111111),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: TextField(
                          maxLines: 1,
                          maxLength: 128,
                          controller: _degreeController,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Degree',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Color(0xff111111),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: TextField(
                          maxLines: 1,
                          maxLength: 64,
                          controller: _fieldOfStudyController,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Field of Study',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Start Date
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _startDateController.text = picked.toIso8601String().split('T')[0];
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: _buildTextField(_startDateController, 'Start Date'),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
      
                          // End Date or Present
                          Expanded(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _isPresent
                                      ? null
                                      : () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _endDateController.text =
                                                  picked.toIso8601String().split('T')[0];
                                              print("OK ${DateTime.now()}");
                                            });
                                          }
                                        },
                                  child: AbsorbPointer(
                                    child: _buildTextField(
                                      _endDateController,
                                      _isPresent ? 'Present' : 'End Date',
                                      enabled: !_isPresent,
                                      
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _isPresent,
                                      onChanged: (val) {
                                        setState(() {
                                          _isPresent = val ?? false;
                                          if (_isPresent) _endDateController.clear();
                                        });
                                      },
                                      fillColor: MaterialStateProperty.all(Color(0xffa393eb)),
                                    ),
                                    Text('Present', style: TextStyle(color: Colors.white)),
                                  ],
                                )
                              ],
                            ),
                          ),
                      ],
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
                      final schoolName = _schoolNameController.text.trim();
                      final degree = _degreeController.text.trim();
                      final fieldOfStudy = _fieldOfStudyController.text.trim();
                      final startDate = _startDateController.text.trim();
                      final endDate = _endDateController.text == '' ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : _endDateController.text.trim();
                      
                      if (schoolName.isEmpty || degree.isEmpty || startDate.isEmpty || (endDate.isEmpty && _isPresent == false)) {
                        showInfoDialog(context, "Please fill all the fields.");
                        return;
                      }
      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(child: CircularProgressIndicator()),
                      );
      
                      final data = {
                        "school_name": schoolName,
                        "degree": degree,
                        "field_of_study": fieldOfStudy,
                        "start_date": startDate,
                        "end_date": endDate,
                      };
      
                      try {
                        final apiClient = ApiClient();
                        dynamic response;
      
                        if (widget.education != null) {
                          data["edu_id"] = widget.education!.eduId!;
                          response = await apiClient.patch(
                            '${ApiClient.baseBackendUrl}/educations/update/',
                            data,
                            auth: true,
                          );
                        } else {
                          response = await apiClient.post(
                            '${ApiClient.baseBackendUrl}/educations/create/',
                            'json',
                            data,
                            auth: true,
                          );
                        }
      
                        Navigator.pop(context); // close loading
                        Navigator.pop(context, true); // close bottom sheet
      
                        if (response == null) {
                          showInfoDialog(context, 'Something went wrong');
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

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int minLines = 1, int maxLines = 1, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: const Color(0xff111111),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
