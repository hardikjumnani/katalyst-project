import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shakala/app_classes/current_workings.dart';
import 'package:shakala/services/api_client.dart';

class EditCurrentWorkingsSheet extends StatefulWidget {
  final CurrentWorking? currentWorking;

  const EditCurrentWorkingsSheet({
    super.key,
    this.currentWorking,
  });

  @override
  State<EditCurrentWorkingsSheet> createState() => _EditCurrentWorkingsSheetState();
}

class _EditCurrentWorkingsSheetState extends State<EditCurrentWorkingsSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentWorking?.title ?? '');
    _descriptionController = TextEditingController(text: widget.currentWorking?.description ?? '');
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
                    'Current Workings',
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
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Color(0xff111111),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: TextField(
                          maxLength: 64,
                          controller: _titleController,
                          minLines: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Title',
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
                          maxLines: null,
                          controller: _descriptionController,
                          minLines: 5,
                          maxLength: 256,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Description',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
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
                      if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
                        showInfoDialog(context, "Please fill all the fields.");
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
                          "title": _titleController.text.replaceAll('\n', ' '),
                          "description": _descriptionController.text.replaceAll(RegExp(r'\n+'), '\n'),
                        };
      
                        dynamic response;
      
                        if (widget.currentWorking != null) {
                          // PATCH request for updating
                          data["cw_id"] = widget.currentWorking!.cwId!;
                          response = await apiClient.patch(
                            '${ApiClient.baseBackendUrl}/current_workings/update/',
                            data,
                            auth: true,
                          );
                        } else {
                          // POST request for creating new entry
                          response = await apiClient.post(
                            '${ApiClient.baseBackendUrl}/current_workings/create/',
                            'json',
                            data,
                            auth: true,
                          );
                        }
      
                        Navigator.pop(context); // Close loading dialog
      
                        if (response != null) {
                          Navigator.pop(context, true); // Close sheet on success
                        } else {
                          showInfoDialog(context, 'Failed to save current working');
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
