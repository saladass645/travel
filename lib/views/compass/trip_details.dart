import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_model.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  final TripController tripController = Get.put(TripController());

  TripDetailsScreen({required this.trip});

  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Trip trip;
  late TripController tripController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    tripController = widget.tripController;
    tripController.getTripDetails(tripController.uid, trip.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info), // Placeholder icon for trip information
                  SizedBox(width: 8),
                  Text(
                    'Trip Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text('Trip Name: ${trip.name}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Destination: ${trip.destination}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Start Date: ${trip.startDate}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('End Date: ${trip.endDate}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Divider(), // Horizontal line as a page break
              Row(
                children: [
                  Icon(Icons.details), // Placeholder icon for trip details
                  SizedBox(width: 8),
                  Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Obx(
                () {
                  List<Trip> detailsForCurrentTrip = tripController.tripList
                      .where((details) => details.id == trip.id)
                      .toList();

                  return detailsForCurrentTrip.isEmpty
                      ? Text('No trip details available for the current trip.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: detailsForCurrentTrip.map((details) {
                            return ListTile(
                                leading: Icon(Icons.check_circle),
                                title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.directions_car),
                                          SizedBox(width: 8),
                                          Text(
                                              'Travel Method: ${trip.details?.travelMethod}'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.hotel),
                                          SizedBox(width: 8),
                                          Text(
                                              'Accommodation: ${trip.details?.accommodation}'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.attach_money),
                                          SizedBox(width: 8),
                                          Text(
                                              'Budget: ${trip.details?.budget}'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.people),
                                          SizedBox(width: 8),
                                          Text(
                                              'Number of People: ${trip.details?.numberOfPeople}'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.notes),
                                          SizedBox(width: 8),
                                          Text(
                                              'Notes: ${trip.details?.extraNotes}'),
                                        ],
                                      ),
                                    ]));
                          }).toList(),
                        );
                },
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(context);
        },
        child: Icon(Icons.edit),
      ),
    );
  }

// Inside _showForm method
  void _showForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Trip Details:'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(
                  controller: tripController.travelMethodController,
                  labelText: 'Travel Method',
                  icon: Icons.directions_car,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the travel method';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: tripController.accommodationController,
                  labelText: 'Accommodation',
                  icon: Icons.hotel,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the accommodation';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: tripController.budgetController,
                  labelText: 'Budget',
                  keyboardType: TextInputType.number,
                  icon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the budget';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: tripController.numberOfPeopleController,
                  labelText: 'Number of People',
                  keyboardType: TextInputType.number,
                  icon: Icons.people,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of people';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: tripController.extraNotesController,
                  labelText: 'Notes',
                  icon: Icons.notes,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveTripDetails();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save Details'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
            ),
            keyboardType: keyboardType,
            validator: validator,
          ),
        ),
      ],
    );
  }

  void _saveTripDetails() async {
    try {
      var tripDetails = TripDetails(
        travelMethod: tripController.travelMethodController.text,
        accommodation: tripController.accommodationController.text,
        budget: double.tryParse(tripController.budgetController.text) ?? 0.0,
        numberOfPeople:
            int.tryParse(tripController.numberOfPeopleController.text) ?? 0,
        extraNotes: tripController.extraNotesController.text,
      );

      print("Saving Trip Details: $tripDetails");

      await tripController.updateTripDetails(trip.id!, tripDetails);
    } catch (e) {
      // Handle the error, show a snackbar, or log it
      print("Error updating trip details: $e");
    }
  }
}
