import 'package:flutter/material.dart';

class SpecialExploreSheet extends StatefulWidget {
  const SpecialExploreSheet({super.key});

  @override
  State<SpecialExploreSheet> createState() => _SpecialExploreSheetState();
}

class _SpecialExploreSheetState extends State<SpecialExploreSheet> {
  String? selectedMode;

  void selectMode(String mode) {
    setState(() {
      selectedMode = mode;
    });
  }

  Widget buildModeButton(String label) {
    final isSelected = selectedMode == label;

    return OutlinedButton(
      onPressed: () => selectMode(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        minimumSize: Size.zero,
        backgroundColor: isSelected ? const Color(0xffa393eb) : Colors.transparent,
        foregroundColor: isSelected ? Colors.black : Colors.white,
        side: BorderSide(
          color: const Color(0xffa393eb),
          width: 2.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.3, 0.8],
            colors: [Color(0xff2a2a2a), Color(0xff111111)], // Background gradient
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Closing bar (drag handle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
      
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Describe your potential connection',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
      
            // Textfield
            TextField(
              maxLines: null,
              minLines: 10,
              style: TextStyle(
                color: Colors.white
              ),
              decoration: InputDecoration(
                hintText: 'What kind of connection are you looking for ...?',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
      
            // Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Modes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '(Optional)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildModeButton('Mentor'),
                      buildModeButton('Ally'),
                      buildModeButton('Guide'),
                    ],
                  ),
                ],
              ),
            ),
      
            // Search Button
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
              height: 45,
              width: 180,
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xffffffff),
                    backgroundColor: Color(0xffa393eb),
                    side: BorderSide(
                      color: Color(0xffa393eb),
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Search'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
