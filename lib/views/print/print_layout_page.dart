import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../view/widgets/app_scaffold_layout.dart';

class PrintLayoutPage extends StatelessWidget {
  final Map template;

  const PrintLayoutPage({
    super.key,
    required this.template,
  });

  Future<void> _exportPdf() async {

    final pdf = pw.Document();

    final rows = template['rows'] ?? 1;
    final cols = template['cols'] ?? 1;
    final name = template['name'] ?? "";
    final date = template['date'] ?? "";
    final userFont = (template['userFont'] ?? 12).toDouble();
    final passFont = (template['passFont'] ?? 10).toDouble();
    final Offset userPos =
        template['userPos'] ?? const Offset(20, 30);
    final Offset passPos =
        template['passPos'] ?? const Offset(20, 60);
    final showPass = template['showPass'] ?? true;
    final cards = template['cards'] ?? [];

    final fontData = await rootBundle
        .load("assets/fonts/Alkalami-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    const spacing = 4.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        textDirection: pw.TextDirection.rtl,
        build: (context) {

          final pageWidth = PdfPageFormat.a4.availableWidth;
          final pageHeight = PdfPageFormat.a4.availableHeight - 35;

          final cardWidth =
              (pageWidth - (spacing * (cols + 1))) / cols;

          final cardHeight =
              (pageHeight - (spacing * (rows + 1))) / rows;

          const designHeight = 210;
          final ratio = cardHeight / designHeight;

          return pw.Padding(
            padding: const pw.EdgeInsets.all(spacing),
            child: pw.Column(
              children: [

                pw.Text(
                  "اسم القالب: $name   |   التاريخ: $date",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 12,
                  ),
                ),

                pw.SizedBox(height: spacing),

                pw.Expanded(
                  child: pw.Column(
                    children: List.generate(rows, (r) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: spacing),
                        child: pw.Row(
                          children: List.generate(cols, (c) {

                            final index = r * cols + c;

                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(right: spacing),
                              child: pw.Container(
                                width: cardWidth,
                                height: cardHeight,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(width: 0.5),
                                ),
                                child: index >= cards.length
                                    ? pw.Container()
                                    : pw.Stack(
                                        children: [

                                          pw.Positioned(
                                            left: userPos.dx * ratio,
                                            top: userPos.dy * ratio,
                                            child: pw.Text(
                                              cards[index]['user'] ?? "",
                                              style: pw.TextStyle(
                                                font: ttf,
                                                fontSize:
                                                    userFont * ratio,
                                              ),
                                            ),
                                          ),

                                          if (showPass)
                                            pw.Positioned(
                                              left: passPos.dx * ratio,
                                              top: passPos.dy * ratio,
                                              child: pw.Text(
                                                cards[index]['pass'] ?? "",
                                                style: pw.TextStyle(
                                                  font: ttf,
                                                  fontSize:
                                                      passFont * ratio,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {

    final rows = template['rows'] ?? 0;
    final cols = template['cols'] ?? 0;
    final name = template['name'] ?? "";
    final date = template['date'] ?? "";
    final background = template['background'];
    final userFont = template['userFont'] ?? 12.0;
    final passFont = template['passFont'] ?? 10.0;
    final Offset userPos =
        template['userPos'] ?? const Offset(20, 30);
    final Offset passPos =
        template['passPos'] ?? const Offset(20, 60);
    final showPass = template['showPass'] ?? true;
    final cards = template['cards'] ?? [];

    const spacing = 4.0;

   return AppScaffoldLayout(
  title: "طباعة القالب",
  footerText: "Mikrotik Cards Printing System",
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: _exportPdf,
        ),
      ],
      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Text(
              "اسم القالب: $name   |   التاريخ: $date",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: AspectRatio(
              aspectRatio: 1 / 1.414,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(spacing),
                child: LayoutBuilder(
                  builder: (context, constraints) {

                    final pageWidth = constraints.maxWidth;
                    final pageHeight = constraints.maxHeight;

                    final cardWidth =
                        (pageWidth - (spacing * (cols + 1))) / cols;

                    final cardHeight =
                        (pageHeight - (spacing * (rows + 1))) / rows;

                    const designHeight = 210;
                    final ratio = cardHeight / designHeight;

                    return Column(
                      children: List.generate(rows, (r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: spacing),
                          child: Row(
                            children: List.generate(cols, (c) {

                              final index = r * cols + c;

                              return Padding(
                                padding: const EdgeInsets.only(right: spacing),
                                child: Container(
                                  width: cardWidth,
                                  height: cardHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black,
                                        width: 0.5),
                                    image: background != null
                                        ? DecorationImage(
                                            image: background,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: index >= cards.length
                                      ? null
                                      : Stack(
                                          children: [

                                            Positioned(
                                              left: userPos.dx * ratio,
                                              top: userPos.dy * ratio,
                                              child: Text(
                                                cards[index]['user'] ?? "",
                                                style: TextStyle(
                                                  fontSize:
                                                      userFont * ratio,
                                                ),
                                              ),
                                            ),

                                            if (showPass)
                                              Positioned(
                                                left: passPos.dx * ratio,
                                                top: passPos.dy * ratio,
                                                child: Text(
                                                  cards[index]['pass'] ?? "",
                                                  style: TextStyle(
                                                    fontSize:
                                                        passFont * ratio,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}