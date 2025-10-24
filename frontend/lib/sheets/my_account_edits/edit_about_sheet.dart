import 'package:flutter/material.dart';
import 'package:shakala/services/api_client.dart';

class EditAboutSheet extends StatefulWidget {
  final String about;

  const EditAboutSheet({super.key, required this.about});

  @override
  State<EditAboutSheet> createState() => _EditAboutSheetState();
}

class _EditAboutSheetState extends State<EditAboutSheet> {
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: widget.about);
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
                    'About',
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Color(0xff111111),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: TextField(
                    maxLines: null,
                    controller: _aboutController,
                    minLines: 10,
                    maxLength: 512,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Share what you\'re built of...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
      
            // Save Button
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              height: 45,
              width: 180,
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () async {
                    final newAbout = _aboutController.text.trim();
            
                    // if (newAbout.isEmpty) {
                    //   showInfoDialog(context, 'About cannot be empty');
                    //   return;
                    // }
            
                    // Show a loading indicator while patching
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          Center(child: CircularProgressIndicator()),
                    );
            
                    try {
                      final apiClient = ApiClient();
                      final response = await apiClient.patch(
                        '${ApiClient.baseBackendUrl}/users/me/',
                        {
                          'about': newAbout.replaceAll(RegExp(r'\n+'), '\n')
                        },
                        auth: true,
                      );
            
                      Navigator.pop(context); // Close loading dialog
            
                      if (response != null) {
                        // Success - close sheet
                        Navigator.pop(context, true);
                      } else {
                        // Failure
                        showInfoDialog(context, 'Failed to update About');
                      }
                    } catch (e) {
                      Navigator.pop(
                        context,
                        false,
                      ); // Close loading dialog if error
                      showInfoDialog(context, 'Error occurred: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xffffffff),
                    backgroundColor: Color(0xffa393eb),
                    side: BorderSide(color: Color(0xffa393eb), width: 2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size(0, 40),
                  ),
                  child: Text('Save'),
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
          ),
        ],
      ),
    );
  }
}
