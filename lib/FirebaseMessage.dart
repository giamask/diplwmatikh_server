import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:server_side/server_side.dart';
import 'package:http/http.dart' as http;

class FirebaseMessage {
  FirebaseMessage({this.body,this.topic,this.token});
  final String token;
  final String body;
  final String topic;
  


  Future<void> send() async {
    final String serviceJson =
        await File("map-testing-547d4-firebase-adminsdk-4wxk2-51868c54a8.json")
            .readAsString();
    final _credentials = ServiceAccountCredentials.fromJson(serviceJson);
    final client = http.Client();
    await obtainAccessCredentialsViaServiceAccount(_credentials,
            ["https://www.googleapis.com/auth/firebase.messaging"], client)
        .then((AccessCredentials credentials) async {
      final String message = 
      topic==null? 
      jsonEncode({  
            "message":{
                "data":{
                  "body":body,
                  "title":"Move"
                  },
                   "token": token,
              }
      }): 
      jsonEncode({  
            "message":{
                "data":{
                  "body":body,
                  "title":"Move"
                  },
                   "topic": topic,
              }
      });

      http.Response resp = await http.post(
          "https://fcm.googleapis.com/v1/projects/map-testing-547d4/messages:send",
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + credentials.accessToken.data
          },
          body: message);
      print(resp.body);
      client.close();
    });
    return Response.ok("confirm");
  }
}
