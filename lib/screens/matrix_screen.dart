import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'matrix_cell_input.dart';
import 'package:provider/provider.dart';
import '../models/markov_model.dart';


class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<MarkovModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final n = model.n;
    final matrix = model.matrix;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transition Matrix", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Define Probabilities", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the transition probabilities for the $n states defined. Ensure each row sums to exactly 1.0.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Matrix Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2127) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // We need horizontal scroll if n is large
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              // Header Row
                              Row(
                                children: [
                                  const SizedBox(width: 80, child: Center(child: Text("From\\To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)))),
                                  ...List.generate(n, (index) => 
                                    Container(
                                      width: 80,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "S${index + 1}",
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Rows
                              ...List.generate(n, (rowIdx) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      // Row Header
                                      Container(
                                        width: 80,
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF334155).withOpacity(0.3) : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text("S${rowIdx + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      ),
                                      ...List.generate(n, (colIdx) {
                                        return Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: MatrixCellInput(
                                            value: matrix[rowIdx][colIdx],
                                            onChanged: (val) {
                                               context.read<MarkovModel>().updateMatrixCell(rowIdx, colIdx, val);
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Validation Summary
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Validation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text("Auto-checking", style: TextStyle(fontSize: 10)), 
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Color(0xFF1C2127), // surface-dark
                        side: BorderSide(color: Color(0xFF3B4754)),
                        labelStyle: TextStyle(color: Color(0xFF9DABB9)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(n, (rowIdx) {
                     final rowSum = matrix[rowIdx].fold(0.0, (a, b) => a + b);
                     final isValid = (rowSum - 1.0).abs() < 0.001;
                     
                     return Container(
                       margin: const EdgeInsets.only(bottom: 8),
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: isValid 
                            ? (isDark ? const Color(0xFF052e16).withOpacity(0.3) : const Color(0xFFF0FDF4))
                            : (isDark ? const Color(0xFF450a0a).withOpacity(0.3) : const Color(0xFFFEF2F2)),
                         border: Border.all(
                           color: isValid 
                              ? (isDark ? Colors.green[900]!.withOpacity(0.5) : Colors.green[100]!) 
                              : (isDark ? Colors.red[900]!.withOpacity(0.5) : Colors.red[100]!),
                         ),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Row(
                         children: [
                           Container(
                             padding: const EdgeInsets.all(6),
                             decoration: BoxDecoration(
                               color: isValid 
                                  ? (isDark ? Colors.green[500]!.withOpacity(0.2) : Colors.green[100])
                                  : (isDark ? Colors.red[500]!.withOpacity(0.2) : Colors.red[100]),
                               shape: BoxShape.circle,
                             ),
                             child: Icon(
                               isValid ? Icons.check_circle : Icons.warning,
                               size: 16,
                               color: isValid ? Colors.green : Colors.red,
                             ),
                           ),
                           const SizedBox(width: 12),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 "Row S${rowIdx + 1}", 
                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                               ),
                               Text(
                                 "Sum: ${rowSum.toStringAsFixed(2)} (${isValid ? 'Valid' : 'Invalid'})",
                                 style: TextStyle(
                                   color: isValid 
                                      ? (isDark ? Colors.green[400] : Colors.green[700]) 
                                      : (isDark ? Colors.red[400] : Colors.red[700]), 
                                   fontSize: 12
                                 ),
                               ),
                             ],
                           )
                         ],
                       ),
                     );
                  }),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey[200]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   if (model.validateMatrix()) {
                     Navigator.pushNamed(context, '/parameters');
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please ensure all rows sum to 1.0')),
                     );
                   }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Next: State Parameters", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),

          ),
        ],
      ),
    );
  }
}
