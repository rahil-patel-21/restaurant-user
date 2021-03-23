import 'package:shared_preferences/shared_preferences.dart';

void setPhoneChecked(phone) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Save String
  await prefs.setString('phone_checked', phone);
}

removePhone() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Remove String
  if ("phone_checked" != null) {
    prefs.remove("phone_checked");
  }

}