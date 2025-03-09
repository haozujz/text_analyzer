import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => showPopover(
            context: context,
            bodyBuilder: (context) => MenuItems(),
            width: 180,
            height: 50,
            direction: PopoverDirection.bottom,
          ),
      child: const Icon(Icons.more_vert),
    );
  }
}

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Handle the save action here
            print("Save clicked");
            Navigator.pop(context); // Close the popover after clicking
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue, // You can style the text here
              ),
            ),
          ),
        ),
      ],
    );
  }
}
