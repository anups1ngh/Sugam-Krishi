import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'keys.dart';
import 'screens/Utilities/UtilitiesPage.dart';
import 'package:http/http.dart' as http;

class AllDataFetchHandler{
  static YoutubeAPI youtube = YoutubeAPI(YT_API_KEY, maxResults: 5);
  static List<YouTubeVideo> videoResult = [];
  static List<Scheme> schemes = [];

  static Future<void> fetchAllData() async{
    fetchUtilsData();
    fetchCommunityData();
    fetchMarketPlaceData();
  }

  static Future<void> fetchUtilsData() async{
    callYTAPI("Modern Farming Techniques");
    callSchemesAPI();
  }
  static Future<void> fetchCommunityData() async{

  }
  static Future<void> fetchMarketPlaceData() async{

  }


  static Future<void> callSchemesAPI() async {
    var res = await http.get(Uri.parse(schemesURL));
    List<dynamic> schemesMap = json.decode(res.body);
    schemesMap.forEach(
          (scheme) {
        schemes.add(new Scheme.fromJson(scheme));
      },
    );
  }
  static Future<void> callYTAPI(String query) async {
    videoResult = await youtube.search(
      query,
      order: 'relevance',
      videoDuration: 'any',
    );
    videoResult = await youtube.nextPage();
  }
}