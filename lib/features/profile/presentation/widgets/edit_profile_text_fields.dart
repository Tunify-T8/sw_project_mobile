import 'package:flutter/material.dart';

class EditProfileTextFields extends StatelessWidget {//controller are better 3lshan aen kolo bat7akem fih mel main screen y3ni ay api aw 7aga htt8yr msh hy2asar feya
  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController bioController;
  final VoidCallback onChanged;
  final VoidCallback onCountryTap; // to select the country from the menu

  const EditProfileTextFields({////these are the required parameters to be passed mynf3sh w7da mttb3etsh
    super.key,
    required this.nameController,
    required this.cityController,
    required this.countryController,
    required this.bioController,
    required this.onChanged,
    required this.onCountryTap, // for the country 
  });

  Widget buildField(String label, TextEditingController controller,
      {int maxLength = 50}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: (_) => onChanged(),
    //   user types something → TextField fires onChanged(_) → widget calls onChanged()→ screen runs setState(() => _hasChanges = true) el asln maktoobe fel edit screen
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        counterStyle: const TextStyle(color: Colors.white70),//7atet di 3lshan el counter yzhar
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          buildField('Display Name', nameController),
          buildField('City', cityController, maxLength: 35),
          ////buildField('Country', countryController, maxLength: 35),
            ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Country', style: TextStyle(color: Colors.white70)),
                subtitle: Text(countryController.text, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: onCountryTap,
            ),
          ///////
          buildField('Bio', bioController),
          //buildField('Genre', genreController),
        ],
      ),
    );
  }
}