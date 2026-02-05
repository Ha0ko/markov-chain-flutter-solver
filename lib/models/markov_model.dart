import 'package:flutter/material.dart';

class MarkovModel extends ChangeNotifier {
  int _n = 3; // Number of states
  // Initialize with zeros for "empty" feel
  List<List<double>> _matrix = [
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0],
  ];
  int _initialState = 0;
  bool _useInitialVector = true; // Default to vector as requested
  List<double> _initialVector = [1.0, 0.0, 0.0];
  int _startStep = 0;
  int _targetSteps = 5;
  List<double>? _resultVector;
  List<Map<int, List<double>>> _stepHistory = [];
  
  int get n => _n;
  List<List<double>> get matrix => _matrix;
  int get initialState => _initialState;
  bool get useInitialVector => _useInitialVector;
  List<double> get initialVector => _initialVector;
  int get startStep => _startStep;
  int get targetSteps => _targetSteps;
  List<double>? get resultVector => _resultVector;
  List<Map<int, List<double>>> get stepHistory => _stepHistory;

  void setStatesCount(int count) {
    if (count < 2) return;
    _n = count;
    // Resize matrix with zeros
    _matrix = List.generate(
      count,
      (i) => List.generate(count, (j) => 0.0),
    );
    // Resize initial vector
    _initialVector = List.filled(count, 0.0);
    _initialVector[0] = 1.0;
    
    if (_initialState >= count) {
      _initialState = 0;
    }
    notifyListeners();
  }

  void updateMatrixCell(int row, int col, double value) {
    _matrix[row][col] = value;
    notifyListeners();
  }

  void setInitialState(int stateIndex) {
    _initialState = stateIndex;
    // Sync vector
    _initialVector = List.filled(_n, 0.0);
    _initialVector[_initialState] = 1.0;
    notifyListeners();
  }

  void setUseInitialVector(bool useVector) {
    _useInitialVector = useVector;
    notifyListeners();
  }

  void updateInitialVector(int index, double value) {
    _initialVector[index] = value;
    notifyListeners();
  }

  void setStartStep(int step) {
    _startStep = step;
    notifyListeners();
  }

  void setTargetSteps(int steps) {
    _targetSteps = steps;
    notifyListeners();
  }

  void reset() {
    _n = 3;
    _matrix = [
         [0.0, 0.0, 0.0],
         [0.0, 0.0, 0.0],
         [0.0, 0.0, 0.0],
    ];
    _initialState = 0;
    _useInitialVector = true;
    _initialVector = [1.0, 0.0, 0.0];
    _startStep = 0;
    _targetSteps = 5;
    _resultVector = null;
    _stepHistory = [];
    notifyListeners();
  }

  bool validateMatrix() {
    for (var row in _matrix) {
      double sum = row.fold(0.0, (a, b) => a + b);
      if ((sum - 1.0).abs() > 0.001) return false;
    }
    return true;
  }

  bool validateInitialVector() {
    double sum = _initialVector.fold(0.0, (a, b) => a + b);
    return (sum - 1.0).abs() <= 0.001;
  }
  
  // Matrix multiplication helper
  List<List<double>> multiplyMatrices(List<List<double>> a, List<List<double>> b) {
    int n = a.length;
    var result = List.generate(n, (_) => List.filled(n, 0.0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        for (int k = 0; k < n; k++) {
          result[i][j] += a[i][k] * b[k][j];
        }
      }
    }
    return result;
  }

  List<double> multiplyVectorMatrix(List<double> v, List<List<double>> m) {
    int n = v.length;
    var result = List.filled(n, 0.0);
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        result[j] += v[i] * m[i][j];
      }
    }
    return result;
  }

  void calculate() {
    List<double> currentVector = List.from(_initialVector);
    _stepHistory = [];
    
    // Record step t
    _stepHistory.add({_startStep: List.from(currentVector)});

    int stepsToSimulate = _targetSteps - _startStep;
    if (stepsToSimulate < 0) stepsToSimulate = 0;

    for (int i = 1; i <= stepsToSimulate; i++) {
      currentVector = multiplyVectorMatrix(currentVector, _matrix);
      _stepHistory.add({_startStep + i: List.from(currentVector)});
    }
    
    _resultVector = currentVector;
    notifyListeners();
  }
}
