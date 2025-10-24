import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shakala/app_classes/experience.dart';
import 'package:shakala/services/api_client.dart';

class EditExperiencesSheet extends StatefulWidget {
  final Experience? experience;

  const EditExperiencesSheet({super.key, this.experience});

  @override
  State<EditExperiencesSheet> createState() => _EditExperiencesSheetState();
}

class _EditExperiencesSheetState extends State<EditExperiencesSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isPresent = false;

  String _locationType = 'On-Site';

  @override
  void initState() {
    super.initState();

    final exp = widget.experience;
    if (exp != null) {
      _titleController.text = exp.title;
      _companyNameController.text = exp.companyName;
      _descriptionController.text = exp.description ?? '';
      _startDateController.text = exp.startDate;
      _endDateController.text = exp.endDate;

      if (exp.cityOrOnline == '<ONLINE>') {
        _locationType = 'Remote';
      } else {
        _locationType = 'On-Site';
        _cityController.text = exp.cityOrOnline ?? '';
        _stateController.text = exp.state ?? '';
        _countryController.text = exp.country ?? '';
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false, // allow top edge to be rounded but keep bottom safe
        child: DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          initialChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xff222222),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar with close button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ],
                      ),
                    ),
      
                    _buildTextField(_titleController, 'Title', maxLines: 1, maxlen: 32),
      
                    _buildTextField(_companyNameController, 'Company Name', minLines: 1, maxLines: 5, maxlen: 32),
      
                    _buildTextField(_descriptionController, 'Description', minLines: 3, maxLines: 6, maxlen: 256),
      
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xff222222),
                        value: _locationType,
                        decoration: InputDecoration(
                          labelText: 'Location Type',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: const Color(0xff111111),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: ['On-Site', 'Remote']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _locationType = value;
                              if (_locationType == 'Remote') {
                                _cityController.clear();
                                _stateController.clear();
                                _countryController.clear();
                              }
                            });
                          }
                        },
                      ),
                    ),
      
                    if (_locationType == 'On-Site') ...[
                      _buildTextField(_cityController, 'City', maxLines: 1),
                      _buildTextField(_stateController, 'State', maxLines: 1),
                      _buildTextField(_countryController, 'Country', maxLines: 1),
                    ],
      
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
      
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        height: 45,
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () async {
                            final title = _titleController.text.trim();
                            final companyName = _companyNameController.text.trim();
                            final description = _descriptionController.text.trim();
                            final startDate = _startDateController.text.trim();
                            final endDate = _endDateController.text == '' ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : _endDateController.text.trim();
      
                            final location = _locationType == 'Remote' ? '<ONLINE>' : _cityController.text.trim();
                            final state = _locationType == 'Remote' ? null : _stateController.text.trim();
                            final country = _locationType == 'Remote' ? null : _countryController.text.trim();
      
                            if (title.isEmpty || companyName.isEmpty || startDate.isEmpty || (endDate.isEmpty && _isPresent == false)) {
                              showInfoDialog(context, "Please fill all the fields.");
                              return;
                            }
      
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => Center(child: CircularProgressIndicator()),
                            );
      
                            final data = {
                              "title": title.replaceAll('\n', ' '),
                              "company_name": companyName.replaceAll('\n', ' '),
                              "description": description.replaceAll(RegExp(r'\n+'), '\n'),
                              "start_date": startDate,
                              "end_date": endDate,
                              "city_or_online": location.replaceAll('\n', ' '),
                              "state": state?.replaceAll('\n', ' '),
                              "country": country?.replaceAll('\n', ' '),
                            };
      
                            try {
                              final apiClient = ApiClient();
                              dynamic response;
      
                              if (widget.experience != null) {
                                data["exp_id"] = widget.experience!.expId!;
                                response = await apiClient.patch(
                                  '${ApiClient.baseBackendUrl}/experiences/update/',
                                  data,
                                  auth: true,
                                );
                              } else {
                                response = await apiClient.post(
                                  '${ApiClient.baseBackendUrl}/experiences/create/',
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
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xffa393eb),
                            side: const BorderSide(color: Color(0xffa393eb), width: 2.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
      {int minLines = 1, int maxLines = 1, bool enabled = true, int maxlen = 32}) {
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
            maxLength: maxlen,
            decoration: InputDecoration(
              counterText: '',
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
