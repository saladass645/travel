import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_model.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;
  final TripController tripController = Get.put(TripController());

  TripDetailsScreen({required this.trip});

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
              SizedBox(height: 16),
              Obx(
                () => tripController.tripList.isEmpty
                    ? Text('No trip details available.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tripController.tripList.map((details) {
                          return ListTile(
                            leading: Icon(Icons
                                .check_circle), // Placeholder icon for each trip detail
                            title:
                                Text('Travel Method: ${details.travelMethod}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Accommodation: ${details.accommodation}'),
                                Text('Budget: ${details.budget}'),
                                Text(
                                    'Number of People: ${details.numberOfPeople}'),
                                Text('Extra Notes: ${details.extraNotes}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context);
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Trip Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: tripController.travelMethodController,
                decoration: InputDecoration(labelText: 'Travel Method'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: tripController.accommodationController,
                decoration: InputDecoration(labelText: 'Accommodation'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: tripController.budgetController,
                decoration: InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: tripController.numberOfPeopleController,
                decoration: InputDecoration(labelText: 'Number of People'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: tripController.extraNotesController,
                decoration: InputDecoration(labelText: 'Extra Notes'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Save entered trip details
                  var tripDetails = TripDetails(
                    travelMethod: tripController.travelMethodController.text,
                    accommodation: tripController.accommodationController.text,
                    budget:
                        double.tryParse(tripController.budgetController.text) ??
                            0.0,
                    numberOfPeople: int.tryParse(
                            tripController.numberOfPeopleController.text) ??
                        0,
                    extraNotes: tripController.extraNotesController.text,
                  );

                  print("Saving Trip Details: $tripDetails");

                  tripController.saveDetails(trip.id!, tripDetails);

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text('Save Details'),
              ),
            ],
          ),
        );
      },
    );
  }
}
