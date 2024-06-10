Readme: 
# Group Details
CMSC 23 UV1L
Members:

  CHAMBAL, VIVEKJEET SINGH (vchambal@up.edu.ph)
  
  PANGA, ERIC CONRAD III VALDEZ (evpanga2@up.edu.ph)
  
  QUEJADA, ROCHE FAUSTINO (rfquejada@up.edu.ph)
  
  TANIG, STEPHANIE VILLANUEVA (svtanig@up.edu.ph)

# Program Description 
Elbiyaya is a mobile application designed to facilitate donations from donors to various organizations. The app aims to provide a simple and secure platform for donors to make contributions of food, clothing, money, and other items, and for organizations to manage and receive these donations.

# Installation Guide
1. Clone the repository:
```sh
git clone https://github.com/ICS-CMSC-23/project-Vivekjeet.git
```
2. Navigate to the project directory:
```sh
cd project
```
3. Retrieve all the dependencies:
```sh
flutter pub get
```
4. Build the app APK:
```sh
flutter build apk
```
5. Install the app on your mobile device and run it.

# How to Use
There are three different accounts: donor, organization, and admin. The admin account is already added manually to the database for security purposes and oversees all the aspects of the app. The admin is mainly responsible for approving or disapproving organizations.

Users who wish to use the app may sign in as donors or organizations. Donors may place their donations for one or more of the list of available organizations provided. The weight of these donations (in kg or lbs) must already be measured because it will be required as part of the information required to submit a donation. Furthermore, donations may be separated into different categories, namely food, clothes, cash, necessities, and others. Donations can be scheduled to be picked up or dropped off. In the case that the donations will be picked up, one or more addresses must be provided along with the contact number. Photos of the donations may also be optionally provided. In the case that the donations will be dropped off, the donor must generate a QR code that must be scanned by the organization to update the donation status. Donation status can be pending, confirmed, scheduled (for pickup), complete, or canceled. 

Organizations are responsible for updating the status of donations. They also categorize the donations, deciding which is the most appropriate donation drive for the given donation. Organizations can customize their donation drives, having add, update, and delete functionalities. To ensure proper documentation and notification, organizations save photos of where the donations ended up and also send an auto-sms to the donor that their donation has reached its destination.

Both donors and organizations have customizable profiles.
