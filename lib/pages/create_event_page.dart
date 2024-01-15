import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import '../db/events.dart';
import '../widgets/date_time_picker_in_page.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  final nameController = TextEditingController(text: 'type name here');
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.now(); // Initialize with current date
    DateTime endDate = DateTime.now(); // Initialize with current date

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Event'),
        ),
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
                    const SizedBox(height: 8),
                    ElevatedButton(
                      //color: Colors.blue,
                      child: const Text("Start Date and Time"),
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const DateTimePickerInPage(
                              title: 'Enter start date and time',
                              isStartDate: true);
                        }));
                      },
                    ),
                    ElevatedButton(
                      //color: Colors.blue,
                      child: const Text("End Date and Time"),
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const DateTimePickerInPage(
                              title: 'Enter end date and time',
                              isStartDate: false);
                        }));
                      },
                    ),
                    // TextFormField(
                    //   decoration: const InputDecoration(
                    //     labelText: 'Date',
                    //   ),
                    //   controller: dateController,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter a date';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 5,
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SubmitButton(onPressed: () {
                      if (_formKey.currentState!.validate()) {
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
                          startDate: myAppState.startDate,
                          endDate: myAppState.endDate,
                        );
                        addEvent(newEvent);
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
