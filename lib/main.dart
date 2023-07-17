import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googlecloudstoragedemo/bucket_list_page.dart';
import 'package:googlecloudstoragedemo/firebase_options.dart';
import 'package:googlecloudstoragedemo/login_page.dart';
import 'package:googlecloudstoragedemo/picture_page.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'GoogleCloudStorageDemo',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Cloud Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showUploadProgress = false;
  double uploadProgressValue = 0.0;
  UploadTask? myUploadTask;

  bool showDownloadProgress = false;
  double downloadProgressValue = 0.0;
  DownloadTask? myDownloadTask;

  bool showLoadingCircle = false;
  String currentMetadata = '';

  bool showDeleteLoading = false;
  bool deleteFail = false;
  String deleteException = '';

  bool showBucketListLoading = false;
  String bucketListString = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text('\n------------上传------------\n'),
                showUploadProgress
                    ? Column(
                        children: [
                          LinearProgressIndicator(
                            minHeight: 10,
                            backgroundColor: Colors.blue,
                            value: uploadProgressValue,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                          ),
                          Text('${(uploadProgressValue * 100).toInt()}%'),
                        ],
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Directory? appFilesDir = await getExternalStorageDirectory();
                        print('macy777 --appFilesDir-> ${appFilesDir?.absolute.path}');
                        String filePath = '${appFilesDir?.absolute.path}/test3.webp';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          final storageRef = FirebaseStorage.instance.ref('Images');
                          final imagesRef = storageRef.child('abc.webp');
                          myUploadTask = imagesRef.putFile(file);
                          uploadFile(myUploadTask);
                        } else {
                          Fluttertoast.showToast(
                              msg: "上传的文件不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {
                            uploadProgressValue = 0.0;
                            showUploadProgress = false;
                          });
                        }
                      },
                      child: const Text('上传图片'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Directory? appFilesDir = await getExternalStorageDirectory();
                        String filePath = '${appFilesDir?.absolute.path}/video.mp4';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          final storageRef = FirebaseStorage.instance.ref('Videos');
                          final videosRef = storageRef.child('video.mp4');
                          myUploadTask = videosRef.putFile(file);
                          uploadFile(myUploadTask);
                        } else {
                          Fluttertoast.showToast(
                              msg: "上传的文件不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {
                            uploadProgressValue = 0.0;
                            showUploadProgress = false;
                          });
                        }
                      },
                      child: const Text('上传视频'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Directory? appFilesDir = await getExternalStorageDirectory();
                        String filePath = '${appFilesDir?.absolute.path}/pdf_test.pdf';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          final storageRef = FirebaseStorage.instance.ref('Docs');
                          final docsRef = storageRef.child('abc.pdf');
                          myUploadTask = docsRef.putFile(file);
                          uploadFile(myUploadTask);
                        } else {
                          Fluttertoast.showToast(
                              msg: "上传的文件不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {
                            uploadProgressValue = 0.0;
                            showUploadProgress = false;
                          });
                        }
                      },
                      child: const Text('上传文档'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          uploadProgressValue = 0.0;
                          showUploadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final textRef = storageRef.child('text');

                        String dataUrl = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==';
                        myUploadTask = textRef.putString(dataUrl, format: PutStringFormat.dataUrl);
                        uploadFile(myUploadTask);
                      },
                      child: const Text('上传字符串'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Directory? appDocDir = await getExternalStorageDirectory();
                        String filePath = '${appDocDir?.absolute.path}/test1.jpg';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          setState(() {
                            uploadProgressValue = 0.0;
                            showUploadProgress = true;
                          });
                          final storageRef = FirebaseStorage.instance.ref('Images');
                          final imagesRef = storageRef.child('originData');
                          myUploadTask = imagesRef.putData(file.readAsBytesSync());
                          uploadFile(myUploadTask);
                        } else {
                          Fluttertoast.showToast(
                              msg: "上传的文件不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {
                            uploadProgressValue = 0.0;
                            showUploadProgress = false;
                          });
                        }
                      },
                      child: const Text('上传原始数据'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Pause the upload.
                        bool? paused = await myUploadTask?.pause();
                        print('macy777 ----paused, $paused');
                      },
                      child: const Text('暂停上传'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool? resumed = await myUploadTask?.resume();
                        print('macy777 ----resumed, $resumed');
                      },
                      child: const Text('恢复上传'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool? canceled = await myUploadTask?.cancel();
                        print('macy777 ----canceled, $canceled');
                        setState(() {
                          showUploadProgress = false;
                        });
                      },
                      child: const Text('取消上传'),
                    ),
                  ],
                ),
                const Text('\n------------下载------------\n'),
                showDownloadProgress
                    ? Column(
                        children: [
                          LinearProgressIndicator(
                            minHeight: 10,
                            backgroundColor: Colors.green,
                            value: downloadProgressValue,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                          Text('${(downloadProgressValue * 100).toInt()}%'),
                        ],
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          Fluttertoast.showToast(
                              msg: "下载到的文件夹不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/test3.webp';
                        File file = File(filePath);
                        print('macy777 --download-- > $filePath');
                        final storageRef = FirebaseStorage.instance.ref('Images');
                        final imagesRef = storageRef.child('abc.webp');
                        downLoadFile(imagesRef, file);
                      },
                      child: const Text('下载图片'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          Fluttertoast.showToast(
                              msg: "下载到的文件夹不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/video.mp4';
                        File file = File(filePath);
                        final storageRef = FirebaseStorage.instance.ref('Videos');
                        final videosRef = storageRef.child('video.mp4');
                        downLoadFile(videosRef, file);
                      },
                      child: const Text('下载视频'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          Fluttertoast.showToast(
                              msg: "下载到的文件夹不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/pdf_test.pdf';
                        File file = File(filePath);
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final docsRef = storageRef.child('abc.pdf');
                        downLoadFile(docsRef, file);
                      },
                      child: const Text('下载文档'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          downloadProgressValue = 0.0;
                          showDownloadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final textRef = storageRef.child('text');

                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          Fluttertoast.showToast(
                              msg: "下载到的文件夹不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/text.txt';
                        File file = File(filePath);
                        downLoadFile(textRef, file);
                      },
                      child: const Text('下载字符串'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          Fluttertoast.showToast(
                              msg: "下载到的文件夹不存在",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/test1.jpg';
                        File file = File(filePath);
                        final imagesRef = FirebaseStorage.instance.ref('Images/originData');
                        downLoadFile(imagesRef, file);
                      },
                      child: const Text('下载原始数据'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Pause the upload.
                        bool? paused = await myDownloadTask?.pause();
                        print('macy777 ----paused, $paused');
                      },
                      child: const Text('暂停下载'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool? resumed = await myDownloadTask?.resume();
                        print('macy777 ----resumed, $resumed');
                      },
                      child: const Text('恢复下载'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool? canceled = await myDownloadTask?.cancel();
                        print('macy777 ----canceled, $canceled');
                        setState(() {
                          showDownloadProgress = false;
                        });
                      },
                      child: const Text('取消下载'),
                    ),
                  ],
                ),
                const Text('\n------------文件元数据------------\n'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            showLoadingCircle = true;
                          });
                          var storageRef = FirebaseStorage.instance.ref('Images');
                          var imageRef = storageRef.child('fengjing.webp');
                          FullMetadata metadata = await imageRef.getMetadata();
                          currentMetadata = 'path:${metadata.fullPath}\nname:${metadata.name}'
                              '\ncontentType:${metadata.contentType}\ncontentLanguage:${metadata.contentLanguage}';
                          setState(() {
                            showLoadingCircle = false;
                          });
                        },
                        child: const Text('获取元数据')),
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            showLoadingCircle = true;
                          });
                          var storageRef = FirebaseStorage.instance.ref('Images');
                          var imageRef = storageRef.child('fengjing.webp');

                          final newMetadata = SettableMetadata(
                            cacheControl: "public,max-age=300",
                            contentType: "image/jpeg",
                            contentLanguage: "en",
                          );

                          final metadata = await imageRef.updateMetadata(newMetadata);
                          currentMetadata = 'path:${metadata.fullPath}\nname:${metadata.name}'
                              '\ncontentType:${metadata.contentType}\ncontentLanguage:${metadata.contentLanguage}';
                          setState(() {
                            showLoadingCircle = false;
                          });
                        },
                        child: const Text('更新元数据')),
                  ],
                ),
                showLoadingCircle ? const CircularProgressIndicator() : Text(currentMetadata),
                const Text('\n------------删除服务器文件------------\n'),
                showDeleteLoading ? const LinearProgressIndicator() : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            deleteFail = false;
                            showDeleteLoading = true;
                          });
                          final storageRef = FirebaseStorage.instance.ref('Images');
                          final imagesRef = storageRef.child('abc.webp');
                          try {
                            await imagesRef.delete();
                          } catch (e) {
                            setState(() {
                              deleteException = '$e';
                              deleteFail = true;
                            });
                            print('macy777 --delete picture exception-- > $e');
                          } finally {
                            setState(() {
                              showDeleteLoading = false;
                            });
                          }
                        },
                        child: const Text('删除图片')),
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            deleteFail = false;
                            showDeleteLoading = true;
                          });
                          final storageRef = FirebaseStorage.instance.ref('Videos');
                          final imagesRef = storageRef.child('video.mp4');
                          try {
                            await imagesRef.delete();
                          } catch (e) {
                            setState(() {
                              deleteException = '$e';
                              deleteFail = true;
                            });
                            print('macy777 --delete video exception-- > $e');
                          } finally {
                            setState(() {
                              showDeleteLoading = false;
                            });
                          }
                        },
                        child: const Text('删除视频')),
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            deleteFail = false;
                            showDeleteLoading = true;
                          });
                          final storageRef = FirebaseStorage.instance.ref('Docs');
                          final imagesRef = storageRef.child('abc.pdf');
                          try {
                            await imagesRef.delete();
                          } catch (e) {
                            setState(() {
                              deleteException = '$e';
                              deleteFail = true;
                            });
                            print('macy777 --delete doc exception-- > $e');
                          } finally {
                            setState(() {
                              showDeleteLoading = false;
                            });
                          }
                        },
                        child: const Text('删除文档')),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(deleteFail ? 16.0 : 0.0),
                  child: deleteFail ? Text('\n删除失败:\n$deleteException\n') : const SizedBox(),
                ),
                const Text('\n------------列出服务器文件------------\n'),
                Container(
                  alignment: Alignment.centerLeft,
                  child: showBucketListLoading
                      ? const LinearProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(bucketListString),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          bucketListString = '';
                          showBucketListLoading = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref();
                        final listResult = await storageRef.listAll();
                        for (var prefix in listResult.prefixes) {
                          // The prefixes under storageRef.
                          // You can call listAll() recursively on them.
                          print('macy777---prefix--> $prefix  ${prefix.name}');
                          bucketListString = '$bucketListString\n${prefix.fullPath}';
                        }
                        for (var item in listResult.items) {
                          // The items under storageRef.
                          print('macy777---item--> $item ${item.name}');
                          bucketListString = '$bucketListString\n${item.fullPath}';
                        }
                        setState(() {
                          showBucketListLoading = false;
                        });
                      },
                      child: const Text('列出桶Root结构'),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     setState(() {
                    //       bucketListString = '';
                    //       showBucketListLoading = true;
                    //     });
                    //     final storageRef = FirebaseStorage.instance.ref();
                    //     getBucketList(storageRef);
                    //
                    //   },
                    //   child: const Text('列出桶结构'),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 88,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: const Key('image'),
            heroTag: Icons.image,
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const PicturePage();
              }));
            },
            child: const Icon(Icons.image),
          ),
          const SizedBox(
            width: 16,
          ),
          FloatingActionButton(
            key: const Key('storage'),
            heroTag: Icons.storage,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const BucketListPage();
              }));
            },
            child: const Icon(Icons.storage),
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // This trailing comma makes auto-formatting nicer
      // for build methods.
    );
  }

  ///将本地文件上传到Firebase Cloud Storage
  void uploadFile(UploadTask? myUploadTask) {
    try {
      setState(() {
        uploadProgressValue = 0.0;
        showUploadProgress = true;
      });
      myUploadTask?.snapshotEvents.listen((taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            setState(() {
              uploadProgressValue = progress / 100;
            });
            print("macy777 ----Upload is $progress% complete.");
            break;
          case TaskState.paused:
            print("macy777 ----Upload is paused.");
            break;
          case TaskState.success:
            print("macy777 ----Upload was succeed");
            Future.delayed(const Duration(milliseconds: 500), () {
              showUploadProgress = false;
              setState(() {});
            });
            break;
          case TaskState.canceled:
            print("macy777 ----Upload was canceled");
            setState(() {
              showUploadProgress = false;
            });
            break;
          case TaskState.error:
            print("macy777 ----Upload was erred");
            setState(() {
              showUploadProgress = false;
            });
            break;
        }
      }).onError((handleError) {
        setState(() {
          showUploadProgress = false;
        });
        print('macy777 ----上传文件---handleError---  $handleError');
      });
    } on FirebaseException catch (e) {
      setState(() {
        showUploadProgress = false;
      });
      print('macy777 ----上传文件---exception---  $e');
    }
  }

  Future<Directory?> getDownloadDir() async {
    Directory? appFilesDir = await getExternalStorageDirectory();
    if (appFilesDir == null) {
      return null;
    }
    var lastIndexOf = appFilesDir.absolute.path.lastIndexOf('/');
    if (lastIndexOf == -1) {
      return null;
    }
    String appDownloadDirPath = appFilesDir.absolute.path.substring(0, lastIndexOf);
    Directory appDownloadDir = Directory('$appDownloadDirPath/download');
    if (!appDownloadDir.existsSync()) {
      appDownloadDir.createSync(recursive: true);
    }
    return appDownloadDir;
  }

  ///从Firebase Cloud Storage下载文件到本地存储
  void downLoadFile(Reference bucketReference, File file) {
    try {
      setState(() {
        downloadProgressValue = 0.0;
        showDownloadProgress = true;
      });
      myDownloadTask = bucketReference.writeToFile(file);
      myDownloadTask?.snapshotEvents.listen((taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            setState(() {
              downloadProgressValue = progress / 100;
            });
            print("macy777 ----Download is $progress% complete.");
            break;
          case TaskState.paused:
            print("macy777 ----Download is paused.");
            break;
          case TaskState.success:
            print("macy777 ----Download was succeed");
            Future.delayed(const Duration(milliseconds: 500), () {
              showDownloadProgress = false;
              setState(() {});
            });
            break;
          case TaskState.canceled:
            print("macy777 ----Download was canceled");
            setState(() {
              showDownloadProgress = false;
            });
            break;
          case TaskState.error:
            print("macy777 ----Download was erred");
            setState(() {
              showDownloadProgress = false;
            });
            break;
        }
      }).onError((handlerError) {
        setState(() {
          showDownloadProgress = false;
        });
        print('macy777 ----下载文件---handlerError---  $handlerError');
      });
    } on FirebaseException catch (e) {
      setState(() {
        showDownloadProgress = false;
      });
      print('macy777 ----下载文件---exception---  $e');
    }
  }

  Stream<ListResult> listAllPaginated(Reference storageRef) async* {
    String? pageToken;
    do {
      final listResult = await storageRef.list(ListOptions(
        maxResults: 100,
        pageToken: pageToken,
      ));
      yield listResult;
      pageToken = listResult.nextPageToken;
    } while (pageToken != null);
  }

  void getRootBucketList() {
    setState(() {
      bucketListString = '';
      showBucketListLoading = true;
    });
    final storageRef = FirebaseStorage.instance.ref();
    listAllPaginated(storageRef).listen((listResult) {
      for (var prefix in listResult.prefixes) {
        print('macy777---xxxprefix--> $prefix');
        bucketListString = '$bucketListString\n${prefix.fullPath}';
      }
      for (var item in listResult.items) {
        print('macy777---xxxitem--> $item');
        bucketListString = '$bucketListString\n${item.fullPath}';
      }
      setState(() {
        showBucketListLoading = false;
      });
    });
  }

  void getBucketList(Reference storageRef) async {
    final listResult = await storageRef.listAll();
    for (var prefix in listResult.prefixes) {
      // The prefixes under storageRef.
      // You can call listAll() recursively on them.
      print('macy777---prefix--> $prefix  ${prefix.name}');
      bucketListString = '$bucketListString\n${prefix.fullPath}';
      getBucketList(storageRef.child(prefix.name));
    }
    for (var item in listResult.items) {
      // The items under storageRef.
      print('macy777---item--> $item ${item.name}');
      bucketListString = '$bucketListString\n${item.fullPath}';
    }
    setState(() {
      showBucketListLoading = false;
    });
  }
}
