import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../api_services.dart';
import '../main_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String? bookType;
  final int? currentPage;
  final String? pagePath;

  DocumentUploadScreen({
    Key? key,
    this.bookType,
    this.currentPage,
    this.pagePath, required String category,
  }) : super(key: key);

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _documents = []; // List to hold multiple documents
  List<String> _documentTypes = [];
  late TabController _tabController;

  // Fields to store user info from SharedPreferences
  String _state = '';
  String _district = '';
  String _taluka = '';
  bool _isLoading = false;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _fetchDocumentList(); // Fetch document types when the screen initializes
    _documents.add({'type': '', 'file': null}); // Initialize with one document entry
  }

  Future<void> _fetchDocumentList() async {
    try {
      final documentTypes = await apiService.fetchDocumentList();
      setState(() {
        _documentTypes = documentTypes;
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
    });
  }

  Future<void> _pickFile(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _documents[index]['file'] = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
    }
  }

  bool _hasValidDocument() {
    return _documents.any((doc) =>
    doc['type'] != null && doc['type']!.isNotEmpty && doc['file'] != null);
  }

  Future<void> _uploadFiles() async {
    if (!_hasValidDocument()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all documents before submitting')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
      );
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      return;
    }

    final uri = Uri.parse('https://e-office.acttconnect.com/api/add-user-document');

    try {
      for (var document in _documents) {
        var request = http.MultipartRequest('POST', uri)
          ..fields['user_id'] = userId
          ..fields['document_type'] = document['type'];
          // ..fields['state'] = _state
          // ..fields['district'] = _district
          // ..fields['taluka'] = _taluka;

        if (document['file'] != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'documents[0][document_name]', document['file']!.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No file selected for document type ${document['type']}')),
          );
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
          return;
        }
        final response = await request.send();
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = await response.stream.bytesToString();
          print('File uploaded successfully: $responseBody');
        } else {
          final responseBody = await response.stream.bytesToString();
          print('Failed to upload file: $responseBody');
        }
      }

      // Clear the documents list and reset state
      setState(() {
        _documents.clear();
        _documents.add({'type': '', 'file': null}); // Reinitialize with one document entry
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files uploaded and reset successfully')),
      );
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during file upload'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  dispose() {
    _tabController.dispose();
    super.dispose();
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
        title: Text('Document Upload',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Color(0xFF4769B2),
        bottom: TabBar(
          physics: NeverScrollableScrollPhysics(),
          unselectedLabelColor: Colors.white,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          controller: _tabController,
          tabs: [
            Tab(text: 'Upload Document'),
            Tab(text: 'View Document'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Document List
                          Column(
                            children: _documents.map((doc) {
                              int index = _documents.indexOf(doc);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: doc['type']?.isEmpty ?? true
                                                    ? null
                                                    : doc['type'],
                                                decoration: InputDecoration(
                                                  labelText: 'Document Type',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: _documentTypes
                                                    .map((docType) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: docType,
                                                    child: Text(docType),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _documents[index]['type'] =
                                                        value ?? '';
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(40, 40),
                                                backgroundColor:
                                                Color(0xFF4769B2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () => _pickFile(index),
                                              child: Icon(Icons.upload_file,
                                                  color: Colors.white),
                                            ),
                                            if (index > 0)
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                color: Colors.red,
                                                onPressed: () {
                                                  setState(() {
                                                    _documents.removeAt(index);
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                        if (_documents[index]['file'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              'File: ${_documents[index]['file']!.path.split('/').last}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _documents.add(
                                      {'type': '', 'file': null});
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4769B2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Add Another Document',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spacer(),
                    if(_hasValidDocument())
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _uploadFiles,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Color(0xFF4769B2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : Text(
                            'Upload Documents',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Document List'),
                          subtitle: Text('View all uploaded documents'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // Ensure the Row takes up minimal space
                            children: [
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  // Share functionality
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  // View functionality
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.download),
                                onPressed: () {
                                  // Download functionality
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
