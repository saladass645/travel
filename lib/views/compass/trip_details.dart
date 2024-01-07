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
                () => tripController.tripList.isEmpty
                    ? Text('No trip details available.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tripController.tripList.map((details) {
                          return ListTile(
                            leading: Icon(Icons
                                .check_circle), // Placeholder icon for each trip detail
                            title: Text(
                                'Travel Method: ${trip.details?.travelMethod}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Accommodation: ${trip.details?.accommodation}'),
                                Text('Budget: ${trip.details?.budget}'),
                                Text(
                                    'Number of People: ${trip.details?.numberOfPeople}'),
                                Text('Notes: ${trip.details?.extraNotes}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
                TextFormField(
                  controller: tripController.travelMethodController,
                  decoration: InputDecoration(labelText: 'Travel Method'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the travel method';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: tripController.accommodationController,
                  decoration: InputDecoration(labelText: 'Accommodation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the accommodation';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: tripController.budgetController,
                  decoration: InputDecoration(labelText: 'Budget'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the budget';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: tripController.numberOfPeopleController,
                  decoration: InputDecoration(labelText: 'Number of People'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of people';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: tripController.extraNotesController,
                  decoration: InputDecoration(labelText: 'Extra Notes'),
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
