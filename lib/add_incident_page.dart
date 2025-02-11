import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';


class AddIncidentPage extends StatefulWidget {
  @override
  _AddIncidentPageState createState() => _AddIncidentPageState();
}

class _AddIncidentPageState extends State<AddIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [TextEditingController()];
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _otherIncidentTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _aiSummaryController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _witnessesController = TextEditingController();



  String? _selectedIncidentType;
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;

  final List<String> incidentTypes = [
    'Bribery',
    'Embezzlement',
    'Fraud',
    'Abuse of Power',
    'Nepotism',
    'Other',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _incidentDate) {
      setState(() {
        _incidentDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _incidentTime) {
      setState(() {
        _incidentTime = picked;
      });
    }
  }

  void _addNameField() {
    if (_nameControllers.length < 6) {
      setState(() {
        _nameControllers.add(TextEditingController());
      });
    }
  }

  void _removeNameField(int index) {
    if (_nameControllers.length > 1) {
      setState(() {
        _nameControllers.removeAt(index);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    _locationController.text = '${position.latitude}, ${position.longitude}';
  }

  Future<void> _selectLocationOnMap() async {
    // Implement map selection logic here
    // For now, just a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Map selection not implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Incident'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ..._nameControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Text('Enter the name of the officer involved.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(index == 0 ? Icons.add : Icons.remove),
                            onPressed: index == 0
                                ? (_nameControllers.length < 6 ? _addNameField : null)
                                : () => _removeNameField(index),
                            color: index == 0 && _nameControllers.length >= 6
                                ? Colors.grey
                                : null,
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text('Location of incident.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                      ),
                      IconButton(
                        icon: Icon(Icons.map),
                        onPressed: _selectLocationOnMap,
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedIncidentType,
                hint: Text('Type of Incident'),
                items: incidentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedIncidentType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the type of incident';
                  }
                  return null;
                },
              ),
              if (_selectedIncidentType == 'Other')
                TextFormField(
                  controller: _otherIncidentTypeController,
                  decoration: InputDecoration(
                    labelText: 'Specify Other Incident Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedIncidentType == 'Other' && (value == null || value.isEmpty)) {
                      return 'Please specify the incident type';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(_incidentDate == null
                    ? 'Select Date of Incident'
                    : 'Date: ${DateFormat.yMd().format(_incidentDate!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(_incidentTime == null
                    ? 'Select Time of Incident'
                    : 'Time: ${_incidentTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description of Incident',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description of the incident';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _aiSummaryController,
                decoration: InputDecoration(
                  labelText: 'AI Summarized',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                readOnly: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _severityController,
                decoration: InputDecoration(
                  labelText: 'Severity',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the severity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Government Department/Official Involved',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the department or official involved';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _witnessesController,
                decoration: InputDecoration(
                  labelText: 'Witnesses (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Incident reported successfully!')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );

  }
} 