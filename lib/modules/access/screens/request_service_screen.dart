import 'package:flutter/material.dart';

import '../widgets/shared.dart';

class RequestServiceScreen extends StatefulWidget {
  const RequestServiceScreen({super.key});

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsCtrl = TextEditingController();
  String _category = 'General';
  bool _urgent = false;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request submitted for $_category')),
    );
    _detailsCtrl.clear();
    setState(() {
      _urgent = false;
      _category = 'General';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: const [
            LogoBadge(size: 30, elevation: false),
            SizedBox(width: 10),
            Text('Request Service'),
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0.85),
        foregroundColor: Colors.black,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: RibbonMarker())],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Submit a service request', style: appTextStyle(weight: FontWeight.w700, size: 20)),
                  const Spacer(),
                  const BadgeChip(label: 'Avg. 2h response', icon: Icons.speed, color: Colors.teal),
                ],
              ),
              const SizedBox(height: 14),
              FrostedCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'General', child: Text('General')),
                        DropdownMenuItem(value: 'IT Support', child: Text('IT Support')),
                        DropdownMenuItem(value: 'Facilities', child: Text('Facilities')),
                        DropdownMenuItem(value: 'HR', child: Text('HR')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _detailsCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Details',
                        hintText: 'Describe your request',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter details';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mark as urgent'),
                      value: _urgent,
                      onChanged: (val) => setState(() => _urgent = val),
                      secondary: Icon(Icons.flash_on, color: _urgent ? Colors.orange : Colors.grey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

