import 'package:flutter/material.dart';
import 'package:market_salla/models/products_model.dart';

class Sallastate with ChangeNotifier {
  List salla = [];
  List favorite = [];
  addtolist(Products product) {
    salla.add(product);
    notifyListeners();
  }

  removeindex(Products product) {
    salla.remove(product);
    notifyListeners();
  }

  totalpayment() {
    int total = 0;
    for (int i = 0; i < salla.length; i++) {
      total += int.parse((salla[i].price).toString().substring(1));
    }
    return total;
  }

  addfavouite(Products product) {
    favorite.add(product);
    notifyListeners();
  }

  unfavorite(Products product) {
    favorite.remove(product);
    notifyListeners();
  }
}
