import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';

class CompassScreen extends StatefulWidget {
  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final TripController tripController = Get.find<TripController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<TripController>(
          builder: (tripController) {
            return SingleChildScrollView(
              child: Column(
                children: tripController.tripList.map((trip) {
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        'Trip Name: ${trip.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destination: ${trip.destination}',
                              style: TextStyle(fontSize: 14)),
                          Text('Start Date: ${trip.startDate}',
                              style: TextStyle(fontSize: 14)),
                          Text('End Date: ${trip.endDate}',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          print(trip.name);
                          tripController.deleteTrip(trip.id!);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open the dialog to add a new trip
          showDialog(
            context: context,
            builder: (context) => AddTripDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTripDialog extends StatefulWidget {
  @override
  _AddTripDialogState createState() => _AddTripDialogState();
}

class _AddTripDialogState extends State<AddTripDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  final TripController tripController = Get.find<TripController>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Trip'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Trip Name'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: destinationController,
            decoration: InputDecoration(labelText: 'Destination'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: startDateController,
            decoration: InputDecoration(labelText: 'Start Date'),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                startDateController.text =
                    "${pickedDate.toLocal().toLocal()}".split(' ')[0];
              }
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: endDateController,
            decoration: InputDecoration(labelText: 'End Date'),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                endDateController.text =
                    "${pickedDate.toLocal().toLocal()}".split(' ')[0];
              }
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Validate input before adding the trip
            if (nameController.text.isNotEmpty &&
                destinationController.text.isNotEmpty &&
                startDateController.text.isNotEmpty &&
                endDateController.text.isNotEmpty) {
              tripController.setTripName(nameController.text);
              tripController.setTripDestination(destinationController.text);
              tripController.setTripStartDate(startDateController.text);
              tripController.setTripEndDate(endDateController.text);

              // Call the method to add the trip
              tripController.addTrip();

              // Clear text fields after adding the trip
              nameController.clear();
              destinationController.clear();
              startDateController.clear();
              endDateController.clear();

              // Close the dialog
              Navigator.pop(context);
            } else {
              // Show an error message or handle invalid input
              // For simplicity, you can show a SnackBar with an error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill in all fields.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text('Add Trip'),
        ),
      ],
    );
  }
}
