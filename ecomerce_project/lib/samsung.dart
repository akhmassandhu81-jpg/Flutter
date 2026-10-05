import 'package:flutter/material.dart';

class samsung extends StatefulWidget {
  const samsung({super.key});

  @override
  State<samsung> createState() => _samsungState();
}

class _samsungState extends State<samsung> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage("https://images.samsung.com/pk/smartphones/galaxy-s24-ultra/images/galaxy-s24-ultra-highlights-color-titanium-black-back-mo.jpg?imbypass=true"),fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("New item Smartphone",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(width: 250,),
                  Text("In Stock",style: TextStyle(color: Colors.green),),
                ],
              ),
              SizedBox(height: 5,),
              Text("\$534",style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text(" Iphone 13 pro max",style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              Row(
                children: [
                  Container(
                    decoration:BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(onPressed: (){}, icon: Icon(Icons.favorite,color: Colors.white,)),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(onPressed: (){}, child: Text("Add to cart"),
                    style: ElevatedButton.styleFrom(
                        elevation: 10,
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 150,vertical: 20)
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Text("Reviews",style: TextStyle(fontSize: 17),),
              SizedBox(height: 20,),
              Row(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
