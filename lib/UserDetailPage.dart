import 'package:flutter/cupertino.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:
      Text('UserDetailPage'),
    );
  }
}