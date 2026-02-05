import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/markov_model.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart'; // For RepaintBoundary
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MarkovModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final GlobalKey globalKey = GlobalKey(); // Key for RepaintBoundary
    
    // Fallback if no result yet (shouldn't happen if navigated correctly)
    if (model.resultVector == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final results = model.resultVector!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculation Result", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             const SizedBox(height: 24),
             Text(
               "State Distribution (K=${model.targetSteps})",
               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 4),
             Text(
               "Convergence check: Stable", // Placeholder logic
               style: TextStyle(color: Colors.grey[500], fontSize: 14),
             ),
             const SizedBox(height: 24),

             // Final Vector Card
             Container(
               margin: const EdgeInsets.symmetric(horizontal: 16),
               constraints: const BoxConstraints(minHeight: 200), // Flexible height
               width: double.infinity,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Theme.of(context).primaryColor.withOpacity(0.3),
                     blurRadius: 20,
                     offset: const Offset(0, 10),
                   )
                 ],
                 image: const DecorationImage(
                   image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuB4npcA7Y5yfpOtFsYoPMFS14jVj0QwV7e7voVSxB8t2sQdHPnqY6zVLMSXDaO0W2HzUhDKo42OCON8o9ybt1IiLXq3v4YqbB6pmGwMewKygSGn59JMFk6zYQfcNf9Ki2kvmNCcVvsIxky3x9IZ7gB8cAw1cDEUDqG57SeGedl-qoIIIky8b4XZ86SxYUapRq6PeRDQXLKW7iD4LF33YviqUM9apH0YLIu-PscxdIxwnwfFEst17T5O_KFZvFsDf3a5InYyW6HGKr7U"),
                   fit: BoxFit.cover,
                   colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                 ),
                 gradient: LinearGradient(
                   begin: Alignment.bottomCenter,
                   end: Alignment.topCenter,
                   colors: [
                     Theme.of(context).primaryColor.withOpacity(0.9),
                     const Color(0xFF101922).withOpacity(0.4),
                   ],
                 )
               ),
               child: Padding(
                 padding: const EdgeInsets.all(24),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 "Final Vector π",
                                 style: TextStyle(
                                   color: Colors.white.withOpacity(0.8),
                                   fontSize: 14,
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: 1.0,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 "[${results.map((e) => e.toStringAsFixed(2)).join(", ")}]",
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 24, 
                                   fontFamily: 'Monospace',
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 "Probability sum = ${results.fold(0.0, (a,b)=>a+b).toStringAsFixed(1)}",
                                 style: TextStyle(
                                   color: Colors.white.withOpacity(0.9),
                                   fontSize: 14,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: const Icon(Icons.functions, color: Colors.white, size: 32),
                         )
                       ],
                     )
                   ],
                 ),
               ),
             ),

             const SizedBox(height: 16),
             
             // Breakdown
             _buildSection(context, title: "Probability Breakdown", child: Column(
               children: List.generate(model.n, (index) {
                 final prob = results[index];
                 final percentage = (prob * 100).toStringAsFixed(0);
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child: Row(
                     children: [
                       SizedBox(
                         width: 60,
                         child: Text("State ${index+1}", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                       ),
                       Expanded(
                         child: Container(
                           height: 12,
                           decoration: BoxDecoration(
                             color: isDark ? const Color(0xFF283039) : Colors.grey[100],
                             borderRadius: BorderRadius.circular(6),
                           ),
                           child: FractionallySizedBox(
                             alignment: Alignment.centerLeft,
                             widthFactor: prob,
                             child: Container(
                               decoration: BoxDecoration(
                                 color: Theme.of(context).primaryColor,
                                 borderRadius: BorderRadius.circular(6),
                               ),
                             ),
                           ),
                         ),
                       ),
                       SizedBox(
                         width: 40,
                         child: Text(
                           "$percentage%", 
                           textAlign: TextAlign.right,
                           style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Monospace'),
                         ),
                       ),
                     ],
                   ),
                 );
               }),
             )),

             // Diagram Section (Exportable)
             _buildSection(context, title: "State Transition Diagram", child: Column(
               children: [
                 RepaintBoundary(
                   key: globalKey,
                   child: Container(
                     color: isDark ? const Color(0xFF1A2632) : Colors.white, // Background for capture
                     height: 300,
                     width: double.infinity,
                     child: CustomPaint(
                       painter: TransitionDiagramPainter(
                         n: model.n,
                         matrix: model.matrix,
                         primaryColor: Theme.of(context).primaryColor,
                         isDark: isDark,
                       ),
                     ),
                   ),
                 ),
               ],
             )),

             // Calculations (Detailed)
             _buildSection(context, title: "Calculation Details", child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text("State Vector P(${model.startStep})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111418) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[200]!),
                    ),
                    child: Text(
                      "[ ${model.useInitialVector ? model.initialVector.join(", ") : List.generate(model.n, (i) => i == model.initialState ? "1.0" : "0.0").join(", ")} ]",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Monospace', fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text("Transition Matrix (M)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111418) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[200]!),
                    ),
                    child: Column(
                       children: model.matrix.map((row) => Padding(
                         padding: const EdgeInsets.symmetric(vertical: 2),
                         child: Text(
                           "[ ${row.map((e) => e.toString()).join(", ")} ]",
                           style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Monospace', fontSize: 13),
                         ),
                       )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text("Steps (k): ${model.targetSteps}", style: const TextStyle(fontWeight: FontWeight.bold)),
               ],
             )),

             // Step-by-Step History
             if (model.stepHistory.isNotEmpty)
               _buildSection(context, title: "Step-by-Step Calculation", child: Column(
                 children: model.stepHistory.map((stepData) {
                   final step = stepData.keys.first;
                   final vector = stepData.values.first;
                   return Container(
                     margin: const EdgeInsets.only(bottom: 12),
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: isDark ? const Color(0xFF111418) : Colors.grey[50],
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[200]!),
                     ),
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Theme.of(context).primaryColor.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Text("t = $step", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).primaryColor)),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Text(
                             "[ ${vector.map((e) => e.toStringAsFixed(2)).join(", ")} ]",
                             style: const TextStyle(fontFamily: 'Monospace', fontSize: 13, fontWeight: FontWeight.bold),
                           ),
                         ),
                       ],
                     ),
                   );
                 }).toList(),
               )),
             
             const SizedBox(height: 100), // Spacing for bottom bar
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                   try {
                     RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                     if (byteData != null) {
                       final directory = await getApplicationDocumentsDirectory();
                       final imagePath = await File('${directory.path}/markov_diagram.png').create();
                       await imagePath.writeAsBytes(byteData.buffer.asUint8List());
                       
                       // Share
                       await Share.shareXFiles([XFile(imagePath.path)], text: 'Markov Chain Transition Diagram');
                     }
                   } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error exporting: $e")));
                      }
                   }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.ios_share, size: 20),
                    const SizedBox(width: 8),
                    Text("Export Graph", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: ElevatedButton(
                onPressed: () {
                   context.read<MarkovModel>().reset();
                   // Fix for crash: use pushNamedAndRemoveUntil to reset navigation stack properly
                   Navigator.of(context).pushNamedAndRemoveUntil('/setup', (route) => false);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text("Restart"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF2D3748) : Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 16),
             child,
          ],
        ),
      ),
    );
  }
}

class TransitionDiagramPainter extends CustomPainter {
  final int n;
  final List<List<double>> matrix;
  final Color primaryColor;
  final bool isDark;

  TransitionDiagramPainter({required this.n, required this.matrix, required this.primaryColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background if needed for export visibility (but handled by wrapper container usually)
    // canvas.drawRect(Offset.zero & size, Paint()..color = isDark ? const Color(0xFF1A2632) : Colors.white);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;
    final nodeRadius = 20.0;
    
    final paintNode = Paint()
      ..color = isDark ? const Color(0xFF1A2632) : Colors.white
      ..style = PaintingStyle.fill;
      
    final paintStroke = Paint()
      ..color = isDark ? Colors.grey[700]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final paintArrow = Paint()
      ..color = isDark ? Colors.grey[600]! : Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paintText = TextPainter(textDirection: TextDirection.ltr);
    
    // Calculate node positions
    final nodePositions = <Offset>[];
    for (int i = 0; i < n; i++) {
        final angle = -pi / 2 + (2 * pi * i) / n;
        nodePositions.add(Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ));
    }

    // Draw edges
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        final p = matrix[i][j];
        if (p < 0.05) continue; // Skip small prob edges for clarity
        
        final start = nodePositions[i];
        final end = nodePositions[j];
        
        if (i == j) {
           // Self loop
           final angle = -pi / 2 + (2 * pi * i) / n;
           final loopCenter = Offset(
              center.dx + (radius + 40) * cos(angle),
              center.dy + (radius + 40) * sin(angle),
           );
           canvas.drawCircle(loopCenter, 15, paintStroke);
           // Draw label
           _drawText(canvas, p.toStringAsFixed(1), loopCenter, paintText);
        } else {
           // Draw arrow
           // Calculate start/end on circumference
           final dx = end.dx - start.dx;
           final dy = end.dy - start.dy;
           final angle = atan2(dy, dx);
           
           final startP = Offset(start.dx + nodeRadius * cos(angle), start.dy + nodeRadius * sin(angle));
           final endP = Offset(end.dx - nodeRadius * cos(angle), end.dy - nodeRadius * sin(angle));
           
           _drawArrow(canvas, startP, endP, paintArrow);
           
           // Midpoint for label
           // We need to shift the label perpendicular to the line to avoid overlap with the other direction
           final mx = (start.dx + end.dx) / 2;
           final my = (start.dy + end.dy) / 2;
           
           // Perpendicular vector
           final pdx = -sin(angle);
           final pdy = cos(angle);
           
           // Shift amount (e.g. 15 pixels)
           final shift = 15.0;
           
           final labelPos = Offset(mx + pdx * shift, my + pdy * shift);
           
           _drawText(canvas, p.toStringAsFixed(1), labelPos, paintText);
        }
      }
    }

    // Draw nodes on top
    for (int i = 0; i < n; i++) {
       canvas.drawCircle(nodePositions[i], nodeRadius, paintNode);
       canvas.drawCircle(nodePositions[i], nodeRadius, paintStroke);
       
       _drawText(canvas, "S${i+1}", nodePositions[i], paintText, isBold: true);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    
    // Draw Arrow Head
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = atan2(dy, dx);
    final arrowSize = 10.0;
    final arrowAngle = pi / 6; // 30 degrees
    
    final p1 = Offset(
      end.dx - arrowSize * cos(angle - arrowAngle),
      end.dy - arrowSize * sin(angle - arrowAngle),
    );
     final p2 = Offset(
      end.dx - arrowSize * cos(angle + arrowAngle),
      end.dy - arrowSize * sin(angle + arrowAngle),
    );
    
    final path = Path()..moveTo(end.dx, end.dy)..lineTo(p1.dx, p1.dy)..moveTo(end.dx, end.dy)..lineTo(p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset center, TextPainter painter, {bool isBold = false}) {
     painter.text = TextSpan(
       text: text,
       style: TextStyle(
         color: isDark ? Colors.white : Colors.black,
         fontSize: 12,
         fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
       ),
     );
     painter.layout();
     painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
