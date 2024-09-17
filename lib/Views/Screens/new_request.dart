import 'package:flutter/material.dart';


class NewRequest extends StatefulWidget {
  const NewRequest({super.key});

  @override
  State<NewRequest> createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  
  
  @override
  Widget build(BuildContext context) {
     final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return  Scaffold(
        backgroundColor: const Color.fromRGBO(244, 252, 255, 1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black), // Ensure the drawer icon is visible
          title: const Text("Reply complaint R- 11123",style: TextStyle(fontWeight: FontWeight.w500),),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 3.0)]),
              height: 0.8,
            ),
          ),
        ),
        drawer: const Drawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: screenWidth*0.9,
                      height: screenHeight*0.2,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.white),
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Request By :",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                          const SizedBox(height: 20,),
                          Row(
                            children: [
                              const Text("R-001111",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                              const SizedBox(width: 5,),
                              Container(
                                height: 26,
                                width: 80,
                                decoration: BoxDecoration(border: Border.all(color: Colors.green),borderRadius: BorderRadius.circular(5)),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text("In Progress",style: TextStyle(color: Colors.green),),
                                ),
                    
                              ),
                              const SizedBox(width: 55,),
                              const Text("July 15 2024 , 12.00 AM",style: TextStyle(fontSize: 10,color: Colors.black54),)
                            ],
                          ),
                          const SizedBox(height: 10,),
                          const Row(children: [
                            Text("Raised by:",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 5,),
                            Text("Alwin",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                            const Text("Department:",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            const SizedBox(width: 5,),
                            const Text("PWD",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                            const SizedBox(width: 180,),
                            Container(
                                height: 23,
                                width: 43,
                              
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.amber),
                                child: const Center(child: Text("High",style: TextStyle(color: Colors.white),)),
                    
                              ),
                          ],)
                        ],
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Container(
                        width: screenWidth*0.9,
                      height: screenHeight*0.43,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Grievance Details",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                          const SizedBox(height: 20,),
                          const Row(children: [
                            Text("Origin :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 70,),
                            Text("Telephone Call",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Contact Number :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 11,),
                            Text("+91 00000 00000",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Address :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 57,),
                            Text("Trichy",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Pin Code :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 54,),
                            Text("600 003",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Zone :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 76,),
                            Text("Zone",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Ward :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 76,),
                            Text("Ward",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Area :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 79,),
                            Text("Area",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Request :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 59,),
                            Text("Fire Accident",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           const Row(children: [
                            Text("Department :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            SizedBox(width: 38,),
                            Text("PWD",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)
                          ],),
                          const SizedBox(height: 10,),
                           Row(children: [
                            const Text("Attachments :",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),),
                            const SizedBox(width: 30,),
                            const Icon(Icons.picture_as_pdf_outlined,color: Colors.red,),
                             const SizedBox(width: 2,),
                            const Text("1.3MB",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                            const SizedBox(width: 2,),
                            InkWell(onTap: (){},child: const Icon(Icons.file_download_outlined),)
                          ],),
                        ],
                      ),
                    ),
                      const SizedBox(height: 15,),
                       Container(
                        width: screenWidth*0.9,
                        height: screenHeight*0.3,
                        color: Colors.white,
                       //  padding: const EdgeInsets.all(16.0),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             const Padding(
                               padding: EdgeInsets.all(16.0),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Text(
                                     'Similar request',
                                     style: TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                   Icon(Icons.search, color: Colors.blue),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 10,),
                             for (int i = 0; i < 4; i++) ...[
                         SimilarRequestItem(isLastItem: i == 3),
                       ],
                           ],
                         ),
                       )
                    
                  ],
                ),
              ),

              const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: const BoxDecoration(color: Color.fromRGBO(244, 252, 255, 1),boxShadow: [BoxShadow(color: Colors.grey)]),
                  child:  Row(
                    children: [
                      const SizedBox(width: 30,),
                      const Text("Complaint History :",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black)),
                      const SizedBox(width: 3,),
                      const Text("#564258",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black54)),
                      const SizedBox(width: 140,),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_down))
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  color: Colors.white,
                  child:  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                                children: [
                                  IconButton(onPressed: (){}, icon: const Icon(Icons.image)),
                                  const SizedBox(width: 8.0),
                                  const Expanded(
                                    child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type...',
                      border: InputBorder.none,
                    ),
                                    ),
                                  ),
                                  IconButton(onPressed: (){}, icon: const Icon(Icons.language, color: Colors.grey),),
                                  const SizedBox(width: 8.0),
                                  IconButton(onPressed: (){}, icon:  const Icon(Icons.send, color: Colors.blue),),
                                 
                                ],
                              ),
                  ),
                ),
                
            ],
          ),

        ),
        );
  }
}
class SimilarRequestItem extends StatelessWidget {
  final bool isLastItem;

  const SimilarRequestItem({super.key, required this.isLastItem});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:  BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100,width: 1),
            ),
            borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
               
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child:  Row(
              children: [
                const Text(
                  'R-001111',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5,),
                Container(
                  height: 23,
                  width: 72,
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'InProgress',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold,fontSize: 10,)
                  ),
                ),
                const Expanded(
                  child: Text(
                    'July 15 2024, 12:00 AM',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          
        ),
      ),
    );
  }
}

