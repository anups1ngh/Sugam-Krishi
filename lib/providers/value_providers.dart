import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ValueProviders with ChangeNotifier {
  bool _showFAB = true;
  bool _showMarketplaceFAB = true;
  bool _showWeatherCard = true;

  bool get shouldShowFAB => _showFAB;
  bool get shouldShowMarketplaceFAB => _showMarketplaceFAB;
  bool get shouldShowWeatherCard => _showWeatherCard;

  void toggleShowFAB(){
    _showFAB = !_showFAB;
    // print("Show FAB : "+_showFAB.toString());
    notifyListeners();
  }
  void toggleShowMarketplaceFAB(){
    _showMarketplaceFAB = !_showMarketplaceFAB;
    notifyListeners();
  }
  void toggleShowWeatherCard(){
    _showWeatherCard = !_showWeatherCard;
    notifyListeners();
  }
}