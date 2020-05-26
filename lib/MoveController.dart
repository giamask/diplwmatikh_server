

import 'package:aqueduct/aqueduct.dart';
import 'package:mysql1/mysql1.dart';
import 'package:server_side/server_side.dart';


import 'VersionProcessing.dart';

class MoveController extends ResourceController {
  
  MoveController(this.conn);

  final MySqlConnection conn;


//Request handling
  @Operation.get()
  Future<Response> registerMove({@Bind.query('objectId') int objectId, @Bind.query('keyId') int keyId, @Bind.query('userId') String userId, @Bind.query('sessionId') int sessionId, @Bind.query('type') String type}) async {
    if (objectId==null || keyId==null || userId ==null || sessionId==null || type==null) 
      return Response.badRequest();
    final List<dynamic> props = [sessionId,type,objectId,keyId,userId];

    try{
      await conn.query("INSERT INTO move VALUES(null,?,?,?,?,?,default)",[sessionId,type,objectId,keyId,userId]);
      await versionSpecificProcessing(props);
      return Response.ok({"outcome":"valid move"})..contentType=ContentType.json;
    }
    on MySqlException catch (e){
  
      return Response.ok({"outcome":"invalid move"})..contentType=ContentType.json;
    }
  }

//Router to code that differs from version to version
  Future<void> versionSpecificProcessing(List props) async{
    final Results results = await conn.query("SELECT game_version FROM session WHERE id= ?",[props[0]]);
    if (results.isEmpty) 
      return Response.notFound();
    final int currentVersion = results.elementAt(0)[0] as int;
    VersionProcessing versionProcessing ;
    switch(currentVersion){
      case 1:{
        versionProcessing = BaseVersion(props,conn);
      }
      break;
      case 2:{
        versionProcessing = VersionProcessing(props,conn);
      }
      break;
    }
    versionProcessing.execute();
  }
}

//Request example:
//http://hci.ece.upatras.gr:8888/move?objectId=1&keyId=6&userId=1&sessionId=1&type=match