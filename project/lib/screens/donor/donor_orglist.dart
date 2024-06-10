// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:project/providers/user_provider.dart';
// import 'package:provider/provider.dart';
// import '../../models/user_model.dart';
// import '../constants.dart';
// import 'donor_detailspage.dart';

// class DonorOrgsList extends StatefulWidget {
//   const DonorOrgsList({super.key});
//   @override
//   State<DonorOrgsList> createState() => _DonorOrgsListState();
// }

// class _DonorOrgsListState extends State<DonorOrgsList> {
//   final _formKey = GlobalKey<FormState>();
//   @override
//   //creating for donors homepage
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           // searchBar(context),
//           orgTitle(context),
//           Expanded(
//             child: createOrgList(context),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget createOrgList(BuildContext context) {
//   // Retrieve the friend list provider without listening for changes
//   // final friendListProvider = Provider.of<FriendListProvider>(context, listen: false);
//   Stream<QuerySnapshot> orgStream =
//       context.watch<UsersProvider>().organizations;

//   return StreamBuilder<QuerySnapshot>(
//     stream: orgStream,
//     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//       if (snapshot.hasError) {
//         return Center(
//           child: Text("Error encountered! ${snapshot.error}"),
//         );
//       }
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(
//           child: CircularProgressIndicator(),
//           // ignore: avoid_print
//         );
//       }
//       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//         // Check if snapshot has no data or if docs is empty
//         return const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text('No available organizations.',
//                 style: TextStyle(fontSize: 20, color: Colors.pink)),
//             // Text (snapshot.data!.docs.toString()),
//           ],
//         );
//       } else {
//         // If snapshot has data and docs is not empty
//         return ListView.builder(
//           itemCount: snapshot.data?.docs.length,
//           physics: const BouncingScrollPhysics(),
//           itemBuilder: ((context, index) {
//             UserModel organization = UserModel.fromJson(
//                 (snapshot.data as QuerySnapshot).docs[index].data()
//                     as Map<String, dynamic>);
//             organization.id = (snapshot.data as QuerySnapshot).docs[index].id;
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               key: Key(organization.id.toString()),
//               child: ListTile(
//                   leading: const Icon(
//                       Icons.groups_rounded,
//                       color: Colors.black54,
//                       size: 50,
//                   ),
//                   title: Text(
//                       organization.organizationName ?? 'No organization name',
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                       ),
//                   ),
//                   subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                           Text(
//                               organization.name ?? 'No organization name',
//                               style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                           ),
//                           Text(
//                               organization.isOpen == true ? 'Open' : 'Closed',
//                               style: TextStyle(
//                                   color: organization.isOpen == true ? Colors.green[800] : Colors.red,
//                                   fontWeight: FontWeight.bold,
//                               ),
//                           ),
//                       ],
//                   ),
//                   tileColor: Constants.primaryColor.withOpacity(0.6),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                   ),
//                   onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => DonorDetails(),
//                               settings: RouteSettings(
//                                   name: '/donor_donate',
//                                   arguments: organization,
//                               ),
//                           ),
//                       );
//                   },
//               ));
//           }),
//         );
//       }
//     },
//   );
// }

// Widget orgTitle(BuildContext context) {
//   return Container(
//     padding: const EdgeInsets.only(left: 16, bottom: 0, top: 20),
//     child: const Text(
//       'Organizations',
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         fontSize: 15.0,
//       ),
//     ),
//   );
// }

// Widget searchBar(BuildContext context) {
//   //get screen size
//   Size size = MediaQuery.of(context).size;
//   return Container(
//     padding: const EdgeInsets.only(top: 20),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           width: size.width * .9,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.search,
//                 color: Colors.black54.withOpacity(.6),
//               ),
//               const Expanded(
//                   child: TextField(
//                 showCursor: false,
//                 decoration: InputDecoration(
//                   hintText: 'Search Organization',
//                   border: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//                 ),
//               )),
//             ],
//           ),
//           decoration: BoxDecoration(
//             color: Constants.blackColor.withOpacity(.1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//         )
//       ],
//     ),
//   );
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../constants.dart';
import 'donor_detailspage.dart';
import 'package:project/providers/user_provider.dart';

class DonorOrgsList extends StatefulWidget {
  const DonorOrgsList({super.key});

  @override
  State<DonorOrgsList> createState() => _DonorOrgsListState();
}

class _DonorOrgsListState extends State<DonorOrgsList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          orgTitle(context),
          Expanded(
            child: createOrgList(context),
          ),
        ],
      ),
    );
  }
}

Widget createOrgList(BuildContext context) {
  Stream<QuerySnapshot> orgStream = context.watch<UsersProvider>().organizations;

  return StreamBuilder<QuerySnapshot>(
    stream: orgStream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Error encountered! ${snapshot.error}"),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text(
            'No available organizations.',
            style: TextStyle(fontSize: 20, color: Colors.pink),
          ),
        );
      } else {
        // Get screen size
        var size = MediaQuery.of(context).size;
        var itemWidth = (size.width / 2) - 20;
        var itemHeight = itemWidth * 1.25;

        return GridView.builder(
          itemCount: snapshot.data?.docs.length,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemBuilder: (context, index) {
            UserModel organization = UserModel.fromJson(
                (snapshot.data as QuerySnapshot).docs[index].data()
                    as Map<String, dynamic>);
            organization.id = (snapshot.data as QuerySnapshot).docs[index].id;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonorDetails(),
                    settings: RouteSettings(
                      name: '/donor_donate',
                      arguments: organization,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFB0D9B1),
                      blurRadius: 15,
                      offset: Offset(10, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        child: organization.profilePicture == null || organization.profilePicture!.isEmpty
                            ? Image.asset(
                                'images/login_logo.png',
                                height: itemHeight * 0.4,
                                width: itemWidth * 0.8,
                                fit: BoxFit.fill,
                              )
                            : Image.network(
                                organization.profilePicture!,
                                height: itemHeight * 0.4,
                                width: itemWidth * 0.8,
                              ),
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            organization.organizationName ?? 'No organization name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            organization.name ?? 'No organization name',
                            style: TextStyle(color: Colors.black.withOpacity(0.7)),
                          ),
                          Text(
                            organization.isOpen! ? 'Open' : 'Closed',
                            style: TextStyle(
                              color: organization.isOpen! ? Colors.green[800] : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    },
  );
}

Widget orgTitle(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(left: 16, bottom: 0, top: 20),
    child: const Text(
      'Organizations',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
      ),
    ),
  );
}
