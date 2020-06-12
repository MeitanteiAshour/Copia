import 'dart:io';

import 'package:copia/Hive/database.dart';
import 'package:copia/Provider/pdfscreen_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neumorphic/neumorphic.dart' as Neu;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class PdfAudio extends StatelessWidget {
  final int index;
  PdfAudio(this.index);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: NeumorphicIcon(
        Icons.headset,
        style: NeumorphicStyle(color: Color(0xffDCC69B), intensity: 0.6),
      ),
      onTap: () => _pdfAudio(context),
    );
  }

  void _pdfAudio(context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Consumer<PDFScreenBloc>(
          builder: (_, bloc, __) => ValueListenableBuilder(
            valueListenable: Hive.box('pdfDB').listenable(),
            builder: (_, Box box, child) {
              PDFDB _pdf = box.getAt(index);
              if (_pdf.soundPath == null) {
                return Container(
                  color: Color(0xff26292D),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 150,
                          height: 150,
                          child:
                              SvgPicture.asset('assets/images/owl_audio.svg')),
                      Center(
                        child: Container(
                          child: Text(
                            "You don't have an audio for this PDF",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: 100,
                        height: 50,
                        child: GestureDetector(
                          child: Neu.NeuCard(
                            bevel: 2,
                            child: Center(
                              child: Text(
                                'Add audio',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            decoration: Neu.NeumorphicDecoration(
                                color: Color(0xffD44626),
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onTap: () {
                            FilePicker.getFile(type: FileType.audio).then(
                              (value) {
                                final _modifiedPDF = PDFDB(
                                    bookmarked: _pdf.bookmarked,
                                    insertedDate: _pdf.insertedDate,
                                    lastSeenDate: _pdf.lastSeenDate,
                                    lastVisitedPage: _pdf.lastVisitedPage,
                                    pageNote: _pdf.pageNote,
                                    pdfAsset: _pdf.pdfAsset,
                                    pdfName: _pdf.pdfName,
                                    soundPath: value?.path ?? null,
                                    thumb: _pdf.thumb,
                                    totalHours: _pdf.totalHours,
                                    documentPath: _pdf.documentPath);
                                box.putAt(index, _modifiedPDF);
                              },
                            );
                            bloc.hideFabButton = false;
                            print(bloc.hideFab);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  color: Color(0xff26292D),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Neu.NeuCard(
                          decoration: Neu.NeumorphicDecoration(
                            color: const Color(0xff26292D),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: const Color(0xff1F2327),
                            child: ClipOval(
                              child: Image.file(
                                File(_pdf.thumb),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${basename(_pdf.soundPath).replaceAll('.mp3', "")}',
                                  style: TextStyle(
                                      fontFamily: 'cormorant',
                                      color: Color(0xffAAABAD),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Neumorphic(
                                style: NeumorphicStyle(
                                    color: Color(0xff1E2125),
                                    depth: 3,
                                    intensity: 0.3,
                                    lightSource: LightSource.topLeft,
                                    boxShape: NeumorphicBoxShape.circle()),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      final _modifiedPDF = PDFDB(
                                          bookmarked: _pdf.bookmarked,
                                          insertedDate: _pdf.insertedDate,
                                          lastSeenDate: _pdf.lastSeenDate,
                                          lastVisitedPage: _pdf.lastVisitedPage,
                                          pageNote: _pdf.pageNote,
                                          pdfAsset: _pdf.pdfAsset,
                                          pdfName: _pdf.pdfName,
                                          soundPath: null,
                                          thumb: _pdf.thumb,
                                          totalHours: _pdf.totalHours,
                                          documentPath: _pdf.documentPath);
                                      box.putAt(index, _modifiedPDF);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                  ),
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
            },
          ),
        );
      },
    );
  }
}
