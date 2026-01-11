import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/trainer_service.dart';
import 'trainer_checkout_screen.dart';

class TrainerCheckinScreen extends StatefulWidget {
  final String orderDetailsId;
  final Map<String, dynamic>? jobData;

  const TrainerCheckinScreen({
    super.key,
    required this.orderDetailsId,
    this.jobData,
  });

  @override
  State<TrainerCheckinScreen> createState() => _TrainerCheckinScreenState();
}

class _TrainerCheckinScreenState extends State<TrainerCheckinScreen> {
  final _trainerService = TrainerService();
  bool _isLoading = false;
  Position? _currentPosition;
  String? _address;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  Future<void> _checkin() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location to be determined')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now().toIso8601String();
      await _trainerService.checkin(
        orderDetailsId: widget.orderDetailsId,
        checkinTime: now,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TrainerCheckoutScreen(
              orderDetailsId: widget.orderDetailsId,
              jobData: widget.jobData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking in: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.jobData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.jobData!['serviceName'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Date: ${widget.jobData!['date'] ?? 'N/A'}'),
                      Text('Time: ${widget.jobData!['time'] ?? 'N/A'}'),
                      if (widget.jobData!['address'] != null)
                        Text('Address: ${widget.jobData!['address']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _currentPosition == null
                        ? const Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 8),
                              Text('Getting location...'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Latitude: ${_currentPosition!.latitude}'),
                              Text('Longitude: ${_currentPosition!.longitude}'),
                            ],
                          ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Location'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _currentPosition == null ? null : _checkin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

