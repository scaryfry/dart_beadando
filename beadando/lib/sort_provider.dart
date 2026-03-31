import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum VisualType { bars, dots, circle }
enum SortAlgo { bubble, quick, selection, insertion }

class SortStats {
  int comparisons = 0;
  int swaps = 0;
  int startTime = 0;
  int elapsedTimeMs = 0;

  void reset() {
    comparisons = 0;
    swaps = 0;
    startTime = DateTime.now().millisecondsSinceEpoch;
    elapsedTimeMs = 0;
  }

  void updateTime() {
    elapsedTimeMs = DateTime.now().millisecondsSinceEpoch - startTime;
  }
}

class AlgoInstance {
  final SortAlgo algo;
  List<int> data;
  SortStats stats = SortStats();
  int? active1, active2;
  bool isComplete = false;
  

  AlgoInstance(this.algo, List<int> source) : data = List.from(source);
}

class SortProvider with ChangeNotifier {
  List<AlgoInstance> instances = [];
  List<int> masterData = [];
  int arraySize = 40;
  double speedDelay = 100; 
  VisualType visualType = VisualType.bars;
  bool isRunning = false;
  bool isDarkMode = true;

  SortProvider() { resetAll(); }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void resetAll() {
    isRunning = false;
    masterData = List.generate(arraySize, (i) => Random().nextInt(300) + 10);
    instances = [
      AlgoInstance(SortAlgo.bubble, masterData),
      AlgoInstance(SortAlgo.quick, masterData),
      AlgoInstance(SortAlgo.selection, masterData),
      AlgoInstance(SortAlgo.insertion, masterData),
    ];
    notifyListeners();
  }

  void setVisual(VisualType type) {
    visualType = type;
    notifyListeners();
  }

  Future<void> _wait(AlgoInstance inst) async {
    inst.stats.updateTime();
    notifyListeners();
    await Future.delayed(Duration(milliseconds: speedDelay.toInt()));
  }

  Future<void> startAll() async {
    if (isRunning) return;
    isRunning = true;
    await Future.wait([
      _bubbleSort(instances[0]),
      _quickSort(instances[1], 0, instances[1].data.length - 1),
      _selectionSort(instances[2]),
      _insertionSort(instances[3]),
    ]);
    isRunning = false;
    notifyListeners();
  }

  // --- Algoritmus Implementációk ---
  Future<void> _bubbleSort(AlgoInstance inst) async {
    inst.stats.reset();
    int n = inst.data.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (!isRunning) return;
        inst.active1 = j; inst.active2 = j + 1;
        inst.stats.comparisons++;
        if (inst.data[j] > inst.data[j + 1]) {
          int temp = inst.data[j];
          inst.data[j] = inst.data[j + 1];
          inst.data[j + 1] = temp;
          inst.stats.swaps++;
        }
        await _wait(inst);
      }
    }
    inst.isComplete = true;
    _cleanup(inst);
  }

  Future<void> _selectionSort(AlgoInstance inst) async {
    inst.stats.reset();
    int n = inst.data.length;
    for (int i = 0; i < n - 1; i++) {
      int minIdx = i;
      for (int j = i + 1; j < n; j++) {
        if (!isRunning) return;
        inst.active1 = i; inst.active2 = j;
        inst.stats.comparisons++;
        if (inst.data[j] < inst.data[minIdx]) minIdx = j;
        await _wait(inst);
      }
      int temp = inst.data[i];
      inst.data[i] = inst.data[minIdx];
      inst.data[minIdx] = temp;
      inst.stats.swaps++;
    }
    inst.isComplete = true;
    _cleanup(inst);
  }

  Future<void> _insertionSort(AlgoInstance inst) async {
    inst.stats.reset();
    int n = inst.data.length;
    for (int i = 1; i < n; i++) {
      int key = inst.data[i];
      int j = i - 1;
      while (j >= 0 && inst.data[j] > key) {
        if (!isRunning) return;
        inst.active1 = i; inst.active2 = j;
        inst.stats.comparisons++;
        inst.data[j + 1] = inst.data[j];
        j--;
        inst.stats.swaps++;
        await _wait(inst);
      }
      inst.data[j + 1] = key;
    }
    inst.isComplete = true;
    _cleanup(inst);
  }

  Future<void> _quickSort(AlgoInstance inst, int low, int high) async {
    if (low == 0 && high == inst.data.length - 1) inst.stats.reset();
    if (low < high) {
      int pivotIdx = await _partition(inst, low, high);
      await _quickSort(inst, low, pivotIdx - 1);
      await _quickSort(inst, pivotIdx + 1, high);
    }
    if (low == 0 && high == inst.data.length - 1) {
      inst.isComplete = true;
      _cleanup(inst);
    }
  }

  Future<int> _partition(AlgoInstance inst, int low, int high) async {
    int pivot = inst.data[high];
    int i = low - 1;
    for (int j = low; j < high; j++) {
      if (!isRunning) break;
      inst.active1 = j; inst.active2 = high;
      inst.stats.comparisons++;
      if (inst.data[j] < pivot) {
        i++;
        int temp = inst.data[i];
        inst.data[i] = inst.data[j];
        inst.data[j] = temp;
        inst.stats.swaps++;
      }
      await _wait(inst);
    }
    int temp = inst.data[i + 1];
    inst.data[i + 1] = inst.data[high];
    inst.data[high] = temp;
    inst.stats.swaps++;
    return i + 1;
  }

  void _cleanup(AlgoInstance inst) {
    inst.active1 = null; inst.active2 = null;
    notifyListeners();
  }
}