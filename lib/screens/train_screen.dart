import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teman_asa/theme.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});
  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  double prog = 0.0;
  Timer? t;
  void start() { t = Timer.periodic(const Duration(milliseconds: 50), (_) { setState(() { prog += 0.01; if(prog >= 1) { t?.cancel(); prog=1; } }); }); }
  void stop() { t?.cancel(); setState(() { prog = 0; }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Latihan Fokus")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Tekan & Tahan", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 40),
            GestureDetector(
              onTapDown: (_) => start(), 
              onTapUp: (_) => stop(), 
              child: Container(
                width: 220, 
                height: 220, 
                decoration: BoxDecoration(
                  color: kAccentCoral, 
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: kAccentCoral.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)]
                ), 
                child: const Center(child: Text("TAHAN", style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'NerkoOne')))
              )
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: LinearProgressIndicator(value: prog, minHeight: 20, borderRadius: BorderRadius.circular(10), color: kMainTeal, backgroundColor: Colors.white),
            )
          ],
        )
      ),
    );
  }
}