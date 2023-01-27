import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';
import 'package:flutter_uni_access/widgets/custom_bottom_outline_button.dart';
import 'package:flutter_uni_access/widgets/qr_image_widget.dart';
import 'package:provider/provider.dart';

class DisplayUserInfo extends StatelessWidget {
  // This method displays a popup
  // showing the qr code of the user
  Future<void> _showUserQrCode(
    BuildContext context,
    String? id,
  ) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertQrImageWidget(id: id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    final uniUser = Provider.of<UserProvider>(context, listen: false).user!;
    // With what number we will divide
    // the height of the screen
    int denominator;

    // If the user is a teacher
    // then the image can be bigger
    // since we don't need space for
    // the qr code button
    if (uniUser.isTeacher!) {
      denominator = 2;
    } else {
      denominator = 3;
    }

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      color: Theme.of(context).colorScheme.secondary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / denominator,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
                image: DecorationImage(
                  image: Image.memory(uniUser.image!).image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  uniUser.id!,
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name: ',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${uniUser.name.toString().capitalize()} ${uniUser.surname.toString().capitalize()}',
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'E-mail: ',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${uniUser.email}',
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Role: ',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  !uniUser.isTeacher! ? 'Student' : 'Teacher',
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              ],
            ),
            if (!uniUser.isTeacher!)
              Column(
                children: [
                  const Divider(
                    thickness: 3.0,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 15,
                  ),
                  CustomBottomOutlineButton(
                    hintMessage: 'Show QR code',
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 15,
                    onPressedMethod: () async =>
                        _showUserQrCode(context, uniUser.id),
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Show QR code',
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
