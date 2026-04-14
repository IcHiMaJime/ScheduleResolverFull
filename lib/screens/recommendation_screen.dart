import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis = aiService.currentAnalysis;

    if (analysis == null) return const Scaffold(body: Center(child: Text('No Data')));

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('AI Insights'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSection(context, 'Detected Conflicts', analysis.conflicts, Colors.red.shade50, Icons.warning_amber_rounded, Colors.red.shade700),
            const SizedBox(height: 16),
            _buildSection(context, 'Ranked Tasks', analysis.rankedTasks, Colors.white, Icons.format_list_numbered, Colors.blue.shade700),
            const SizedBox(height: 16),
            _buildSection(context, 'Recommended Schedule', analysis.recommendedSchedule, Colors.white, Icons.calendar_today, Colors.green.shade700),
            const SizedBox(height: 16),
            _buildSection(context, 'The Strategy', analysis.explanation, Colors.blue.shade100, Icons.lightbulb_outline, Colors.blue.shade900),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, Color bgColor, IconData icon, Color accentColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: accentColor),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Text(
                content.replaceAll('*', ''),
                style: TextStyle(fontSize: 15, height: 1.6, color: Colors.blueGrey.shade800)
            ),
          ],
        ),
      ),
    );
  }
}