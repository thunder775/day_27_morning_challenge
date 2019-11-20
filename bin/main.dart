// Challenge 1
// Flutter module makes multiple, parallel, requests to a web service, and
// shares the result with the host app. We'll use the "balldontlie" API for this
// purpose, since it's open and supports cross-domain requests for web apps. in
// this case, the input value represents the number of calls to be made, eg a
// value of 3 means we will fetch data for players 1, 2, 3. The URL for player 2,
// for example, is:
// https://www.balldontlie.io/api/v1/players/1
// Once all calls have been made, the Flutter module should calculate average
// weight of all queried players and print it in console.
//  The calls must occur in parallel, always using up to *four* separate threads,
// in a typical "worker" pattern, to ensure there are always three pending requests
// until no further requests are needed. The requests should be logged when initiated
// and again when completed.

// Challenge 2
// A point on the screen (pt1) wants to move a certain distance (dist) closer to
// another point on the screen (pt2) The function has three arguments,
// two of which are objects with x & y values, and the third being the distance,
// e.g. {x:50, y:60}, {x: 100, y: 100}, 10. The expected result is a similar
// object with the new co-ordinate.
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:executor/executor.dart';
import 'package:http/http.dart';

List distance(Map point1, Map point2, int move1) {
  double dis = pow(point1['x'] - point2['x'], 2).toDouble();
  double dist = pow(point1['y'] - point2['y'], 2).toDouble();
  double distance = sqrt(dis + dist);
  print(distance);
  double move2 = distance - move1;
  print(move2);
  print((point1['x'] * move2) + (point2['x'] * move1));
  double x = ((point1['x'] * move2) + (point2['x'] * move1)) / (move1 + move2);
  double y = ((point1['y'] * move2) + (point2['y'] * move1)) / (move1 + move2);
  return [x, y];
}

Future averageWeight(int n)async {
  List weights = [];
  Executor executor = Executor(
    concurrency: 4,
  );

  for (int i = 0; i < n; i++) {
    executor.scheduleTask(() async {
      var x = await getWeight(i);
     if(x!=null){
       weights.add(x);
     };
    });
  }
await executor.join(withWaiting: true);
  return weights.reduce((a,b)=>a+b)/weights.length;
}

Future getWeight(int i) async {
  print('request ${i + 1} made');
  Response response =
      await get('https://www.balldontlie.io/api/v1/players/${i + 1}');
  Map map = jsonDecode(response.body);
  print('request ${i + 1} completed and weight is ${map['weight_pounds']}');

  return map['weight_pounds'];
}

main() async {
  print(distance({'x': 50, 'y': 60}, {'x': 100, 'y': 100}, 10));

//  var x = await getWeight(1);
//  sleep(Duration(seconds: 3));
//  print(x);
  dynamic x = await averageWeight(5);
  print(x);
}
