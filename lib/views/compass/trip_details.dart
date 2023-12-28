import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/models/trip_model.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  TripDetailsScreen({required this.trip});

  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late TripController tripDetailsController;

  @override
  void initState() {
    super.initState();
    tripDetailsController = TripController();
    _loadTripDetails(); // Load trip details when the screen initializes
  }

  void _loadTripDetails() {
    if (widget.trip.details != null) {
      tripDetailsController.travelMethodController.text =
          widget.trip.details!.travelMethod.toString();
      tripDetailsController.accommodationController.text =
          widget.trip.details!.accommodation.toString();
      tripDetailsController.budgetController.text =
          widget.trip.details!.budget.toString();
      tripDetailsController.numberOfPeopleController.text =
          widget.trip.details!.numberOfPeople.toString();
      tripDetailsController.extraNotesController.text =
          widget.trip.details!.extraNotes.toString();
    }
  }

  void _showDetailsForm() {
    Get.defaultDialog(
      title: 'Add Details',
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Add your form fields for trip details here
            TextFormField(
              controller: tripDetailsController.travelMethodController,
              decoration: InputDecoration(
                labelText: 'Travel Method',
                prefixIcon: Icon(Icons.directions_car),
              ),
            ),
            TextFormField(
              controller: tripDetailsController.accommodationController,
              decoration: InputDecoration(
                labelText: 'Accommodation',
                prefixIcon: Icon(Icons.hotel),
              ),
            ),
            TextFormField(
              controller: tripDetailsController.budgetController,
              decoration: InputDecoration(
                labelText: 'Budget',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            TextFormField(
              controller: tripDetailsController.numberOfPeopleController,
              decoration: InputDecoration(
                labelText: 'Number of People',
                prefixIcon: Icon(Icons.people),
              ),
            ),
            TextFormField(
              controller: tripDetailsController.extraNotesController,
              decoration: InputDecoration(
                labelText: 'Extra Notes',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            tripDetailsController.saveDetails(widget.trip.id!);
            Get.back();
          },
          child: Text('Save Details'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Name: ${widget.trip.name}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text('Destination: ${widget.trip.destination}',
                style: TextStyle(fontSize: 18)),
            Text('Start Date: ${widget.trip.startDate}',
                style: TextStyle(fontSize: 18)),
            Text('End Date: ${widget.trip.endDate}',
                style: TextStyle(fontSize: 18)),
            Divider(),
            SizedBox(height: 20),
            if (widget.trip.details != null) ...[
              Text('Your Trip Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 10),
              // Display additional details in a ListView for scrollability
              ListView(
                shrinkWrap: true,
                children: [
                  _buildDetailsItem(Icons.directions_car,
                      'Travel Method: ${widget.trip.details!.travelMethod}'),
                  _buildDetailsItem(Icons.hotel,
                      'Accommodation: ${widget.trip.details!.accommodation}'),
                  _buildDetailsItem(Icons.attach_money,
                      'Budget: ${widget.trip.details!.budget}'),
                  _buildDetailsItem(Icons.people,
                      'Number of People: ${widget.trip.details!.numberOfPeople}'),
                  _buildDetailsItem(Icons.notes,
                      'Extra Notes: ${widget.trip.details!.extraNotes}'),
                ],
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDetailsForm,
        tooltip: 'Add Details',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDetailsItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
    );
  }
}

class TripDetailsController extends GetxController {
  late TextEditingController travelMethodController;
  late TextEditingController accommodationController;
  late TextEditingController budgetController;
  late TextEditingController numberOfPeopleController;
  late TextEditingController extraNotesController;

  @override
  void onInit() {
    super.onInit();
    travelMethodController = TextEditingController();
    accommodationController = TextEditingController();
    budgetController = TextEditingController();
    numberOfPeopleController = TextEditingController();
    extraNotesController = TextEditingController();
  }
}
