import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../db/events.dart';

// Initilizing the Create Event Page
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override // The extended Stateful Widget class needs to be over-rided for custom operations
  // Calling the main body class
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Identifier for the Event
  final _formKey = GlobalKey<FormBuilderState>();
  // Components of the Event that need to be filled
  final nameController = TextEditingController(text: 'type name here');
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? startDate = DateTime.now(); // Initialize with current date
  TimeOfDay? startTime = TimeOfDay.fromDateTime(DateTime.now());
  DateTime? endDate = DateTime.now(); // Initialize with current date
  TimeOfDay? endTime = TimeOfDay.fromDateTime(DateTime.now());
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  // Prevents duplications
  bool alreadySubmitted = false;
  // GUI structure of the Create Event Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: alreadySubmitted
              ? const Text('Event Created')
              : const Text('Create Event'),
        ),
        // Title Box
        body: FormBuilder(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    //const SizedBox(height: 8),
                    // Start Date & Time Row
                    Row(
                      children: [
                        Text('starts: ${formatter.format(startDate!)}'),
                        IconButton(
                          onPressed: () {
                            Future<void> selectDate() async {
                              startDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (startDate != null) {
                                // Use the selected date as needed
                                logger.d('we got date $startDate');
                                setState(() {});
                              }
                            }

                            selectDate();
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                        //const SizedBox(height: 8),
                        IconButton(
                          onPressed: () {
                            Future<void> selectTime() async {
                              startTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (startTime != null) {
                                // Use the selected time as needed
                                logger.d('got start time $startTime');
                                startDate = DateTime(
                                    startDate!.year,
                                    startDate!.month,
                                    startDate!.day,
                                    startTime!.hour,
                                    startTime!.minute);
                                setState(() {});
                              }
                            }

                            selectTime();
                          },
                          icon: const Icon(Icons.access_time),
                        ),
                      ],
                    ),
                    //const SizedBox(height: 8),
                    // End Date & Time row
                    const Divider(),
                    Row(
                      children: [
                        Text('ends: ${formatter.format(endDate!)}'),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () {
                            Future<void> selectDate() async {
                              endDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (endDate != null) {
                                // Use the selected date as needed
                                logger.d('we got end date $endDate');
                                setState(() {});
                              }
                            }

                            selectDate();
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () {
                            Future<void> selectTime() async {
                              endTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (endTime != null) {
                                // Use the selected time as needed
                                logger.d('got end time $endTime');
                                endDate = DateTime(
                                    endDate!.year,
                                    endDate!.month,
                                    endDate!.day,
                                    endTime!.hour,
                                    endTime!.minute);
                                setState(() {});
                              }
                            }

                            selectTime();
                          },
                          icon: const Icon(Icons.access_time),
                        ),
                      ],
                    ),
                    // Location Input
                    const Divider(),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                      ),
                      controller: locationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    // const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 2,
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // Submit Button with all event details
                    SubmitButton(onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          !alreadySubmitted) {
                        logger.d('name: ${nameController.text}');
                        logger.d('name: ${dateController.text}');
                        logger.d('name: ${locationController.text}');
                        logger.d('name: ${descriptionController.text}');
                        logger.d('Form submitted successfully!');
                        Event newEvent = Event(
                          title: nameController.text,
                          // date: dateController.text,
                          location: locationController.text,
                          description: descriptionController.text,
                          userId: myAppState.model.getUserId(),
                          startDate: startDate ?? DateTime.now(),
                          endDate: endDate ?? DateTime.now(),
                          email: myAppState.model
                              .getUserEmailAddress(myAppState.model.userId),
                        );
                        addEvent(newEvent);
                        alreadySubmitted = true;
                        setState(() {});
                      }
                    }),
                    // const SizedBox(height: 8),
                  ],
                ))));
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    Key? key,
    required this.onPressed,
    this.text = 'Submit',
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
