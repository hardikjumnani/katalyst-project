import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shakala/main.dart';
import 'package:shakala/app_classes/education.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class AddEducationPage extends StatefulWidget {
  const AddEducationPage({super.key});

  @override
  State<AddEducationPage> createState() => _AddEducationState();
}

class _AddEducationState extends State<AddEducationPage> {
  final apiClient = ApiClient();

  List<School> schoolsList = [];
  List<Degree> degreesList = [];
  List<FieldOfStudy> fieldOfStudyList = [];

  School? selectedSchool;
  Degree? selectedDegree;
  FieldOfStudy? selectedFieldOfStudy;

  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isPresent = false;

  final List<Education> _educationsList = [];

  bool _isLoading = false;

  void _addEducation(School school, Degree degree, FieldOfStudy fieldOfStudy, String startDate, String? endDate) {
    safeSetState(() {
      _educationsList.add(
        Education(
          school: school,
          degree: degree,
          fieldOfStudy: fieldOfStudy,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      _schoolNameController.text = '';
      _degreeController.text = '';
      _fieldOfStudyController.text = '';
      selectedSchool = null;
      selectedDegree = null;
      selectedFieldOfStudy = null;
      _startDateController.text = '';
      _endDateController.text = '';
      _isPresent = false;
    });
  }

  void _removeEducation(int index) {
    safeSetState(() {
      _educationsList.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }
  
  @override
  void dispose() {
    _schoolNameController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final schoolRes = await apiClient.get("${ApiClient.baseBackendUrl}/educations/schools/", auth: true);
      final degreeRes = await apiClient.get("${ApiClient.baseBackendUrl}/educations/degrees/", auth: true);
      final fieldRes  = await apiClient.get("${ApiClient.baseBackendUrl}/educations/fields/", auth: true);

      safeSetState(() {
        schoolsList = (schoolRes['data'] as List).map((e) => School.fromJson(e)).toList();
        degreesList = (degreeRes['data'] as List).map((e) => Degree.fromJson(e)).toList();
        fieldOfStudyList  = (fieldRes['data'] as List).map((e) => FieldOfStudy.fromJson(e)).toList();
      });
    } catch (e) {
      print("Error loading dropdown data");
    }
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
                    'Add Education',
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
                    'Add Your Education',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Share your educational background',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  
                  SizedBox(height: 40),

                  // Education Input Section - Matches AddSkillsPage structure
                  Text(
                    'Add New Education',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // School Name
                  Text(
                    'School Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildSchoolDropdown(),
                  
                  SizedBox(height: 16),
                  
                  // Degree
                  Text(
                    'Degree',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDegreeDropdown(),
                  
                  SizedBox(height: 16),
                  
                  // Field of Study
                  Text(
                    'Field of Study',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildFieldOfStudyDropdown(),
                  
                  SizedBox(height: 16),
                  
                  // Dates Section
                  Text(
                    'Education Period',
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
                        'I currently study here',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Add Education Button - Matches AddSkillsPage button style
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addEducationToForm(),
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
                            'Add Education',
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

                  // Educations List Section - Matches AddSkillsPage structure
                  if (_educationsList.isNotEmpty) ...[
                    Text(
                      'Your Education (${_educationsList.length})',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Educations List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _educationsList.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildEducationItem(_educationsList[index], index);
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
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.white30,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No education added yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first education',
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

  Widget _buildSchoolDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<School>(
          dropdownColor: Color(0xFF3a3a3a),
          value: selectedSchool,
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select School',
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
          onChanged: (School? newValue) {
            safeSetState(() {
              selectedSchool = newValue;
              if (newValue != null) {
                _schoolNameController.text = newValue.name;
              }
            });
          },
          items: schoolsList
              .map<DropdownMenuItem<School>>((School school) {
            return DropdownMenuItem<School>(
              value: school,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${school.city}, ${school.state}, ${school.country}',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDegreeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Degree>(
          dropdownColor: Color(0xFF3a3a3a),
          value: selectedDegree,
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Degree',
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
          onChanged: (Degree? newValue) {
            safeSetState(() {
              selectedDegree = newValue;
              if (newValue != null) {
                _degreeController.text = newValue.name;
              }
            });
          },
          items: degreesList
              .map<DropdownMenuItem<Degree>>((Degree degree) {
            return DropdownMenuItem<Degree>(
              value: degree,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(degree.name),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFieldOfStudyDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FieldOfStudy>(
          dropdownColor: Color(0xFF3a3a3a),
          value: selectedFieldOfStudy,
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Field of Study',
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
          onChanged: (FieldOfStudy? newValue) {
            safeSetState(() {
              selectedFieldOfStudy = newValue;
              if (newValue != null) {
                _fieldOfStudyController.text = newValue.name;
              }
            });
          },
          items: fieldOfStudyList
              .map<DropdownMenuItem<FieldOfStudy>>((FieldOfStudy field) {
            return DropdownMenuItem<FieldOfStudy>(
              value: field,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(field.name),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEducationItem(Education education, int index) {
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
            Icons.school_outlined,
            color: Color(0xffa393eb),
            size: 20,
          ),
        ),
        title: Text(
          education.school.name,
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
              education.degree.name,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 2),
            Text(
              education.fieldOfStudy.name,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '${_formatDateMonthYear(DateTime.parse(education.startDate))} - ${education.endDate == null ? 'Present' : _formatDateMonthYear(DateTime.parse(education.endDate!))}',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _removeEducation(index),
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

  void _addEducationToForm() {
    if (selectedSchool == null) {
      _showErrorDialog("Please select a school");
      return;
    }
    
    if (selectedDegree == null) {
      _showErrorDialog("Please select a degree");
      return;
    }
    
    if (selectedFieldOfStudy == null) {
      _showErrorDialog("Please select a field of study");
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

    _addEducation(
      selectedSchool!,
      selectedDegree!,
      selectedFieldOfStudy!,
      formattedStartDate,
      formattedEndDate,
    );
  }

  Future<void> _continueToNext() async {
    if (_educationsList.isEmpty) {
      if (
        selectedSchool != null &&
        selectedDegree != null &&
        selectedFieldOfStudy != null &&
        _startDateController.text.trim().isNotEmpty &&
        !(!_isPresent && _endDateController.text.trim().isEmpty)
      ) {
        _addEducationToForm();
      } else {
        _showErrorDialog("Please add at least one education or skip this step");
        return;
      }
    }

    safeSetState(() {
      _isLoading = true;
    });

    try {
      await Future.wait(_educationsList.map((edu) {
        String? tmpEndDate = edu.endDate;
        return apiClient.post(
          '${ApiClient.baseBackendUrl}/educations/create/', 
          'json',
          {
            "school_id": edu.school.id,
            "degree_id": edu.degree.id,
            "field_of_study_id": edu.fieldOfStudy.id,
            "start_date": edu.startDate,
            "end_date": tmpEndDate,
          },
          auth: true,
        );
      }));

      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainApp(showUser: null,)),
        (Route<dynamic> route) => false,
      );
      
    } on DioException catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      String errorMessage = "Failed to save education. Please try again.";
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey("detail")) {
            // errorMessage = "Error: ${data["detail"]}";
            errorMessage = "Unexpected error received";
          } else if (data.containsKey("end_date")) {
            final endDateErrors = data["end_date"];
            errorMessage = "End Date Error: ${endDateErrors.join(", ")}";
          } else if (data.containsKey("start_date")) {
            final startDateErrors = data["start_date"];
            errorMessage = "Start Date Error: ${startDateErrors.join(", ")}";
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainApp(showUser: null,)),
      (Route<dynamic> route) => false,
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