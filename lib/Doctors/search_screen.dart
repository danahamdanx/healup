import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ehr_detail_screen.dart'; // Screen for detailed EHR view
import 'package:flutter/foundation.dart'; // For kIsWeb


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedFilter = 'patient_name'; // Default filter
  bool _isLoading = false; // To show loading indicator
  String _errorMessage = ''; // To show error message

  // List of search filters
  final List<String> _filters = [
    'patient_name',
    'doctor_name',
    'appointment_date',
  ];

  // Function to handle search
  void _searchEHR() async {
    if(kIsWeb){
      if (_searchController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter a search term';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = ''; // Clear previous error messages
      });

      ApiService apiService = ApiService();
      Map<String, String> searchCriteria = {
        _selectedFilter: _searchController.text,
      };

      try {
        List<Map<String, dynamic>> results = await apiService.searchEHR(searchCriteria);

        // Check if no results are found
        if (results.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No records found matching your search criteria';
          });
        } else {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No records found matching your search criteriasd';
        });
      }

    }
    else{
      if (_searchController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter a search term';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = ''; // Clear previous error messages
      });

      ApiService apiService = ApiService();
      Map<String, String> searchCriteria = {
        _selectedFilter: _searchController.text,
      };

      try {
        List<Map<String, dynamic>> results = await apiService.searchEHR(searchCriteria);

        // Check if no results are found
        if (results.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No records found matching your search criteria';
          });
        } else {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No records found matching your search criteriasd';
        });
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,  // لإزالة سهم التراجع

          title: Text('Search EHR Records',style: TextStyle(color: Colors.white70),),
          backgroundColor: Color(0xff414370),
          elevation: 6,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter dropdown
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Color(0xff414370), // Set background color to the desired color
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                        },
                        isExpanded: true,
                        items: _filters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Color(0xff414370),
                        iconEnabledColor: Colors.white70,
                        style: TextStyle(color: Color(0xff414370)),
                        borderRadius: BorderRadius.circular(30),
                        underline: SizedBox.shrink(),
                      ),
                    ),

                    // Search input field
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Enter search term',
                          filled: true,
                          fillColor: Colors.grey[400]!.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: Icon(Icons.search, color: Color(0xff414370)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff414370),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    // Search Button
                    _isLoading
                        ? Center(
                      child: CircularProgressIndicator(color: Color(0xff414370)),
                    )
                        : SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _searchEHR,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Color(0xff414370),
                          shadowColor: Color(0xff414370).withOpacity(0.6),
                          elevation: 6,
                        ),
                        child: Text(
                          'Search',
                          style: TextStyle(color: Colors.white70, fontSize: 22),
                        ),
                      ),
                    ),

                    // Error message display if there is an error or no results
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Color(0xff800020), fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Search results
                    if (_searchResults.isNotEmpty) ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            var ehr = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EHRDetailScreen(ehr: ehr),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 6,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white70,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xff414370),
                                    child: Text(
                                      ehr['patient_name'][0].toUpperCase(),
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  title: Text(
                                    ehr['patient_name'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    '${ehr['doctor_name']} - ${ehr['appointment_date']}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    else{
      return Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,  // لإزالة سهم التراجع

          title: Text('Search EHR Records',style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xff414370),
          elevation: 6,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter dropdown
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color(0xff414370), // Set background color to the desired color
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: _filters.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                          child: Text(
                            value.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: Color(0xff414370),
                    iconEnabledColor: Colors.white70,
                    style: TextStyle(color: Color(0xff414370)),
                    borderRadius: BorderRadius.circular(30),
                    underline: SizedBox.shrink(),
                  ),
                ),

                // Search input field
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter search term',
                      filled: true,
                      fillColor: Colors.grey[400]!.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: Icon(Icons.search, color: Color(0xff414370)),
                      // Customize focused border color here
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff414370), // This is the color for the focused border
                          width: 2.0, // Optionally adjust the border width
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      // Customize the border color when the TextField is not focused
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey, // Default color when not focused
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),

                ),

                // Search Button
                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(color: Color(0xff414370)),
                )
                    : SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _searchEHR,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color(0xff414370),
                      shadowColor: Color(0xff414370).withOpacity(0.6),
                      elevation: 6,
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(color: Colors.white70, fontSize: 22),
                    ),
                  ),
                ),

                // Error message display if there is an error or no results
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Color(0xff800020), fontSize: 16,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Search results
                if (_searchResults.isNotEmpty) ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var ehr = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EHRDetailScreen(ehr: ehr),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 6,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Color(0xffd4dcee),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xff414370),
                                child: Text(
                                  ehr['patient_name'][0].toUpperCase(),
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              title: Text(
                                ehr['patient_name'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                '${ehr['doctor_name']} - ${ehr['appointment_date']}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

    }

  }
}

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api/healup/ehr/search';
  final String baseUrl2 = 'http://localhost:5000/api/healup/ehr/search';

  Future<List<Map<String, dynamic>>> searchEHR(Map<String, String> searchCriteria) async {
    if(kIsWeb){
      try {
        final response = await http.post(
          Uri.parse(baseUrl2),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(searchCriteria),
        );

        if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body)['ehrRecords'];
          return jsonResponse.map((ehr) => Map<String, dynamic>.from(ehr)).toList();
        } else {
          throw Exception('Failed to load EHR records');
        }
      } catch (e) {
        throw Exception('Error: $e');
      }

    }
    else{
      try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(searchCriteria),
        );

        if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body)['ehrRecords'];
          return jsonResponse.map((ehr) => Map<String, dynamic>.from(ehr)).toList();
        } else {
          throw Exception('Failed to load EHR records');
        }
      } catch (e) {
        throw Exception('Error: $e');
      }

    }

  }
}
