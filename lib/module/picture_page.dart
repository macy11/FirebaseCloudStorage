import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key});

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  String imageUrl = '';
  bool startLoad = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Image'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        startLoad = true;
                      });
                      var refFromURL = FirebaseStorage.instance.refFromURL(
                          'https://firebasestorage.googleapis.com/v0/b/cloudstoragedemo-a7555.appspot.com/o/Images%2Fabc.webp?alt=media&token=205181d0-ed2c-45a5-890c-13466c2f6bc8');
                      imageUrl = await refFromURL.getDownloadURL();
                      print('macy777---imageUrl--1--> $imageUrl');
                    } catch (e) {
                      print('macy777---imageUrl--1-exception-> $e');
                    } finally {
                      setState(() {
                        startLoad = false;
                      });
                    }
                  },
                  child: const Text('加载图片1'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        startLoad = true;
                      });
                      var refFromURL = FirebaseStorage.instance
                          .refFromURL('gs://cloudstoragedemo-a7555.appspot.com/Images/fengjing.webp');
                      imageUrl = await refFromURL.getDownloadURL();
                      print('macy777---imageUrl--2--> $imageUrl');
                    } catch (e) {
                      print('macy777---imageUrl--2-exception-> $e');
                    } finally {
                      setState(() {
                        startLoad = false;
                      });
                    }
                  },
                  child: const Text('加载图片2'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        startLoad = true;
                      });
                      var refFromURL = FirebaseStorage.instance.ref('Images/hehua.webp');
                      imageUrl = await refFromURL.getDownloadURL();
                      print('macy777---imageUrl--3--> $imageUrl');
                    } catch (e) {
                      print('macy777---imageUrl--3-exception-> $imageUrl');
                    } finally {
                      setState(() {
                        startLoad = false;
                      });
                    }
                  },
                  child: const Text('加载图片3'),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: startLoad
                    ? const CircularProgressIndicator()
                    : imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            // placeholder: (BuildContext context, String url) {
                            //   return const CircularProgressIndicator(
                            //   );
                            // },
                            progressIndicatorBuilder: (BuildContext context, String url, DownloadProgress progress) {
                              return const CircularProgressIndicator();
                            },
                            errorWidget: (BuildContext context, String url, dynamic error) {
                              return const Text('加载失败');
                            },
                          )
                        : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
