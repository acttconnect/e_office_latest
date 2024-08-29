import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // Ensure this import is present
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://e-office.acttconnect.com/api/';

  // Function to log in and store response
  static Future<void> login(String mobileNumber) async {
    final url = Uri.parse('${_baseUrl}login-via-mobile');
    final headers = {"Content-Type": "application/x-www-form-urlencoded"};
    final body = {'mobile': mobileNumber};

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['msg'] == 'Login Successfully') {
          final prefs = await SharedPreferences.getInstance();
          final birthDateString = data['data']['birth_date'] ?? '';
          final formattedBirthDate = _formatDate(birthDateString);
          await prefs.setString('id', data['data']['id'].toString());
          await prefs.setString('first_name', data['data']['first_name'] ?? '');
          await prefs.setString('middle_name', data['data']['middle_name'] ?? '');
          await prefs.setString('last_name', data['data']['last_name'] ?? '');
          await prefs.setString('number', data['data']['number']);
          await prefs.setString('address', data['data']['address'] ?? '');
          await prefs.setString('state', data['data']['state'] ?? '');
          await prefs.setString('district', data['data']['district'] ?? '');
          await prefs.setString('taluka', data['data']['taluka'] ?? '');
          await prefs.setInt('leaves', data['data']['leaves']);
          await prefs.setString('email', data['data']['email'] ?? '');
          await prefs.setString('caste', data['data']['caste'] ?? '');
          await prefs.setString('address_B', data['data']['address_B'] ?? '');
          await prefs.setString('father_name', data['data']['father_name'] ?? '');
          await prefs.setString('father_address', data['data']['father_address'] ?? '');
          await prefs.setString('birth_date', formattedBirthDate);
          await prefs.setString('birth_text', data['data']['birth_text'] ?? '');
          await prefs.setString('birth_mark', data['data']['birth_mark'] ?? '');
          await prefs.setString('height', data['data']['height'] ?? '');
          await prefs.setString('qualification', data['data']['qualification'] ?? '');
          await prefs.setString('another_qualification', data['data']['another_qualification'] ?? '');
          await prefs.setString('digital_sig', data['data']['digital_sig'] ?? '');
          await prefs.setString('digital_sig_verify', data['data']['digital_sig_verify'] ?? '');
          await prefs.setString('certificate_no', data['data']['certificate_no'] ?? '');
          await prefs.setString('post_name', data['data']['post_name'] ?? '');
          await prefs.setString('created_at', data['data']['created_at'] ?? '');
          await prefs.setString('updated_at', data['data']['updated_at'] ?? '');
          await prefs.setBool('login_status', data['data']['login_status'] ?? false);
        } else {
          throw Exception('Login failed: ${data['msg']}');
        }
      } else {
        throw Exception('Failed to login: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow; // Propagate the exception
    }
  }

  // Function to format the birth date
  static String _formatDate(String dateString) {
    try {
      // Handle the specific date format
      if (dateString == null || dateString.isEmpty || dateString == '-000001-11-30T00:00:00.000000Z') {
        return 'Not Available';
      }

      DateTime parsedDate = DateTime.parse(dateString.replaceAll('Z', ''));
      return '${parsedDate.day}-${parsedDate.month}-${parsedDate.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Function to get stored user data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('id'),
      'first_name': prefs.getString('first_name'),
      'middle_name': prefs.getString('middle_name'),
      'last_name': prefs.getString('last_name'),
      'number': prefs.getString('number'),
      'address': prefs.getString('address'),
      'state': prefs.getString('state'),
      'district': prefs.getString('district'),
      'taluka': prefs.getString('taluka'),
      'leaves': prefs.getInt('leaves'),
      'email': prefs.getString('email'),
      'caste': prefs.getString('caste'),
      'address_B': prefs.getString('address_B'),
      'father_name': prefs.getString('father_name'),
      'father_address': prefs.getString('father_address'),
      'birth_date': prefs.getString('birth_date'),
      'birth_text': prefs.getString('birth_text'),
      'birth_mark': prefs.getString('birth_mark'),
      'height': prefs.getString('height'),
      'qualification': prefs.getString('qualification'),
      'another_qualification': prefs.getString('another_qualification'),
      'digital_sig': prefs.getString('digital_sig'),
      'digital_sig_verify': prefs.getString('digital_sig_verify'),
      'certificate_no': prefs.getString('certificate_no'),
      'post_name': prefs.getString('post_name'),
      'created_at': prefs.getString('created_at'),
      'updated_at': prefs.getString('updated_at'),
      'login_status': prefs.getBool('login_status'),
    };
  }

  Future<void> submitLeaveRequest({
    required String state,
    required String district,
    required String taluka,
    required DateTime leaveStartDate,
    required DateTime leaveEndDate,
    required DateTime leaveAppliedStartDate,
    required DateTime leaveAppliedEndDate,
    required String leaveSubject,
    required String leaveDescription,
  }) async {
    final url = Uri.parse('$_baseUrl/add-leaves');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'state': state,
        'district': district,
        'taluka': taluka,
        'leave_start_date': leaveStartDate.toIso8601String(),
        'leave_end_date': leaveEndDate.toIso8601String(),
        'leave_applied_start_date': leaveAppliedStartDate.toIso8601String(),
        'leave_applied_end_date': leaveAppliedEndDate.toIso8601String(),
        'leave_subject': leaveSubject,
        'leave_description': leaveDescription,
      }),
    );

    if (response.statusCode == 200) {
      // Request was successful
      print('Leave request submitted successfully.');
    } else {
      // Handle error
      print('Failed to submit leave request. Status code: ${response.statusCode}');
    }
  }
  Future<List<String>> fetchDocumentList() async {
    final response = await http.post(Uri.parse('https://e-office.acttconnect.com/api/document-list'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> documentList = jsonResponse['data'];
        return documentList.map<String>((doc) => doc['doc_name'] as String).toList();
      } else {
        throw Exception('Failed to load document list');
      }
    } else {
      throw Exception('Failed to load document list');
    }
  }



}
