import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_office/Screens/OtherScreens/document_screen.dart';
import 'package:e_office/Screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_checklist.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cross_file/cross_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:http/http.dart' as http;

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PdfViewerController _oldBookController;
  late PdfViewerController _eBookController;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _pageController =
      TextEditingController(); // For page input
  bool isOldBookDownloading = true;
  bool isEBookDownloading = true;
  String? oldBookPath;
  String? eBookPath;
  final String oldBookUrl =
      'https://e-office.acttconnect.com/eofficeManual.pdf';
  final String eBookUrl = 'https://e-office.acttconnect.com/eofficeManual.pdf';
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  Timer? _debounce;
  int _searchResultIndex = 0;
  List<String> _searchResults = [];
  bool _isLoading = false;
  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _oldBookController = PdfViewerController();
    _eBookController = PdfViewerController();
    print(oldBookUrl);
    _downloadPdf(oldBookUrl, 'old_book.pdf', isOldBook: true);
    _downloadPdf(eBookUrl, 'e_book.pdf', isOldBook: false);
    _searchController.addListener(_onSearchChanged);
    _fetchCategories();
  }

  Future<void> _downloadPdf(String url, String fileName,
      {required bool isOldBook}) async {
    String filePath =
        '${(await getApplicationDocumentsDirectory()).path}/$fileName';

    if (File(filePath).existsSync()) {
      if (await _isFileComplete(filePath)) {
        setState(() {
          if (isOldBook) {
            oldBookPath = filePath;
            isOldBookDownloading = false;
          } else {
            eBookPath = filePath;
            isEBookDownloading = false;
          }
        });
        return;
      } else {
        File(filePath).deleteSync();
      }
    }

    try {
      await Dio().download(url, filePath);
      setState(() {
        if (isOldBook) {
          oldBookPath = filePath;
          isOldBookDownloading = false;
        } else {
          eBookPath = filePath;
          isEBookDownloading = false;
        }
      });
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Failed to download ${isOldBook ? 'Old Book' : 'eBook'} PDF. Please try again later.")),
      );
    }
  }

  Future<bool> _isFileComplete(String filePath) async {
    return true;
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final searchText = _searchController.text;
      if (searchText.isNotEmpty) {
        setState(() {
          //
          _isLoadingSearch = true; // Start loading for search
        });
        _searchText(searchText, _tabController.index == 0);
      } else {
        setState(() {
          _searchResults = [];
          _isLoadingSearch = false; // Stop loading if input is empty
        });
      }
    });
  }

  void _searchText(String searchText, bool isOldBook) async {
    setState(() {
      _isLoadingSearch = true; // Start loading for search
    });
    await Future.delayed(Duration(seconds: 1)); // Simulate search delay
    if (isOldBook) {
      _oldBookController.searchText(searchText);
    } else {
      _eBookController.searchText(searchText);
    }
    setState(() {
      _searchResults = [];
      _isLoadingSearch = false; // Stop loading after search completes
    });
  }

  void _goToPage(String pageText) {
    if (pageText.isNotEmpty) {
      int pageIndex = int.tryParse(pageText) ?? 1;
      if (_tabController.index == 0) {
        _oldBookController.jumpToPage(pageIndex);
      } else {
        _eBookController.jumpToPage(pageIndex);
      }
    }
  }

  void _nextPage() {
    if (_tabController.index == 0) {
      _oldBookController.nextPage();
    } else {
      _eBookController.nextPage();
    }
  }

  void _previousPage() {
    if (_tabController.index == 0) {
      _oldBookController.previousPage();
    } else {
      _eBookController.previousPage();
    }
  }

  void _addToChecklist(int currentPage) async {
    File? pageFile = await downloadSpecificPageAsFile(currentPage);
    if (pageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChecklistForm(
            bookType: _tabController.index == 0 ? 'Old Book' : 'eBook',
            currentPage: currentPage,
            pageFile: pageFile,
          ),
        ),
      );
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse('https://e-office.acttconnect.com/api/document-list'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> documentList = jsonResponse['data'];
          setState(() {
            categories = documentList
                .map<String>((doc) => doc['doc_name'] as String)
                .toList();
          });
        } else {
          throw Exception('Failed to load document list');
        }
      } else {
        throw Exception('Failed to load document list');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _showCategoryDialog(int currentPage) async {
    if (categories.isEmpty) {
      return;
    }
    String? pagePath = await downloadSpecificPageAsFile(currentPage)
        .then((value) => value?.path);

    if (pagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get the page PDF')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<String>(
                      hint: Text("Select Category"),
                      value: selectedCategory,
                      style: TextStyle(color: Colors.black),
                      underline: SizedBox(),
                      isExpanded: true,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue; // Set selected category in dialog state
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  // Text('Preview of the selected page:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(
                    height: 300, // Set a fixed height for the PDF viewer
                    child: SfPdfViewer.file(
                      File(pagePath),
                      controller: PdfViewerController(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (selectedCategory != null) {
                      _uploadSelectedPage(pagePath, selectedCategory!); // Call the upload method
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a category')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> _uploadSelectedPage(String pagePath, String category) async {
    if (pagePath.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a page and category before submitting')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
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
      // Create the multipart request
      var request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId
        ..fields['doc_name'] = category;

      // Ensure the file exists
      final file = File(pagePath);
      if (await file.exists()) {
        print('File exists at: $pagePath');
        // Add the file to the request
        request.files.add(await http.MultipartFile.fromPath('documents[0][file]', file.path));
      } else {
        print('File does not exist at: $pagePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File does not exist at the specified path')),
        );
        return;
      }

      // Debugging output to check the request fields and files
      print('Request fields: ${request.fields}');
      print('Request files:');
      for (var f in request.files) {
        print(' - Filename: ${f.filename}, Length: ${f.length} bytes, Path: ${f.field}');
      }

      // Send the request
      final response = await request.send();

      // Read the response body
      final responseBody = await response.stream.bytesToString();

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('File uploaded successfully: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully')),
        );
      } else {
        print('Failed to upload file: ${response.statusCode}, Body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: ${response.statusCode}'),
          ),
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
  Future<File?> downloadSpecificPageAsFile(int pageNumber) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pagePath = '${directory.path}/page_$pageNumber.pdf';
      // Open the original PDF file
      final pdfDocument = await PdfDocument.openFile(
          _tabController.index == 0 ? oldBookPath! : eBookPath!);
      // Check if the page number is valid
      if (pageNumber < 1 || pageNumber > pdfDocument.pagesCount) {
        print('Invalid page number: $pageNumber');
        return null;
      }

      // Load the specific page
      final page = await pdfDocument.getPage(pageNumber);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
      );
      // Null check for pageImage.bytes
      if (pageImage?.bytes == null) {
        print("Failed to render the page image.");
        return null;
      }
      final pdf = pw.Document();
      // Convert the page image to a widget and add it to a new PDF document
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Image(
              pw.MemoryImage(pageImage!.bytes),
              // Ensure bytes is non-null using '!'
              fit: pw.BoxFit.contain,
            );
          },
        ),
      );
      // Save the PDF file
      final pdfFile = File(pagePath);
      await pdfFile.writeAsBytes(await pdf.save());
      // Verify the file creation
      if (await pdfFile.exists()) {
        print("File saved successfully at: $pagePath");
        return pdfFile;
      } else {
        print("Failed to save file at: $pagePath");
        return null;
      }
    } catch (e) {
      print('Error downloading the specific page: $e');
      return null;
    }
  }
  void _sharePage(BuildContext context, int currentPage) async {
    File? pdfFile = await downloadSpecificPageAsFile(currentPage);
    if (pdfFile != null && await pdfFile.exists()) {
      try {
        final xFile = XFile(pdfFile.path);
        await Share.shareXFiles([xFile], text: 'Check out this PDF page!');
        print("Sharing PDF at: ${pdfFile.path}"); // Debug print for sharing
      } catch (e) {
        print('Error sharing the file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share the PDF.')),
        );
      }
    } else {
      print('File does not exist: ${pdfFile?.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share the page or file does not exist.'),
        ),
      );
    }
  }

// Inside _BookScreenState
  void _sharePdf() async {
    String? pdfPath = _tabController.index == 0 ? oldBookPath : eBookPath;
    if (pdfPath != null && await File(pdfPath).exists()) {
      final file = XFile(pdfPath);
      await Share.shareXFiles([file], text: 'Check out this PDF!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No PDF available or file does not exist.')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _oldBookController.dispose();
    _eBookController.dispose();
    _searchController.dispose();
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4769B2),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          },
        ),
        title: _isSearching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        hintText: 'Search in PDF',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (_isLoadingSearch)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                ],
              )
            : Text('Books Screen',
                style: TextStyle(color: Colors.white, fontSize: 20)),
        bottom: TabBar(
          physics: NeverScrollableScrollPhysics(),
          unselectedLabelColor: Colors.white,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          controller: _tabController,
          tabs: [
            Tab(text: 'Old Book'),
            Tab(text: 'eBook'),
          ],
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              int currentPage = _tabController.index == 0
                  ? _oldBookController.pageNumber
                  : _eBookController.pageNumber;

              if (value == 'Add to Checklist') {
                _addToChecklist(currentPage);
              } else if (value == 'Add to Document') {
                _showCategoryDialog(currentPage);
              } else if (value == 'Share PDF') {
                _sharePdf();
              } else if (value == 'Share Page') {
                _sharePage(context, currentPage);
              } else if(value == 'Download PDF'){
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        _downloadPdf(oldBookUrl, 'old_book.pdf', isOldBook: true);
                      },
                      child: Text('Download Old Book'),
                    ),
                    ElevatedButton(
                      onPressed:(){
                        _downloadPdf(eBookUrl, 'e_book.pdf', isOldBook: false);
                      },
                      child: Text('Download eBook'),
                    ),
                  ],
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Add to Checklist',
                child: Text('Add to Checklist'),
              ),
              PopupMenuItem(
                value: 'Add to Document',
                child: Text('Add to Document'),
              ),
              PopupMenuItem(
                value: 'Share PDF',
                child: Text('Share Entire PDF'),
              ),
              PopupMenuItem(
                value: 'Share Page',
                child: Text('Share Current Page'),
              ),
              PopupMenuItem(
                value: 'Download PDF',
                child: Text('Download PDF'),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          if (_searchResults.isNotEmpty)
            SearchResultCard(
                searchResults: _searchResults,
                currentIndex: _searchResultIndex,
                onNextPressed: () {
                  setState(() {
                    _searchResultIndex++;
                    if (_searchResultIndex >= _searchResults.length) {
                      _searchResultIndex = 0;
                    }
                  });
                },
                onPreviousPressed: () {
                  setState(() {
                    _searchResultIndex--;
                    if (_searchResultIndex < 0) {
                      _searchResultIndex = _searchResults.length - 1;
                    }
                  });
                }),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(
                  child: isOldBookDownloading
                      ? CircularProgressIndicator()
                      : SfPdfViewer.network(
                    oldBookUrl, // Using the oldBookUrl
                    controller: _oldBookController,
                  ),
                ),
                Center(
                  child: isEBookDownloading
                      ? CircularProgressIndicator()
                      : SfPdfViewer.network(
                    eBookUrl, // Using the eBookUrl
                    controller: _eBookController,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                ),
                Expanded(
                  child: Container(
                    height: 30,
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                      controller: _pageController,
                      decoration: InputDecoration(
                        labelText: 'Go to ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSubmitted: _goToPage, // Navigate on submitting
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextPage,
                ),
              ],
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final List<String> searchResults;
  final int currentIndex;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;

  const SearchResultCard({
    Key? key,
    required this.searchResults,
    required this.currentIndex,
    required this.onNextPressed,
    required this.onPreviousPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search Results (${searchResults.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              searchResults[currentIndex],
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onPreviousPressed,
                ),
                Text(
                  '${currentIndex + 1}/${searchResults.length}',
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: onNextPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
