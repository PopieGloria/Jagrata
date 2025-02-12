import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';


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

  late final GenerativeModel _model;
  bool _isGeneratingSummary = false;

  @override
  void initState() {
    super.initState();
    // Initialize the Gemini model
    _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.0-pro');
  }

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

  Future<void> _generateSummary() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description first')),
      );
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      final prompt = [
        Content.text(
          '''Generate a formal and structured summary of this incident report. Use markdown formatting:
          - Use # for main headings
          - Use ** for bold important points
          - Use proper paragraphs with line breaks

          Include the following sections:
          1. # Introduction
             - Type of corruption and when it occurred
          2. # Detailed Analysis
             - Comprehensive explanation with **key points highlighted**
          3. # Impact Assessment
             - Severity analysis and potential consequences
          4. # Contextual Information
             - Relevant details about department/officials

          Incident Description:
          ${_descriptionController.text}'''
        )
      ];

      final response = await _model.generateContent(prompt);
      
      setState(() {
        _aiSummaryController.text = response.text ?? 'Unable to generate summary';
      });
    } catch (e) {
      print('Error generating summary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating AI summary: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGeneratingSummary = false;
      });
    }
  }

  Widget _buildAISummaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'AI Structured Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (_isGeneratingSummary)
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B86E5)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                height: 300,
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _aiSummaryController,
                  maxLines: null,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'AI summary will appear here',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4, left: 8),
          child: Text(
            'Supports markdown formatting',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Color(0xFF7EB6FF), // Light blue
            Color(0xFF5B86E5), // Medium blue
            Color(0xFF36D1DC), // Cyan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isGeneratingSummary ? null : _generateSummary,
        icon: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.hexagon_outlined,
              size: 28,
              color: Colors.white,
            ),
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
        label: Text(
          'Generate Summary using AI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
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
                  helperText: 'Provide detailed description of the incident',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the incident';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildGenerateButton(),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildAISummaryField(),
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _aiSummaryController.dispose();
    // ... (dispose other controllers)
    super.dispose();
  }
} 