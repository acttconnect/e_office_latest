import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Models/leave_count.dart';
import 'Models/receipt_by_status.dart';
import 'Models/receipt_model.dart';

class ApiService {
  static const String _baseUrl = 'https://e-office.acttconnect.com/api';

  // static Future<void> login(String mobileNumber) async {
  //   final url = Uri.parse('${_baseUrl}/login-via-mobile');
  //   final headers = {"Content-Type": "application/x-www-form-urlencoded"};
  //   final body = {'mobile': mobileNumber};
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = json.decode(response.body);
  //
  //       if (data['msg'] == 'Login Successfully') {
  //         final prefs = await SharedPreferences.getInstance();
  //         final birthDateString = data['data']['birth_date'] ?? '';
  //         final formattedBirthDate = _formatDate(birthDateString);
  //
  //         // Save each piece of data with null safety checks
  //         await prefs.setString('id', data['data']['id']?.toString() ?? '');
  //         print(' this is my userID: ${data['data']['id']}');
  //         await prefs.setString('otp', data['data']['otp']?.toString() ?? '');
  //         await prefs.setString('first_name', data['data']['first_name'] ?? '');
  //         await prefs.setString(
  //             'middle_name', data['data']['middle_name'] ?? '');
  //         await prefs.setString('last_name', data['data']['last_name'] ?? '');
  //         await prefs.setString('number', data['data']['number'] ?? '');
  //         await prefs.setString(
  //             'joining_date', data['data']['joining_date'] ?? '');
  //         await prefs.setString('address', data['data']['address'] ?? '');
  //         await prefs.setString('state', data['data']['state'] ?? '');
  //         await prefs.setString('district', data['data']['district'] ?? '');
  //         await prefs.setString('taluka', data['data']['taluka'] ?? '');
  //         await prefs.setInt('leaves', data['data']['leaves'] ?? 0);
  //         await prefs.setString('email', data['data']['email'] ?? '');
  //         await prefs.setString('caste', data['data']['caste'] ?? '');
  //         await prefs.setString('address_B', data['data']['address_B'] ?? '');
  //         await prefs.setString(
  //             'father_name', data['data']['father_name'] ?? '');
  //         await prefs.setString(
  //             'father_address', data['data']['father_address'] ?? '');
  //         await prefs.setString('birth_date', formattedBirthDate);
  //         await prefs.setString('birth_text', data['data']['birth_text'] ?? '');
  //         await prefs.setString('birth_mark', data['data']['birth_mark'] ?? '');
  //         await prefs.setString('gender', data['data']['gender'] ?? '');
  //         await prefs.setString('joining_start_salary',
  //             data['data']['joining_start_salary'] ?? '');
  //         await prefs.setString('height', data['data']['height'] ?? '');
  //         await prefs.setString(
  //             'qualification', data['data']['qualification'] ?? '');
  //         await prefs.setString('another_qualification',
  //             data['data']['another_qualification'] ?? '');
  //         await prefs.setString(
  //             'digital_sig', data['data']['digital_sig'] ?? '');
  //         await prefs.setString(
  //             'digital_sig_verify', data['data']['digital_sig_verify'] ?? '');
  //         await prefs.setString(
  //             'certificate_no', data['data']['certificate_no'] ?? '');
  //         await prefs.setString('post_name', data['data']['post_name'] ?? '');
  //         await prefs.setString('created_at', data['data']['created_at'] ?? '');
  //         await prefs.setString('updated_at', data['data']['updated_at'] ?? '');
  //         await prefs.setBool(
  //             'login_status', data['data']['login_status'] ?? false);
  //       } else {
  //         throw Exception('Login failed: ${data['msg']}');
  //       }
  //     } else {
  //       throw Exception('Failed to login: ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     rethrow; // Propagate the exception
  //   }
  // }


  static Future<Map<String, dynamic>> login(String mobileNumber) async {
    final url = Uri.parse('https://e-office.acttconnect.com/api/login-via-mobile?mobile=$mobileNumber');
    final response = await http.post(url);

    if (response.statusCode == 200|| response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['msg'] == 'OTP sent successfully') {
        // Return both the message and the OTP
        return {
          'msg': responseData['msg'],
          'otp': responseData['otp']
        };
      } else {
        throw Exception('Error: ${responseData['msg']}');
      }
    } else {
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    final url = Uri.parse('$_baseUrl/verify-otp?mobile=$mobile&otp=$otp');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'status': 'success',
          'data': responseData
        };
      } else {
        return {
          'status': 'error',
          'message': 'Failed to verify OTP'
        };
      }
    } catch (error) {
      return {
        'status': 'error',
        'message': 'An error occurred: $error'
      };
    }
  }
  // Function to format the birth date
  static String _formatDate(String dateString) {
    try {
      // Handle the specific date format
      if (dateString.isEmpty ||
          dateString == '-000001-11-30T00:00:00.000000Z') {
        return 'Not Available';
      }

      DateTime parsedDate = DateTime.parse(dateString.replaceAll('Z', ''));
      return '${parsedDate.day}-${parsedDate.month}-${parsedDate.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }


  Future<void> submitLeaveRequest({
    required String userId,
    required DateTime leaveStartDate,
    required DateTime leaveEndDate,
    required DateTime leaveAppliedStartDate,
    required DateTime leaveAppliedEndDate,
    required String leaveSubject,
    required String leaveDescription,
    required String leaveCategory,
    required String isFromTotalLeave,
    required String totalLeaveDays,
  }) async {
    final url = Uri.parse('$_baseUrl/add-leaves');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'user_id': userId,
          'leave_category': leaveCategory,
          'subject': leaveSubject,
          'description': leaveDescription,
          'start_date': leaveStartDate.toIso8601String(),
          'end_date': leaveEndDate.toIso8601String(),
          'apply_start_date': leaveAppliedStartDate.toIso8601String(),
          'apply_end_date': leaveAppliedEndDate.toIso8601String(),
          'is_from_total_leave': isFromTotalLeave,
          'total_leave_days': totalLeaveDays.toString(),
          // Ensure totalLeaveDays is included
        }),
      );
      print('User ID: $userId');
      print('Leave Start Date: $leaveStartDate');
      print('Leave End Date: $leaveEndDate');
      print('Leave Applied Start Date: $leaveAppliedStartDate');
      print('Leave Applied End Date: $leaveAppliedEndDate');
      print('Leave Subject: $leaveSubject');
      print('Leave Description: $leaveDescription');
      print('Leave Category: $leaveCategory');
      print('Is From Total Leave: $isFromTotalLeave');
      print('Total Leave Days: $totalLeaveDays');


      if (response.statusCode == 200|| response.statusCode == 201) {
        // Handle successful response if needed
        print('Leave request submitted successfully');
      } else {
        // Handle errors here based on response status code
        throw Exception('Failed to submit leave request: ${response.body}');
      }
    } catch (e) {
      rethrow;
      // Handle exceptions
      print('Error occurred: $e');
      throw Exception('Error occurred while submitting leave request: $e');
    }
  }

  Future<List<String>> fetchDocumentList() async {
    final response = await http.post(Uri.parse('$_baseUrl/document-list'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> documentList = jsonResponse['data'];
        return documentList
            .map<String>((doc) => doc['doc_name'] as String)
            .toList();
      } else {
        throw Exception('Failed to load document list');
      }
    } else {
      throw Exception('Failed to load document list');
    }
  }

  Future<List<String>> fetchChecklistNames() async {
    final response = await http.post(
      Uri.parse('https://e-office.acttconnect.com/api/get-book-checklist'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        // Extract checklist names from the response
        return (data['data'] as List)
            .map((item) => item['checklist_name'] as String)
            .toList();
      } else {
        throw Exception('Failed to load checklist');
      }
    } else {
      throw Exception('Failed to load checklist');
    }
  }

  Future<GetReceiptResponse> getReceipt(String userId) async {
    var url = Uri.parse('$_baseUrl/get-receipt?user_id=$userId');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetReceiptResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load receipts');
      }
    } catch (e) {
      throw Exception('Error fetching receipts: $e');
    }
  }

  Future<LeaveCountResponse?> getLeaveCount(int userId) async {
    final String url = "$_baseUrl/get-leave-count?user_id=$userId";
    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return LeaveCountResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load leave count');
      }
    } catch (e) {
      print("Error fetching leave count: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getSalary(int userId) async {
    final response = await http.post(Uri.parse(
        'https://e-office.acttconnect.com/api/get-salary?user_id=$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load salary');
    }
  }

  Future<ReceiptByStatus> fetchReceiptsByStatus(int userId) async {
    final response = await http.post(
      Uri.parse('https://e-office.acttconnect.com/api/getreceiptbystatus?user_id=$userId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ReceiptByStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load receipts');
    }
  }


  Future<bool> submitPromotion({
    required String designation,
    required String additionalSalary,
    required String incrementType,
    required String incrementName,
    required String description,
    required String incrementDate,
    required String salaryCalculationType,
    required String additionalAmount,
    String? filePath,
    String? userSignature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add-promotion'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'designation': designation,
          'additional_salary': additionalSalary,
          'increment_type': incrementType,
          'increment_name': incrementName,
          'description': description,
          'increment_date': incrementDate,
          'salary_calculation_type': salaryCalculationType,
          'additional_amount': additionalAmount,
          'file_path': filePath,
          'user_signature': userSignature,
        }),
      );

      // Check if the response was successful
      return response.statusCode == 200;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}

//page_file  somefile
//checklist_name  some name
//process_status  yes or no
//receipt_process_status Apply or No Apply
//receipt_number  some number
//Status  Pending
//receipt_status in process
//user_id  1