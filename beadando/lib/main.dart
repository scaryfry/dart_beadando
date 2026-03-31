import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sort_provider.dart';
import 'sorting_painter.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => SortProvider(),
        child: const SortingVisualizerApp(),
      ),
    );

class SortingVisualizerApp extends StatelessWidget {
  const SortingVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SortProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: p.isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SortProvider>();
    final accentColor = p.isDarkMode ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PRÉMIUM NAVBAR
            _buildNavbar(context, p),

            // GRID VIEW - ALGORITMUS KÁRTYÁK
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12),
                childAspectRatio: 0.85,
                children: p.instances.map((inst) => _buildAlgoCard(inst, p, accentColor)).toList(),
              ),
            ),

            // ALSÓ VEZÉRLŐPANEL
            _buildBottomPanel(context, p),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, SortProvider p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const Text("ALGO-PRO", style: TextStyle( fontSize: 22, letterSpacing: -1.2)),
          const Spacer(),
          DropdownButton<VisualType>(
            value: p.visualType,
            underline: const SizedBox(),
            onChanged: (v) => p.setVisual(v!),
            items: VisualType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(p.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round_outlined),
            onPressed: () => p.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgoCard(AlgoInstance inst, SortProvider p, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(inst.algo.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${inst.stats.elapsedTimeMs}ms", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomPaint(painter: SortingPainter(inst, p.visualType, color), size: Size.infinite),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text("C: ${inst.stats.comparisons} | S: ${inst.stats.swaps}", 
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, SortProvider p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: p.isRunning ? null : () => p.startAll(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text("INDÍTÁS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              FloatingActionButton.large(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                onPressed: () => p.resetAll(),
                child: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 22, color: Colors.grey),
              Expanded(
                child: Slider(
                  // LOGIKA: Jobbra húzva gyorsabb (kisebb késleltetés)
                  value: 201 - p.speedDelay, 
                  min: 1, max: 200,
                  activeColor: Colors.greenAccent[400],
                  onChanged: (v) => p.speedDelay = 201 - v,
                ),
              ),
              const Text("GYORSASÁG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}