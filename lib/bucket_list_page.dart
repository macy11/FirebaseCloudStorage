import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BucketListPage extends StatefulWidget {
  const BucketListPage({super.key});

  @override
  State<BucketListPage> createState() => _BucketListPageState();
}

class _BucketListPageState extends State<BucketListPage> {
  bool showLoading = true;
  List<StorageItem> storageList = [];
  bool isInit = true;
  late Reference currentRef;

  @override
  void initState() {
    final storageRef = FirebaseStorage.instance.ref();
    getBucketList(storageRef);
    super.initState();
  }

  void getBucketList(Reference storageRef) async {
    currentRef = storageRef;
    setState(() {
      showLoading = true;
    });
    List<StorageItem> list = [];
    final listResult = await storageRef.listAll();
    for (var prefix in listResult.prefixes) {
      print('macy777---prefix--> ${prefix.fullPath}');
      list.add(StorageItem(path: prefix.fullPath, name: prefix.name, isDir: true));
    }
    for (var item in listResult.items) {
      print('macy777---item--> ${item.fullPath}');
      list.add(StorageItem(path: item.fullPath, name: item.name, isDir: false));
    }
    setState(() {
      isInit = false;
      storageList = list;
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Storage List')),
        body: Stack(
          alignment: Alignment.center,
          children: [
            isInit
                ? const Center()
                : storageList.isNotEmpty
                    ? ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          var storageItem = storageList[index];
                          return CupertinoButton(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(storageItem.name),
                            ),
                            onPressed: () {
                              if (storageItem.isDir) {
                                final storageRef = FirebaseStorage.instance.ref(storageItem.path);
                                getBucketList(storageRef);
                              }
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            height: 1.0,
                          );
                        },
                        itemCount: storageList.length,
                      )
                    : const Center(
                        child: Text('此处还没有文件'),
                      ),
            showLoading ? const CircularProgressIndicator() : const SizedBox(),
          ],
        ),
      ),
      onWillPop: () async {
        Reference? parent = currentRef.parent;
        if (parent == null) {
          return true;
        } else {
          getBucketList(parent);
          return false;
        }
      },
    );
  }
}

class StorageItem {
  String path;
  String name;
  bool isDir;

  StorageItem({
    required this.path,
    required this.name,
    required this.isDir,
  });
}
