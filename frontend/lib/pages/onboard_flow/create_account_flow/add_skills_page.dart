import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/add_experience_page.dart';
import 'package:shakala/app_classes/skill.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class AddSkillsPage extends StatefulWidget {
  const AddSkillsPage({super.key});

  @override
  State<AddSkillsPage> createState() => _AddSkillsState();
}

class _AddSkillsState extends State<AddSkillsPage> {
  final apiClient = ApiClient();
  
  final TextEditingController _skillNameController = TextEditingController();
  String? _selectedLevel;

  final List<Skill> _skillsList = [];

  bool _isLoading = false;
  
  final List<String> _levelOptions = [
    'None',
    'Exploring',
    'Learning',
    'Applying',
    'Specializing',
    'Mastering'
  ];

  void _addSkill(String skillName, String level) {
    safeSetState(() {
      _skillsList.add(
        Skill(
          name: skillName.trim(),
          level: level.trim()
        )
      );
      _skillNameController.text = '';
      _selectedLevel = null;
    });
  }

  void _removeSkill(int index) {
    safeSetState(() {
      _skillsList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _skillNameController.dispose();
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add Skills',
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
                    'Add Your Skills',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Showcase your expertise and proficiency levels',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // Skill Input Section
                  Text(
                    'Add New Skill',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Skill Name
                  Text(
                    'Skill Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(_skillNameController, 'e.g. Public Speaking', maxLines: 1, maxlen: 32),
                  
                  SizedBox(height: 16),
                  
                  // Skill Level
                  Text(
                    'Proficiency Level',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildLevelDropdown(),
                  
                  SizedBox(height: 16),
                  
                  // Add Skill Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addSkillToForm(),
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
                            'Add Skill',
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

                  // Skills List Section
                  if (_skillsList.isNotEmpty) ...[
                    Text(
                      'Your Skills (${_skillsList.length})',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Skills List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _skillsList.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildSkillItem(_skillsList[index], index);
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
                            Icons.psychology_outlined,
                            size: 64,
                            color: Colors.white30,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No skills added yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first skill to get started',
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
      {int maxLines = 1, int maxlen = 32}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxlen,
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildLevelDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Color(0xFF3a3a3a),
          value: _selectedLevel,
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Proficiency Level',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          iconEnabledColor: Colors.white54,
          icon: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.arrow_drop_down),
          ),
          style: TextStyle(color: Colors.white, fontSize: 14),
          isExpanded: true,
          onChanged: (String? newValue) {
            safeSetState(() {
              if (newValue == 'None') {
                _selectedLevel = null;
              } else {
                _selectedLevel = newValue;
              }
            });
          },
          items: _levelOptions
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSkillItem(Skill skill, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xffa393eb).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology_outlined,
            color: Color(0xffa393eb),
            size: 20,
          ),
        ),
        title: Text(
          skill.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          skill.level,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          onPressed: () => _removeSkill(index),
          icon: Icon(
            Icons.delete_outline,
            color: Color(0xffff9c9c),
            size: 20,
          ),
        ),
      ),
    );
  }

  void _addSkillToForm() {
    if (_skillNameController.text.trim().isEmpty) {
      _showErrorDialog("Please enter a skill name");
      return;
    }
    
    if (_selectedLevel == null) {
      _showErrorDialog("Please select a proficiency level");
      return;
    }

    _addSkill(_skillNameController.text, _selectedLevel!);
  }

  Future<void> _continueToNext() async {
    if (_skillsList.isEmpty) {
      if (_skillNameController.text.trim().isNotEmpty && _selectedLevel != null) {
        _addSkillToForm();
      } else {
        _showErrorDialog("Please add at least one skill or skip this step");
        return;
      }
    }

    safeSetState(() {
      _isLoading = true;
    });
    
    try {
      await Future.wait(_skillsList.map((skill) {
        return apiClient.post(
          '${ApiClient.baseBackendUrl}/skills/create/', 
          'json',
          {
            "name": skill.name.replaceAll('\n', ' '),
            "level": skill.level.toUpperCase(),
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
          builder: (context) => AddExperiencePage(),
        ),
      );

    } on DioException catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      String errorMessage = "Failed to save skills. Please try again.";
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey("detail")) {
            // errorMessage = "Error: ${data["detail"]}";
            errorMessage = "Unexpected error received";
          } else if (data.containsKey("name")) {
            final nameErrors = data["name"];
            errorMessage = "Skill Name Error: ${nameErrors.join(", ")}";
          } else if (data.containsKey("level")) {
            final levelErrors = data["level"];
            errorMessage = "Level Error: ${levelErrors.join(", ")}";
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
        builder: (context) => AddExperiencePage(),
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