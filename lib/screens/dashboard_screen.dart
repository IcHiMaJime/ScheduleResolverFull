import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);

    final sortedTasks = List<TaskModel>.from(scheduleProvider.tasks);
    sortedTasks.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50, // Subtle blue background
      appBar: AppBar(
        title: const Text('Schedule Resolver', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.lightBlue.shade800,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // AI Recommendation Banner (Modernized)
            if (aiService.currentAnalysis != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.lightBlue.shade300]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI Optimization Ready', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('View your updated timeline.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendationScreen())),
                        child: const Text('View', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),

            // Task List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('${sortedTasks.length} Tasks', style: TextStyle(color: Colors.blue.shade700)),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: sortedTasks.isEmpty
                  ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.blue.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No tasks added yet!', style: TextStyle(color: Colors.grey)),
                ],
              ))
                  : ListView.builder(
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  final String hour = task.startTime.hour.toString().padLeft(2, '0');
                  final String minute = task.startTime.minute.toString().padLeft(2, '0');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.lightBlue.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.access_time, color: Colors.blue.shade700),
                      ),
                      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${task.category} • $hour:$minute", style: TextStyle(color: Colors.blueGrey.shade600)),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => scheduleProvider.removerTasks(task.id)),
                    ),
                  );
                },
              ),
            ),

            // AI Action Button
            if (sortedTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: aiService.isLoading ? null : () => aiService.analyzeSchedule(scheduleProvider.tasks),
                    icon: aiService.isLoading ? const SizedBox.shrink() : const Icon(Icons.bolt),
                    label: aiService.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Resolve Conflicts With AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskInputScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}