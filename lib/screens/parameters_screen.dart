import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/markov_model.dart';

class ParametersScreen extends StatelessWidget {
  const ParametersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MarkovModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Temporal Parameters", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("How to Solve"),
                  content: const Text(
                    "This app computes the future probability distribution of the Markov Chain.\n\n"
                    "1. Define the transition matrix (M).\n"
                    "2. Set the initial probability vector (P) at time t.\n"
                    "3. Set the target time step (K).\n\n"
                    "The app calculates iteratively: P(n+1) = P(n) × M",
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
                  ],
                )
              );
            },
            icon: Icon(Icons.help, color: isDark ? Colors.grey : Colors.grey[400])
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Define the initial state of the system and the projection time horizon for the Markov process.",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Start State Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text("Start Configuration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                       Icon(Icons.settings_input_component, color: Theme.of(context).primaryColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Start Step Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2127) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("START INSTANT (t)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                         Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: model.startStep.toString(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: "e.g. 0"
                                ),
                                onChanged: (value) {
                                  final val = int.tryParse(value);
                                  if (val != null && val >= 0) {
                                    context.read<MarkovModel>().setStartStep(val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vector Input (Always visible)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2127) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text("PROBABILITY VECTOR AT t (SUM = 1.0)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12, runSpacing: 12,
                            children: List.generate(model.n, (index) {
                              return SizedBox(
                                width: 80,
                                child: TextFormField(
                                  // Use Key to force rebuild if n changes or reset happens, usually handled by parent rebuild but good to be safe if values stick
                                  key: ValueKey("vec_${index}_${model.initialVector[index]}"), 
                                  initialValue: model.initialVector[index].toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: "S${index+1}",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) {
                                    double? d = double.tryParse(val);
                                    if(d != null) context.read<MarkovModel>().updateInitialVector(index, d);
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          if (!model.validateInitialVector())
                            const Text("Vector sum must be 1.0", style: TextStyle(color: Colors.red, fontSize: 12))
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Time Horizon Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text("Target instant", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                       Icon(Icons.schedule, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2127) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TARGET INSTANT (K)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                         Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: model.targetSteps.toString(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: "e.g. 10"
                                ),
                                onChanged: (value) {
                                  final val = int.tryParse(value);
                                  if (val != null && val > 0) {
                                    context.read<MarkovModel>().setTargetSteps(val);
                                  }
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("STEP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Theme.of(context).primaryColor)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("Must satisfy K > t", style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const SizedBox(height: 32),
                  // Calculation Logic
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                           ? [const Color(0xFF151F2B), const Color(0xFF1C2936)] 
                           : [Colors.grey[100]!, Colors.grey[200]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155).withOpacity(0.5) : Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.functions, color: Theme.of(context).primaryColor, size: 18),
                            const SizedBox(width: 8),
                            Text("CALCULATION LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey[500])),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "P_(n+1) = P_n × M",
                          style: TextStyle(
                            fontFamily: 'Monospace', 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                         const SizedBox(height: 12),
                         Text(
                           "Where:\n"
                           "• P_(n+1): Probability distribution at step n+1\n"
                           "• P_n: Probability distribution at step n\n"
                           "• M: Transition Matrix",
                           style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[800], height: 1.5),
                         )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
           Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   if (model.useInitialVector) {
                      if (!model.validateInitialVector()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Initial vector must sum to 1.0")));
                        return;
                      }
                   }
                   context.read<MarkovModel>().calculate();
                   Navigator.pushNamed(context, '/result');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text(
                      "Calculate Solution",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
