import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_app/components/custom_field.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
//import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/compass/trip_details.dart';
//import 'package:travel_app/views/home/search_option_screen.dart';

class CompassScreen extends GetWidget<TripController> {
  final TripController tripController = TripController();
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  CompassScreen({Key? key}) : super(key: key);

  void openTripBox(BuildContext context, {int? editId}) {
    // If editId is provided, populate fields for editing
    if (editId != null) {
      Trip editTrip =
          tripController.tripList.firstWhere((trip) => trip.id == editId);
      tripNameController.text = editTrip.name!;
      destinationController.text = editTrip.destination!;
      startDateController.text = editTrip.startDate!;
      endDateController.text = editTrip.endDate!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Trip Information'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              CustomField(
                controller: tripNameController,
                hintText: 'Trip Name',
                hint: 'Trip Name',
                readOnly: false,
              ),
              SizedBox(height: 10),
              CustomField(
                controller: destinationController,
                hintText: 'Destination',
                hint: 'Destination',
                readOnly: false,
              ),
              SizedBox(height: 10),
              CustomField(
                controller: startDateController,
                hintText: 'Start Date',
                readOnly: true,
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
                hint: 'Start Date',
              ),
              SizedBox(height: 10),
              CustomField(
                controller: endDateController,
                hintText: 'End Date',
                readOnly: true,
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
                hint: 'End Date',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Handle saving the trip information
              if (editId != null) {
                // Editing existing trip
                tripController.editTrip(editId);
              } else {
                // Adding new trip
                tripController.addTrip();
              }

              tripNameController.clear();
              destinationController.clear();
              startDateController.clear();
              endDateController.clear();

              Navigator.pop(context); // Close the dialog
            },
            child: Text(editId != null ? "Save" : "Add"),
          )
        ],
      ),
    );
  }

  void viewTripDetails(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Your Trip'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Obx(
              () => Column(
                children: tripController.tripList.map((trip) {
                  return GestureDetector(
                    onTap: () {
                      viewTripDetails(context, trip);
                    },
                    child: Card(
                      elevation: 5,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                openTripBox(context, editId: trip.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                tripController.deleteTrip(trip.id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openTripBox(context);
        },
        child: const Icon(LineIcons.plus),
      ),
    );
  }
}
