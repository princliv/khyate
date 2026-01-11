import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/trainer_service.dart';
import 'trainer_checkin_screen.dart';

class TrainerAssignedJobsScreen extends StatefulWidget {
  const TrainerAssignedJobsScreen({super.key});

  @override
  State<TrainerAssignedJobsScreen> createState() => _TrainerAssignedJobsScreenState();
}

class _TrainerAssignedJobsScreenState extends State<TrainerAssignedJobsScreen> {
  final _trainerService = TrainerService();
  List<dynamic> _jobs = [];
  bool _isLoading = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final result = await _trainerService.getAllAssignedJobs(
        page: 1,
        limit: 50,
        status: _selectedStatus,
      );
      setState(() {
        _jobs = result?['jobs'] ?? result?['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading jobs: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Jobs'),
        actions: [
          DropdownButton<String>(
            value: _selectedStatus,
            hint: const Text('Filter'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
              DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
              _loadJobs();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? const Center(child: Text('No jobs assigned'))
              : RefreshIndicator(
                  onRefresh: _loadJobs,
                  child: ListView.builder(
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(job['serviceName'] ?? 'Service'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${job['date'] ?? 'N/A'}'),
                              Text('Time: ${job['time'] ?? 'N/A'}'),
                              Text('Status: ${job['status'] ?? 'N/A'}'),
                              if (job['customerName'] != null)
                                Text('Customer: ${job['customerName']}'),
                            ],
                          ),
                          trailing: job['status'] == 'assigned'
                              ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TrainerCheckinScreen(
                                          orderDetailsId: job['orderDetailsId'] ?? job['_id'] ?? '',
                                          jobData: job,
                                        ),
                                      ),
                                    ).then((_) => _loadJobs());
                                  },
                                  child: const Text('Check-in'),
                                )
                              : null,
                          onTap: () {
                            // Show job details
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(job['serviceName'] ?? 'Job Details'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Status: ${job['status'] ?? 'N/A'}'),
                                      Text('Date: ${job['date'] ?? 'N/A'}'),
                                      Text('Time: ${job['time'] ?? 'N/A'}'),
                                      if (job['address'] != null)
                                        Text('Address: ${job['address']}'),
                                      if (job['notes'] != null)
                                        Text('Notes: ${job['notes']}'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

