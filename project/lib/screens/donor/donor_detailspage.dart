import 'package:flutter/material.dart';
import 'package:project/screens/constants.dart';
import 'package:project/models/user_model.dart';

class DonorDetails extends StatefulWidget {
  const DonorDetails({super.key});
  @override
  _DonorDetailsState createState() => _DonorDetailsState();
}

class _DonorDetailsState extends State<DonorDetails> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserModel? selectedOrganization = ModalRoute.of(context)!.settings.arguments as UserModel?;

    return Scaffold(
      body: Center(
      child: Stack(alignment: Alignment.center, children: [
        //x button
        Positioned(
          top: size.height * 0.07,
          left: size.width * 0.05,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Constants.primaryColor.withOpacity(.15),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              color: Constants.primaryColor,
            ),
          ),
        ),
        //Organization Photo
        Positioned(
          top: size.height * 0.15,
          child: Container(
            height: size.height * 0.35,
            width: size.width * 0.90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              // color: Constants.primaryColor.withOpacity(.60),
            ),
            child: const Icon(
              Icons.groups_rounded,
              size: 300,
              color: Colors.black54,
            ),
          ),
        ),
        //Organization Details
        Positioned(
          top: size.height * 0.45,
          child: Container(
              height: size.height * 0.60,
              width: size.width,
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Constants.primaryColor.withOpacity(0.60),
              ),
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedOrganization!.organizationName ?? 'No organization name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: size.height * 0.30,
                      child: Text(
                        selectedOrganization.description ?? 'No organization description.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Constants.blackColor.withOpacity(.6),
                        ),
                      ),
                    ),
                    //Donate Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/donor_donate', arguments: selectedOrganization);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 70),
                        height: size.height * 0.07,
                        decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: Constants.primaryColor.withOpacity(.3),
                              )
                            ]),
                        child: const Center(
                          child: Text(
                            'Donate Now!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ]),
    ));
  }
}
