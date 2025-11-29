List<Map<String, dynamic>> users = [
  {
    'email': 'ibrashawqy98@gmail.com',
    'password': '123456',
    'name': 'Shawqy',
    'male': true,
  },
  {
    'email': 'dragon.rider@gmail.com',
    'password': '123456',
    'name': 'DragonRider',
    'male': true,
  },
  {'email': 'girl', 'password': '123456', 'name': 'Mariam', 'male': false},
];

bool isMale = true;
String token = "";
const String myServer = "192.168.1.108:8080";
String baseURL = "http://$myServer";
String myWebSocketServer = "ws://$myServer/ws/app";
String mySchedule = '$baseURL/api/schedule';
///////
String login_route = "/auth/login";
String profile_route = "/me/overview";
String room_route_create = "/rooms";
String room_route_update = "/rooms/";
