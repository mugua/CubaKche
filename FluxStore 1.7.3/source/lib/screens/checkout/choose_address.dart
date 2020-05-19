import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/address.dart';
import '../../models/cart/cart_model.dart';
import '../../models/user/user.dart';
import '../../services/index.dart';

class ChooseAddress extends StatefulWidget {
  final void Function(Address) callback;

  ChooseAddress(this.callback);

  @override
  _StateChooseAddress createState() => _StateChooseAddress();
}

class _StateChooseAddress extends State<ChooseAddress> {
  List<Address> listAddress = [];
  User user;

  @override
  void initState() {
    super.initState();
    getDatafromLocal();
    getUserInfor();
  }

  Future<void> getUserInfor() async {
    final LocalStorage storage = LocalStorage("fstore");
    final userJson = storage.getItem(kLocalKey["userInfo"]);
    if (userJson != null) {
      final User user = await Services().getUserInfo(userJson['cookie']);
      user.isSocial = userJson['isSocial'] ?? false;
      setState(() {
        this.user = user;
      });
    }
  }

  Future<void> getDatafromLocal() async {
    final LocalStorage storage = LocalStorage("address");
    List<Address> _list = [];
    try {
      final ready = await storage.ready;
      if (ready) {
        var data = storage.getItem('data');
        if (data != null) {
          (data as List).forEach((item) {
            final add = Address.fromLocalJson(item);
            _list.add(add);
          });
        }
      }
      setState(() {
        listAddress = _list;
      });
    } catch (err) {
      print(err);
    }
  }

  void removeData(int index) {
    final LocalStorage storage = LocalStorage("address");
    try {
      var data = storage.getItem('data');
      if (data != null) {
        (data as List).removeAt(index);
      }
      storage.setItem('data', data);
    } catch (err) {
      print(err);
    }
    getDatafromLocal();
  }

  Widget convertToCard(BuildContext context, Address address) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.streetName}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.street}")],
              ),
            )
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.city}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.city}")],
              ),
            )
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.stateProvince}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.state}")],
              ),
            )
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.country}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.country}")],
              ),
            )
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.zipCode}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.zipCode}")],
              ),
            )
          ],
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _renderBillingAddress() {
    if (user == null || user.billing == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        final add = Address(
            firstName: user.billing.firstName.isNotEmpty
                ? user.billing.firstName
                : user.firstName,
            lastName: user.billing.lastName.isNotEmpty
                ? user.billing.lastName
                : user.lastName,
            email:
                user.billing.email.isNotEmpty ? user.billing.email : user.email,
            street: user.billing.address1,
            country: user.billing.country,
            state: user.billing.state,
            phoneNumber: user.billing.phone,
            city: user.billing.city,
            zipCode: user.billing.postCode);
        Provider.of<CartModel>(context, listen: false).setAddress(add);
        Navigator.of(context).pop();
        widget.callback(add);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15),
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              S.of(context).billingAddress,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(user.billing.firstName + ' ' + user.billing.lastName),
            Text(user.billing.phone),
            Text(user.billing.email),
            Text(user.billing.address1),
            Text(user.billing.city),
            Text(user.billing.postCode)
          ],
        ),
      ),
    );
  }

  Widget _renderShippingAddress() {
    if (user == null || user.shipping == null) return Container();
    return GestureDetector(
      onTap: () {
        final add = Address(
            firstName: user.shipping.firstName.isNotEmpty
                ? user.shipping.firstName
                : user.firstName,
            lastName: user.shipping.lastName.isNotEmpty
                ? user.shipping.lastName
                : user.lastName,
            email: user.email,
            street: user.shipping.address1,
            country: user.shipping.country,
            state: user.shipping.state,
            city: user.shipping.city,
            zipCode: user.shipping.postCode);
        Provider.of<CartModel>(context, listen: false).setAddress(add);
        Navigator.of(context).pop();
        widget.callback(add);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15),
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              S.of(context).shippingAddress,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(user.shipping.firstName + ' ' + user.shipping.lastName),
            Text(user.shipping.address1),
            Text(user.shipping.city),
            Text(user.shipping.postCode)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          S.of(context).selectAddress,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _renderBillingAddress(),
            _renderShippingAddress(),
            Column(
              children: [
                if (listAddress.isEmpty)
                  Image.asset(
                    kEmptySearch,
                    width: 120,
                    height: 120,
                  ),
                ...List.generate(listAddress.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<CartModel>(context, listen: false)
                              .setAddress(listAddress[index]);
                          Navigator.of(context).pop();
                          widget.callback(listAddress[index]);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  child: Icon(
                                    Icons.home,
                                    color: Theme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: convertToCard(
                                      context, listAddress[index]),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    removeData(index);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
