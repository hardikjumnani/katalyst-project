import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/add_skills_page.dart';
import 'package:shakala/app_classes/current_workings.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class AddCurrentWorkingsPage extends StatefulWidget {
  const AddCurrentWorkingsPage({super.key});

  @override
  State<AddCurrentWorkingsPage> createState() => _AddCurrentWorkingsState();
}

class _AddCurrentWorkingsState extends State<AddCurrentWorkingsPage> {
  final apiClient = ApiClient();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<CurrentWorking> _currentWorkingsList = [];
  bool _isLoading = false;

  void _addCurrentWorking(String title, String description) {
    safeSetState(() {
      _currentWorkingsList.add(
        CurrentWorking(
          title: title.trim(),
          description: description.trim(),
        ),
      );
      _titleController.text = '';
      _descriptionController.text = '';
    });
  }

  void _removeCurrentWorking(int index) {
    safeSetState(() {
      _currentWorkingsList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2a2a2a),
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Current Workings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(width: 24), // For symmetrical spacing
                ],
              ),
            ),
          ),

          // Divider
          Divider(color: Colors.white12, height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'What Are You Currently Working On?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Share your current projects or activities',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // Current Working Input Section
                  Text(
                    'Add New Current Working',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Title Field
                  Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(_titleController, 'e.g. Mobile App Development, Research Project', maxLines: 1, maxlen: 64),
                  
                  SizedBox(height: 16),
                  
                  // Description Field
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(_descriptionController, 'Describe what you\'re working on...', maxLines: 4, maxlen: 256, counterText: null),
                  
                  SizedBox(height: 16),
                  
                  // Add Current Working Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addCurrentWorkingToForm(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xffc8bef3),
                        backgroundColor: Color(0x00000000),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Add Current Working',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32),

                  // Current Workings List Section
                  if (_currentWorkingsList.isNotEmpty) ...[
                    Text(
                      'Your Current Workings (${_currentWorkingsList.length})',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Current Workings List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _currentWorkingsList.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildCurrentWorkingItem(_currentWorkingsList[index], index);
                      },
                    ),
                    
                    SizedBox(height: 24),
                  ] else ...[
                    // Empty State
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.white30,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No current workings added yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first current working to get started',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _continueToNext(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xffa393eb),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Skip Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => _skipToNext(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Color(0xffa393eb),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1, int maxlen = 32, String? counterText = ''}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxlen,
        decoration: InputDecoration(
          counterText: counterText,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xffa393eb), width: 1),
          ),
        ),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildCurrentWorkingItem(CurrentWorking currentWorking, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0x33a393eb),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.work_outline,
            color: Color(0xffa393eb),
            size: 20,
          ),
        ),
        title: Text(
          currentWorking.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          currentWorking.description,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          onPressed: () => _removeCurrentWorking(index),
          icon: Icon(
            Icons.delete_outline,
            color: Color(0xffff9c9c),
            size: 20,
          ),
        ),
      ),
    );
  }

  void _addCurrentWorkingToForm() {

    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog("Please enter a title");
      return;
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorDialog("Please enter a description");
      return;
    }

    _addCurrentWorking(_titleController.text, _descriptionController.text);
  }

  Future<void> _continueToNext() async {
    if (_currentWorkingsList.isEmpty) {
      if (_titleController.text.trim().isNotEmpty && _descriptionController.text.trim().isNotEmpty) {
        _addCurrentWorkingToForm();
      } else {
        _showErrorDialog("Please add  at least one project or skip this step");
        return;
      }
    }

    safeSetState(() {
      _isLoading = true;
    });
    
    try {
      await Future.wait(_currentWorkingsList.map((cw) {
        return apiClient.post(
          '${ApiClient.baseBackendUrl}/current_workings/create/', 
          'json',
          {
            "title": cw.title.replaceAll('\n', ' '),
            "description": cw.description.replaceAll(RegExp(r'\n{3,}'), '\n\n'),
          },
          auth: true,
        );
      }));

      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddSkillsPage(),
        ),
      );

    } on DioException catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      String errorMessage = "Failed to save current workings. Please try again.";
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey("detail")) {
            // errorMessage = "Error: ${data["detail"]}";
            errorMessage = "Unexpected error received";
          } else if (data.containsKey("title")) {
            final titleErrors = data["title"];
            errorMessage = "Title Error: ${titleErrors.join(", ")}";
          } else if (data.containsKey("description")) {
            final descriptionErrors = data["description"];
            errorMessage = "Description Error: ${descriptionErrors.join(", ")}";
          }
        }
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });
      _showErrorDialog("An unexpected error occurred");
    }
  }

  void _skipToNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddSkillsPage(),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2a2a2a),
        title: Text(
          "Warning",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xffa393eb)),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}