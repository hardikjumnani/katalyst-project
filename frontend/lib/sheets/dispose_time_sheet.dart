import 'package:flutter/material.dart';

class DisposeTimeSheet extends StatelessWidget {
  const DisposeTimeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            // color: Colors.pink,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispose Time',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Select after how much time should your moment be disposed.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Button
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: () {}, 
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('None'),
                ),
                OutlinedButton(
                  onPressed: () {}, 
                  child: Text('24 Hours'),
                ),
                OutlinedButton(
                  onPressed: () {}, 
                  child: Text('7 Days'),
                ),
                OutlinedButton(
                  onPressed: () {}, 
                  child: Text('1 Month'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
