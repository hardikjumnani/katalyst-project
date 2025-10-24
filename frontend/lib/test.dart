import 'package:flutter/material.dart';

class DynamicTextFieldList extends StatefulWidget {
  const DynamicTextFieldList({super.key});
  @override
  State<DynamicTextFieldList> createState() => _DynamicTextFieldListState();
}

class _DynamicTextFieldListState extends State<DynamicTextFieldList> {
  final List<TextEditingController> _controllers = [];

  void _addCategoryField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to free memory
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildCategoryFields() {
    return Column(
      children: List.generate(_controllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _controllers[index],
            decoration: InputDecoration(
              labelText: 'Category ${index + 1}',
              border: OutlineInputBorder(),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCategoryFields(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCategoryField,
                child: Text('Add Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}