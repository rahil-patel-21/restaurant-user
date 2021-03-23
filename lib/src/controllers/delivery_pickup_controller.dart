import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class DeliveryPickupController extends CartController {
  GlobalKey<ScaffoldState> scaffoldKey;
  // model.Address deliveryAddress;
  List<model.Address> deliveryAddress = <model.Address>[];
  PaymentMethodList list;

  DeliveryPickupController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    super.listenForCarts();
    listenForDeliveryAddress();
    print(settingRepo.deliveryAddress.value.toMap());
  }

  // void listenForDeliveryAddress() async {
  //   this.deliveryAddress = settingRepo.deliveryAddress.value;
  //   print(this.deliveryAddress.id);
  // }

    void listenForDeliveryAddress({String message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
      setState(() {
        deliveryAddress.add(_address);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void addAddress(model.Address address) {
    userRepo.addAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        // this.deliveryAddress = value;
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).new_address_added_successfully),
      ));
    });
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        // this.deliveryAddress = value;
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_address_updated_successfully),
      ));
    });
  }

  PaymentMethod getPickUpMethod() {
    return list.pickupList.elementAt(0);
  }

  PaymentMethod getDeliveryMethod() {
    return list.pickupList.elementAt(1);
  }

  void toggleDelivery(addresses, index) {
    for (var i = 0; i < addresses.length; i++) {
      addresses[i].isDefault = false;
    }
    addresses[index].isDefault = !addresses[index].isDefault;

    list.pickupList.forEach((element) {
      if (element != getDeliveryMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getDeliveryMethod().selected = true;
    });
  }

  void togglePickUp() {
    list.pickupList.forEach((element) {
      if (element != getPickUpMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getPickUpMethod().selected = !getPickUpMethod().selected;
    });
  }

  PaymentMethod getSelectedMethod() {
    return list.pickupList.firstWhere((element) => element.selected);
  }

  @override
  validCheckout(context, allowCheckout, orderLimitPass) {
    if (!allowCheckout && orderLimitPass) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Please select delivery option'),
      ));
    } else if (!allowCheckout) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Minimum order is php350'),
      ));
    } else {
      goCheckout(context);
    }
  }


  @override
  void goCheckout(BuildContext context) {
    Navigator.of(context).pushNamed(getSelectedMethod().route);
  }
    reflect(con) {}
}
