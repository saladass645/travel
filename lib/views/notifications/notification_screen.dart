import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/notifications/trip_checklist_screen.dart'; // Import the new screen

class NotificationScreen extends StatelessWidget {
  final TripController tripController = Get.put(TripController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Checklist'),
      ),
      body: Obx(
        () => tripController.tripList.isEmpty
            ? Center(
                child: Text('No trips available. Create a new one!'),
              )
            : ListView.builder(
                itemCount: tripController.tripList.length,
                itemBuilder: (context, index) {
                  Trip trip = tripController.tripList[index];
                  return _buildTripCard(context, trip);
                },
              ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Navigate to the TripChecklistScreen when a card is tapped
          Get.to(() => TripChecklistScreen(trip: trip));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.name ?? "",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Destination: ${trip.destination}'),
              SizedBox(height: 8),
              Text('Start Date: ${trip.startDate}'),
              SizedBox(height: 8),
              Text('End Date: ${trip.endDate}'),
            ],
          ),
        ),
      ),
    );
  }
}
