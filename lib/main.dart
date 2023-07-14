import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
    androidProvider: AndroidProvider.playIntegrity,
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
                    ? LinearProgressIndicator(
                        minHeight: 10,
                        backgroundColor: Colors.blue,
                        value: uploadProgressValue,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showUploadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Images');
                        final imagesRef = storageRef.child('abc.webp');

                        Directory? appFilesDir = await getExternalStorageDirectory();
                        print('macy777 --appFilesDir-> ${appFilesDir?.absolute.path}');
                        String filePath = '${appFilesDir?.absolute.path}/test3.webp';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          putFileToFBStorage(imagesRef, file);
                        }
                      },
                      child: const Text('上传图片'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showUploadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Videos');
                        final videosRef = storageRef.child('video.mp4');

                        Directory? appFilesDir = await getExternalStorageDirectory();
                        String filePath = '${appFilesDir?.absolute.path}/video.mp4';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          putFileToFBStorage(videosRef, file);
                        }
                      },
                      child: const Text('上传视频'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showUploadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final docsRef = storageRef.child('abc.pdf');

                        Directory? appFilesDir = await getExternalStorageDirectory();
                        String filePath = '${appFilesDir?.absolute.path}/pdf_test.pdf';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          putFileToFBStorage(docsRef, file);
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
                          showUploadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final textRef = storageRef.child('text');

                        String dataUrl = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==';

                        try {
                          await textRef.putString(dataUrl, format: PutStringFormat.dataUrl);
                          setState(() {
                            showUploadProgress = false;
                          });
                        } on FirebaseException catch (e) {
                          print('macy777 上传字符串---exception---  $e');
                        }
                      },
                      child: const Text('上传字符串'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showUploadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Images');
                        final imagesRef = storageRef.child('originData');

                        Directory? appDocDir = await getExternalStorageDirectory();
                        String filePath = '${appDocDir?.absolute.path}/test1.jpg';
                        File file = File(filePath);
                        if (file.existsSync()) {
                          try {
                            await imagesRef.putData(file.readAsBytesSync());
                            setState(() {
                              showUploadProgress = false;
                            });
                          } on FirebaseException catch (e) {
                            print('macy777 上传原始数据---exception---  $e');
                          }
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
                    ? LinearProgressIndicator(
                        minHeight: 10,
                        backgroundColor: Colors.green,
                        value: downloadProgressValue,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showDownloadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Images');
                        final imagesRef = storageRef.child('abc.webp');

                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          setState(() {
                            showDownloadProgress = false;
                          });
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/test3.webp';
                        print('macy777 --download-- > $filePath');
                        File file = File(filePath);
                        downLoadFileFromFBStorage(imagesRef, file);
                      },
                      child: const Text('下载图片'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showDownloadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Videos');
                        final videosRef = storageRef.child('video.mp4');

                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          setState(() {
                            showDownloadProgress = false;
                          });
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/video.mp4';
                        File file = File(filePath);
                        downLoadFileFromFBStorage(videosRef, file);
                      },
                      child: const Text('下载视频'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showDownloadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final docsRef = storageRef.child('abc.pdf');

                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          setState(() {
                            showDownloadProgress = false;
                          });
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/pdf_test.pdf';
                        File file = File(filePath);
                        downLoadFileFromFBStorage(docsRef, file);
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
                          showDownloadProgress = true;
                        });
                        final storageRef = FirebaseStorage.instance.ref('Docs');
                        final textRef = storageRef.child('text');

                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          setState(() {
                            showDownloadProgress = false;
                          });
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/text.txt';
                        File file = File(filePath);
                        downLoadFileFromFBStorage(textRef, file);
                      },
                      child: const Text('下载字符串'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showDownloadProgress = true;
                        });
                        final imagesRef = FirebaseStorage.instance.ref('Images/originData');

                        var appDownloadDir = await getDownloadDir();
                        if (appDownloadDir == null) {
                          setState(() {
                            showDownloadProgress = false;
                          });
                          return;
                        }
                        String filePath = '${appDownloadDir.absolute.path}/test1.jpg';
                        File file = File(filePath);
                        downLoadFileFromFBStorage(imagesRef, file);
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

  ///上传文件
  void putFileToFBStorage(Reference bucketReference, File file) {
    try {
      myUploadTask = bucketReference.putFile(file);
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
            setState(() {
              showUploadProgress = false;
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
      });
    } on FirebaseException catch (e) {
      print('macy777 ----上传文件---exception---  $e');
    }
  }

  Future<Directory?> getDownloadDir() async {
    Directory? appFilesDir = await getExternalStorageDirectory();
    if (appFilesDir == null) {
      setState(() {
        showDownloadProgress = false;
      });
      return null;
    }
    var lastIndexOf = appFilesDir.absolute.path.lastIndexOf('/');
    if (lastIndexOf == -1) {
      setState(() {
        showDownloadProgress = false;
      });
      return null;
    }
    String appDownloadDirPath = appFilesDir.absolute.path.substring(0, lastIndexOf);
    Directory appDownloadDir = Directory('$appDownloadDirPath/download');
    if (!appDownloadDir.existsSync()) {
      appDownloadDir.createSync(recursive: true);
    }
    return appDownloadDir;
  }

  ///下载文件到本地存储
  void downLoadFileFromFBStorage(Reference bucketReference, File file) {
    try {
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
            setState(() {
              showDownloadProgress = false;
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
      });
    } on FirebaseException catch (e) {
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
