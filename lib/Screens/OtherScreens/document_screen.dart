import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
    this.pagePath,
    required String category,
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
  List<Map<String, dynamic>> _uploadedDocuments = [];
  bool _isLoading = false;
  ApiService apiService = ApiService();

  Future<void> _fetchUploadedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
      );
      return;
    }
    final uri = Uri.parse(
        'https://e-office.acttconnect.com/api/view-user-documents?user_id=$userId');
    try {
      final response = await http.post(uri);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _uploadedDocuments = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching uploaded documents')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _fetchDocumentList(); // Fetch document types when the screen initializes
    _documents
        .add({'type': '', 'file': null}); // Initialize with one document entry

    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _tabController.index == 1) {
        _fetchUploadedDocuments(); // Fetch uploaded documents on tab change
      }
    });
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
        SnackBar(
            content: Text('Please complete all documents before submitting')),
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

    final uri =
        Uri.parse('https://e-office.acttconnect.com/api/add-user-document');

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId;

      // Loop through the documents to add them to the request
      for (var i = 0; i < _documents.length; i++) {
        var document = _documents[i];

        if (document['file'] != null) {
          // Get the file path
          String filePath = document['file']!.path;

          // Create a multipart file from the path
          var multipartFile = await http.MultipartFile.fromPath(
            'documents[$i][file]',
            filePath,
          );

          // Add the multipart file
          request.files.add(multipartFile);

          // Add the document name and type for each file
          request.fields['documents[$i][name]'] =
              document['type'] ?? 'Untitled'; // Use document type for name
          request.fields['documents[$i][document_type]'] =
              document['type'] ?? ''; // Document type
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'No file selected for document type ${document['type']}')),
          );
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
          return;
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['error'] == false) {
          setState(() {
            // Process the saved documents to show the correct file names and types
            final savedDocuments =
                jsonResponse['data']['saved_documents'] as List;

            for (var i = 0; i < savedDocuments.length; i++) {
              // Match the saved document with the corresponding local document
              final savedDocument = savedDocuments[i];
              final localDocument = _documents[i];

              // Replace 'doc_name' with the selected document type
              savedDocument['doc_name'] = localDocument['type'] ?? 'Untitled';
              // Replace 'document' with the original file name
              savedDocument['document'] =
                  localDocument['file']?.path.split('/').last ?? 'Unknown';
            }

            // Optionally, you can display a success message or update the UI with the correct details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Documents submitted successfully')),
            );

            // Clear the documents list and reset state
            _documents.clear();
            _documents.add({
              'type': '',
              'file': null,
              'name': ''
            }); // Reinitialize with one document entry
          });
        } else {
          print('Failed to upload files: $responseBody');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(jsonResponse['message'] ?? 'Failed to upload files')),
          );
        }
      } else {
        print('Failed to upload files: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload files')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during file upload')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _downloadFile(String? documentName, String? docName) async {
    if (documentName == null || documentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No document available to download')),
      );
      return;
    }

    final documentUrl = 'https://e-office.acttconnect.com/images/$documentName';

    // Request storage permissions
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    try {
      final response = await http.get(Uri.parse(documentUrl));

      if (response.statusCode == 200) {
        // Get the directory to save the file
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/$documentName';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download file')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while downloading the file')),
      );
    }
  }

  Future<void> _downloadAndPreviewFile(BuildContext context, String documentName) async {
    if (documentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No document available to preview')),
      );
      return;
    }

    // Construct the URL for the image
    final String url = 'https://e-office.acttconnect.com/images/$documentName';

    // Get the temporary directory to save the file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$documentName';

    try {
      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save the file to the temporary directory
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Show the image or PDF in an AlertDialog
        _showPreviewDialog(context, filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Preview document')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during file preview')),
      );
    }
  }

  void _showPreviewDialog(BuildContext context, String filePath) {
    // Get the file extension
    final fileExtension = filePath.split('.').last;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Document Preview'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Set a fixed height
            child: fileExtension == 'pdf'
                ? PDFView(filePath: filePath) // PDF display
                : Image.file(File(filePath)), // Image display
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }




  Future<void> _shareFile(String? documentName) async {
    if (documentName == null || documentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No document available to share')),
      );
      return;
    }

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/$documentName';
    final file = File(filePath);

    if (await file.exists()) {
      // Create an XFile from the file
      final xFile = XFile(filePath);
      // Share the file using the share_plus package
      await Share.shareXFiles([xFile], text: 'Check out this document: $documentName');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File does not exist, please download it first')),
      );
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
                                                value:
                                                    doc['type']?.isEmpty ?? true
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
                                            padding:
                                                const EdgeInsets.only(top: 8),
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
                                  _documents.add({'type': '', 'file': null});
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
                    if (_hasValidDocument())
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    'Upload Documents',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _uploadedDocuments.length,
                        itemBuilder: (context, index) {
                          final document = _uploadedDocuments[index];
                          return ListTile(
                            title: Text(document['doc_name'] ?? 'Untitled'),
                            subtitle: Text(document['document'] ?? 'No file'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // Ensure the Row takes up minimal space
                              children: [
                                IconButton(
                                  icon: Icon(Icons.download),
                                  onPressed: () => _downloadFile(document['document'], document['doc_name']),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    if (document['document'] != null) {
                                      _downloadAndPreviewFile(context, document['document']);
                                    }
                                  }
                                ),
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () => _shareFile(document['document']),
                                ),
                              ],
                            ),
                          );

                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// user_id   1
// documents[0][name]   pan_card
// documents[0][file]   file
// documents[1][name]   aa_card
// documents[1][file]   file
