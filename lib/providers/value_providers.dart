import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ValueProviders with ChangeNotifier {
  bool _showFAB = true;
  bool _showMarketplaceFAB = true;
  bool _showWeatherCard = true;

  bool get shouldShowFAB => _showFAB;
  bool get shouldShowMarketplaceFAB => _showMarketplaceFAB;
  bool get shouldShowWeatherCard => _showWeatherCard;

  void setShowFAB(bool state){
    _showFAB = state;
    // print("Show FAB : "+_showFAB.toString());
    notifyListeners();
  }
  void setShowMarketplaceFAB(bool state){
    _showMarketplaceFAB = state;
    notifyListeners();
  }
  void setShowWeatherCard(bool state){
    _showWeatherCard = state;
    notifyListeners();
  }
}