import 'package:copia/Moor/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:provider/provider.dart';

class PDFScreen extends StatefulWidget {
  final AsyncSnapshot<List<PDFSData>> snapshot;
  final int index;
  final AsyncSnapshot<PDFSData> lastOpenedSnapshot;
  PDFScreen({this.snapshot, this.index, this.lastOpenedSnapshot});
  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  @override
  void didChangeDependencies() {
    final singlePDF = widget.snapshot != null
        ? widget.snapshot.data[widget.index]
        : widget.lastOpenedSnapshot.data;
    final _dbProvider = Provider.of<AppDatabase>(context);
    _dbProvider.updatePDF(singlePDF.copyWith(lastSeenDate: DateTime.now()));

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PDFView(
          filePath: widget.snapshot != null
              ? widget.snapshot.data[widget.index].pdfAsset
              : widget.lastOpenedSnapshot.data.pdfAsset,
          enableSwipe: true,
          fitPolicy: FitPolicy.BOTH,
          swipeHorizontal: true,
          onError: (err) {
            print("error is : $err");
          },
          pageFling: true,
          fitEachPage: true,
          onViewCreated: (s) {
            print('Hello');
          },
          onRender: (_pages) {
            setState(() {
              // pages = _pages;
              // isReady = true;
            });
          },
        ),
      ),
    );
  }

  void update() {
    final _dbBloc = Provider.of<AppDatabase>(context);
    _dbBloc.updates(
      PDFSData(
        lastSeenDate: DateTime.now(),
        id: widget.snapshot.data[widget.index].id,
      ),
    );
  }
}
