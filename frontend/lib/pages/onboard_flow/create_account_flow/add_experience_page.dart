import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/add_education_page.dart';
import 'package:shakala/app_classes/experience.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class AddExperiencePage extends StatefulWidget {
  const AddExperiencePage({super.key});

  @override
  State<AddExperiencePage> createState() => _AddExperiencePageState();
}

class _AddExperiencePageState extends State<AddExperiencePage> {
  final apiClient = ApiClient();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isPresent = false;

  final List<Experience> _experiencesList = [];

  bool _isLoading = false;

  void _addExperience(String title, String companyName, String startDate, String? endDate) {
    safeSetState(() {
      _experiencesList.add(
        Experience(
          title: title,
          companyName: companyName,
          startDate: startDate,
          endDate: endDate ?? "",
        ),
      );

      _titleController.text = '';
      _companyNameController.text = '';
      _startDateController.text = '';
      _endDateController.text = '';
      _isPresent = false;
    });
  }

  void _removeExperience(int index) {
    safeSetState(() {
      _experiencesList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2a2a2a),
      body: Column(
        children: [
          // Header - Matches AddSkillsPage exactly
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add Experience',
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
                  
                  // Title - Matches AddSkillsPage structure
                  Text(
                    'Add Your Experience',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Share your professional work experience',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // Experience Input Section - Matches AddSkillsPage structure
                  Text(
                    'Add New Experience',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Job Title
                  Text(
                    'Job Title',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(_titleController, 'e.g. Software Engineer, Product Manager', maxLines: 1, maxlen: 32),
                  
                  SizedBox(height: 16),
                  
                  // Company Name
                  Text(
                    'Company Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(_companyNameController, 'e.g. Google, Microsoft', maxLines: 1, maxlen: 32),
                  
                  SizedBox(height: 16),
                  
                  // Dates Section
                  Text(
                    'Employment Period',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _selectStartDate(),
                              child: AbsorbPointer(
                                child: _buildTextField(_startDateController, 'MM/YYYY', maxLines: 1, maxlen: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      
                      // End Date or Present
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            GestureDetector(
                              onTap: _isPresent ? null : () => _selectEndDate(),
                              child: AbsorbPointer(
                                child: _buildTextField(
                                  _endDateController,
                                  _isPresent ? 'Present' : 'MM/YYYY',
                                  maxLines: 1,
                                  maxlen: 10,
                                  enabled: !_isPresent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Present Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isPresent,
                        onChanged: (bool? value) {
                          safeSetState(() {
                            _isPresent = value ?? false;
                            if (_isPresent) {
                              _endDateController.clear();
                            }
                          });
                        },
                        fillColor: WidgetStateProperty.all(Color(0xffa393eb)),
                        checkColor: Colors.white,
                      ),
                      Text(
                        'I currently work here',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Add Experience Button - Matches AddSkillsPage button style
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addExperienceToForm(),
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
                            'Add Experience',
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

                  // Experiences List Section - Matches AddSkillsPage structure
                  if (_experiencesList.isNotEmpty) ...[
                    Text(
                      'Your Experiences (${_experiencesList.length})',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Experiences List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _experiencesList.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildExperienceItem(_experiencesList[index], index);
                      },
                    ),
                    
                    SizedBox(height: 24),
                  ] else ...[
                    // Empty State - Matches AddSkillsPage style
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
                            'No experiences added yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first work experience',
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

          // Bottom Buttons - Matches AddSkillsPage exactly
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
      {int maxLines = 1, int maxlen = 32, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxlen,
        enabled: enabled,
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

  Widget _buildExperienceItem(Experience experience, int index) {
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
            color: Color(0xffa393eb).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.work_outline,
            color: Color(0xffa393eb),
            size: 20,
          ),
        ),
        title: Text(
          experience.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              experience.companyName,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${_formatDateMonthYear(DateTime.parse(experience.startDate))} - ${experience.endDate == null ? 'Present' : _formatDateMonthYear(DateTime.parse(experience.endDate!))}',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _removeExperience(index),
          icon: Icon(
            Icons.delete_outline,
            color: Color(0xffff9c9c),
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      safeSetState(() {
        _startDateController.text = _formatDateForInput(picked);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      safeSetState(() {
        _endDateController.text = _formatDateForInput(picked);
      });
    }
  }

  String _formatDateForInput(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  String _formatDateMonthYear(DateTime date) {
    return DateFormat.yMMM().format(date);
  }

  void _addExperienceToForm() {
    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog("Please enter a job title");
      return;
    }
    
    if (_companyNameController.text.trim().isEmpty) {
      _showErrorDialog("Please enter a company name");
      return;
    }
    
    if (_startDateController.text.trim().isEmpty) {
      _showErrorDialog("Please select a start date");
      return;
    }
    
    if (!_isPresent && _endDateController.text.trim().isEmpty) {
      _showErrorDialog("Please select an end date or mark as present");
      return;
    }

    // Parse dates for validation
    DateTime startDate;
    DateTime? endDate;
    
    try {
      startDate = DateFormat('MM/yyyy').parse(_startDateController.text.trim());
      if (!_isPresent) {
        endDate = DateFormat('MM/yyyy').parse(_endDateController.text.trim());
      }
    } catch (e) {
      _showErrorDialog("Please enter valid dates in MM/YYYY format");
      return;
    }
    
    // Check endDate is not before startDate, unless _isPresent
    if (!_isPresent && endDate!.isBefore(startDate)) {
      _showErrorDialog("End date cannot be before start date");
      return;
    }

    // Format dates for API (YYYY-MM-DD format)
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String? formattedEndDate = _isPresent ? null : DateFormat('yyyy-MM-dd').format(endDate!);

    _addExperience(
      _titleController.text.trim(),
      _companyNameController.text.trim(),
      formattedStartDate,
      formattedEndDate,
    );
  }

  Future<void> _continueToNext() async {
    if (_experiencesList.isEmpty) {
      if (
        _titleController.text.trim().isNotEmpty &&
        _companyNameController.text.trim().isNotEmpty &&
        _startDateController.text.trim().isNotEmpty &&
        !(!_isPresent && _endDateController.text.trim().isEmpty)
      ) {
        _addExperienceToForm();
      } else {
        _showErrorDialog("Please add at least one experience or skip this step");
        return;
      }
    }

    safeSetState(() {
      _isLoading = true;
    });

    try {
      await Future.wait(_experiencesList.map((exp) {
        String? tmpEndDate = exp.endDate;
        return apiClient.post(
          '${ApiClient.baseBackendUrl}/experiences/create/', 
          'json',
          {
            "company_name": exp.companyName.replaceAll('\n', ' '),
            "title": exp.title.replaceAll('\n', ' '),
            "description": exp.description?.replaceAll(RegExp(r'\n{3,}'), '\n\n'),
            "city_or_online": exp.cityOrOnline,
            "state": exp.state,
            "country": exp.country,
            "start_date": exp.startDate,
            "end_date": tmpEndDate,
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
          builder: (context) => AddEducationPage(),
        ),
      );

    } on DioException catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      String errorMessage = "Failed to save experiences. Please try again.";
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey("detail")) {
            errorMessage = "Unexpected error received";
          } else if (data.containsKey("end_date")) {
            final endDateErrors = data["end_date"];
            errorMessage = "End Date Error: ${endDateErrors.join(", ")}";
          } else if (data.containsKey("start_date")) {
            final startDateErrors = data["start_date"];
            errorMessage = "Start Date Error: ${startDateErrors.join(", ")}";
          } else if (data.containsKey("company_name")) {
            final companyErrors = data["company_name"];
            errorMessage = "Company Error: ${companyErrors.join(", ")}";
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
        builder: (context) => AddEducationPage(),
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