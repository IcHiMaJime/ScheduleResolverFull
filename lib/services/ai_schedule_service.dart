import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/schedule_analysis.dart';
import '../models/task_model.dart';

class AiScheduleService extends ChangeNotifier{
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading; //


  final String _apiKey ='';

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || tasks.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final tasksJson = jsonEncode(tasks.map((t)=> t.toJson()).toList());
      final prompt =
          ''' 
          You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format $tasksJson
          
          Please provide exactly 4 sections of markdown text:
          
          1. ### Detected Conflicts
          List any scheduling conflicts
          2. ### Ranked Tasks
          Rank with tasks need attention first
          3. ### Recommended Schedule
          Provide a revised daily timeline view adjusting the task time.
          4. ### Explanation
          Explain why this Recommendation was made.
          ''';
      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');
    } catch (e) {
      _errorMessage = 'Failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "No conflicts found.",
      rankedTasks = "No ranking available.",
      recommendedSchedule = "No schedule generated.",
      explanation = "No explanation provided.";

    final sections = fullText.split('### ');
    for (var section in sections ) {
      if (section.startsWith('Detected Conflicts')) conflicts = section.replaceFirst('Detected Conflicts', '').trim();
      else if (section.startsWith('Ranked Tasks')) rankedTasks = section.replaceFirst('Ranked Tasks', '').trim();
      else if (section.startsWith('Recommended Schedule')) recommendedSchedule = section.replaceFirst('Recommended Schedule', '').trim();
      else if (section.startsWith('Explanation')) explanation = section.replaceFirst('Explanation', '').trim();
    }


    return ScheduleAnalysis(
        conflicts: conflicts,
        rankedTasks: rankedTasks,
        recommendedSchedule: recommendedSchedule,
        explanation: explanation
    );
  }
}