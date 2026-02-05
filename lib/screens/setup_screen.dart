import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/markov_model.dart';


class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MarkovModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          "New Markov Chain",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,

      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Hero Icon
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark 
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [Colors.blue[50]!, Colors.blue[100]!],
                      ),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : Colors.blue[100]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.hub,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    "Define System",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the total number of states in your system (n > 0). This determines the matrix size.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Number Input
                  const Text(
                    "NUMBER OF STATES (N)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Decrement
                      _buildControlButton(
                        context, 
                        icon: Icons.remove, 
                        onTap: () {
                          if (model.n > 2) {
                            context.read<MarkovModel>().setStatesCount(model.n - 1);
                          }
                        }
                      ),
                      const SizedBox(width: 16),
                      // Input
                      Container(
                        width: 160,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).inputDecorationTheme.enabledBorder!.borderSide.color,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${model.n}",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                       const SizedBox(width: 16),
                      // Increment
                      _buildControlButton(
                        context, 
                        icon: Icons.add, 
                        onTap: () {
                          if (model.n < 10) { // Limit reasonable size
                             context.read<MarkovModel>().setStatesCount(model.n + 1);
                          }
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Quick Select
                  const Text(
                    "QUICK SELECT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16, // Increased gap
                    runSpacing: 16,
                    children: [2, 3, 4, 5, 6, 7].map((n) {
                      final isSelected = model.n == n;
                      return GestureDetector(
                        onTap: () => context.read<MarkovModel>().setStatesCount(n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).primaryColor.withOpacity(0.1) 
                                : (isDark ? const Color(0xFF283039) : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor.withOpacity(0.5) 
                                  : Colors.transparent,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)
                            ] : [],
                          ),
                          child: Text(
                            "$n States",
                            style: TextStyle(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : (isDark ? Colors.white : Colors.black87),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/matrix');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_4x4),
                        SizedBox(width: 8),
                        Text(
                          "Generate Matrix",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Step 1 of 3",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? Colors.transparent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), // slate-500
          ),
        ),
      ),
    );
  }
}
