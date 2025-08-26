import 'package:flutter/material.dart';
import 'package:minsellprice/services/work_manager_service.dart';
import 'package:minsellprice/core/utils/constants/colors.dart';

class WorkManagerStatusWidget extends StatefulWidget {
  const WorkManagerStatusWidget({super.key});

  @override
  State<WorkManagerStatusWidget> createState() =>
      _WorkManagerStatusWidgetState();
}

class _WorkManagerStatusWidgetState extends State<WorkManagerStatusWidget> {
  bool isWorkManagerRunning = false;
  DateTime? lastApiExecution;
  DateTime? nextApiExecution;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      final isRunning = await WorkManagerService.isTaskRunning();
      final lastExecution = await WorkManagerService.getLastExecutionTime();
      final nextExecution = await WorkManagerService.getNextExecutionTime();

      if (mounted) {
        setState(() {
          isWorkManagerRunning = isRunning;
          lastApiExecution = lastExecution;
          nextApiExecution = nextExecution;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading API status...'),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isWorkManagerRunning ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isWorkManagerRunning ? Icons.sync : Icons.sync_disabled,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Background API Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          isWorkManagerRunning
                              ? 'Active - Running every 5 minutes'
                              : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: isWorkManagerRunning
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _checkStatus,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Status',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status Details
              if (isWorkManagerRunning) ...[
                _buildStatusRow(
                  'Last Execution',
                  lastApiExecution != null
                      ? _formatDateTime(lastApiExecution!)
                      : 'Never',
                  Icons.access_time,
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  'Next Execution',
                  nextApiExecution != null
                      ? _formatDateTime(nextApiExecution!)
                      : 'Unknown',
                  Icons.schedule,
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  'API Endpoint',
                  'growth.matridtech.net',
                  Icons.link,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Background service is not running. API calls will not be made automatically.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isWorkManagerRunning
                          ? () async {
                              await WorkManagerService.stopPeriodicTask();
                              await _checkStatus();
                            }
                          : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Service'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isWorkManagerRunning
                          ? null
                          : () async {
                              await WorkManagerService.startPeriodicTask();
                              await Future.delayed(const Duration(seconds: 2));
                              await _checkStatus();
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
