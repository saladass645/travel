import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/models/trip_model.dart';

class TripChecklistScreen extends StatelessWidget {
  final Trip trip;
  final TripController tripController = Get.find<TripController>();

  TripChecklistScreen({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.name} Checklist'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display trip information here (destination, start date, end date, etc.)
              // You can use the same format as in NotificationScreen
              Text('Destination: ${trip.destination}'),
              Text('Start Date: ${trip.startDate}'),
              Text('End Date: ${trip.endDate}'),

              SizedBox(height: 16),

              // Input trip checklist
              TextField(
                controller: tripController.checklistItemController,
                decoration: InputDecoration(
                  labelText: 'Checklist Item',
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await tripController.addChecklist(
                    trip.id!,
                    tripController.checklistItemController.text,
                  );
                  tripController.checklistItemController.clear();
                },
                child: Text('Add Item'),
              ),

              SizedBox(height: 16),

              // Display checklist items
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tripController.checklistName
                      .where((checklist) => checklist["tripId"] == trip.id)
                      .map((checklist) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(checklist["item"]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            tripController.deleteChecklist(
                              trip.id!,
                              checklist['item'],
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
