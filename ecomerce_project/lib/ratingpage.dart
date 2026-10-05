import 'package:flutter/material.dart';

class ratingpage extends StatefulWidget {
  const ratingpage({super.key});

  @override
  State<ratingpage> createState() => _ratingpageState();
}

class _ratingpageState extends State<ratingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: Colors.grey[200], // Light background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg"),
                radius: 24, // Slightly larger avatar
              ),
              title: Text(
                "Lorem Ipsum Sit Amet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
              onTap: () {
                // Handle tap action
              },
            ),
            SizedBox(height: 20,),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: Colors.grey[200], // Light background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg"),
                radius: 24, // Slightly larger avatar
              ),
              title: Text(
                "Lorem Ipsum Sit Amet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
              onTap: () {
                // Handle tap action
              },
            ),
            SizedBox(height: 20,),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: Colors.grey[200], // Light background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg"),
                radius: 24, // Slightly larger avatar
              ),
              title: Text(
                "Lorem Ipsum Sit Amet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
              onTap: () {
                // Handle tap action
              },
            ),
            SizedBox(height: 20,),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: Colors.grey[200], // Light background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg"),
                radius: 24, // Slightly larger avatar
              ),
              title: Text(
                "Lorem Ipsum Sit Amet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
              onTap: () {
                // Handle tap action
              },
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt_rounded),
                  ),
                  SizedBox(width: 10,),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
        
                  ),
                  SizedBox(width: 10,),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
        
                  ),
                  SizedBox(width: 10,),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
        
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
