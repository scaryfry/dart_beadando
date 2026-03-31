import 'dart:async';
import 'package:flutter/material.dart';

enum VisualType { bars, dots, circle }
enum SortAlgo { bubble, selection, insertion, quick }

class SortStats {
  int comparisons = 0;
  int swaps = 0;
  int startTime = 0;
  int elapsedTimeMs = 0;
  
  void reset() {
    comparisons = 0;
    swaps = 0;
    elapsedTimeMs = 0;
    startTime = DateTime.now().millisecondsSinceEpoch;
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