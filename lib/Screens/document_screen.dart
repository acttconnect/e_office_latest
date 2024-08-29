import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../api_services.dart';
import 'main_screen.dart';
import 'package:http/http.dart' as http;
class DocumentUploadScreen extends StatefulWidget {
  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  List<PlatformFile> _selectedFiles = []; // Define _selectedFiles to hold picked files
  List<PlatformFile> _filteredFiles = []; // Define _filteredFiles to display selected files
  List<String> _documentTypes = [];
  String _selectedDocumentType = '';
  File? _file;

  // Fields to store user info from SharedPreferences
  String _state = '';
  String _district = '';
  String _taluka = '';
  String _username = '';

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _filteredFiles = _selectedFiles; // Initialize _filteredFiles
    _loadUserData();
    _fetchDocumentList(); // Fetch document types when the screen initializes
  }

  Future<void> _fetchDocumentList() async {
    try {
      final documentTypes = await apiService.fetchDocumentList();
      setState(() {
        _documentTypes = documentTypes;
        _selectedDocumentType = _documentTypes.isNotEmpty ? _documentTypes.first : '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching document list: $e')),
      );
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _state = prefs.getString('state') ?? 'N/A';
      _district = prefs.getString('district') ?? 'N/A';
      _taluka = prefs.getString('taluka') ?? 'N/A';
      _username = prefs.getString('first_name') ?? 'N/A'; // Check if the key is correct
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }


  Future<void> _uploadFile() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id'); // Fetch the user ID from SharedPreferences

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    final uri = Uri.parse('https://e-office.acttconnect.com/api/add-user-document');
    var request = http.MultipartRequest('POST', uri);

    // Add the user ID field to the request
    request.fields['user_id'] = userId;
    request.fields['document_type'] = _selectedDocumentType;
    request.fields['state'] = _state;
    request.fields['district'] = _district;
    request.fields['taluka'] = _taluka;

    // Add the file to the request
    request.files.add(await http.MultipartFile.fromPath('documents[0][document_name]', _file!.path));

    try {
      // Print request details for debugging
      print('Sending request to: $uri');
      print('User ID: ${request.fields['user_id']}');
      print('File path: ${_file!.path}');
      print('File size: ${await _file!.length()} bytes');

      final response = await request.send();

      // Print response status and body for debugging
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody'); // Print response body for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully')),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to upload file. Response body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $responseBody')),
        );
      }
    } catch (e) {
      print('Exception: $e'); // Print exception details for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
        title: Text('Document Upload', style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Color(0xFF4769B2),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: _state,
              decoration: InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
              ),
              readOnly: true,
            ),
            SizedBox(height: 10,),
            TextFormField(
              initialValue: _district,
              decoration: InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10,),
            TextFormField(
              initialValue: _taluka,
              decoration: InputDecoration(
                labelText: _taluka,
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10,),
            TextFormField(
              initialValue: _username,
              decoration: InputDecoration(
                labelText: _username,
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _documentTypes.isNotEmpty ? _selectedDocumentType : null,
              decoration: InputDecoration(
                labelText: 'Document Type',
                border: OutlineInputBorder(),
              ),
              items: _documentTypes.map((docType) {
                return DropdownMenuItem<String>(
                  value: docType,
                  child: Text(docType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDocumentType = value ?? '';
                });
              },
            ),
            SizedBox(height: 16),

            if (_filteredFiles.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Selected files:\n${_filteredFiles.map((file) => file.name).join('\n')}',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4769B2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _pickFile();
                    },
                    child: Text('Add Document', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4769B2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: (){
                      _uploadFile();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Upload', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
