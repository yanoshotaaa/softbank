import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoreReservationScreen extends StatefulWidget {
  const StoreReservationScreen({super.key});

  @override
  State<StoreReservationScreen> createState() => _StoreReservationScreenState();
}

class _StoreReservationScreenState extends State<StoreReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedStore;
  String? _selectedService;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  final List<Map<String, dynamic>> _stores = [
    {
      'name': '新宿店',
      'address': '東京都新宿区新宿3-1-1',
      'hours': '10:00-20:00',
      'services': ['機種変更', 'プラン変更', '故障対応', '新規契約'],
    },
    {
      'name': '渋谷店',
      'address': '東京都渋谷区渋谷2-1-1',
      'hours': '10:00-20:00',
      'services': ['機種変更', 'プラン変更', '故障対応', '新規契約'],
    },
    {
      'name': '池袋店',
      'address': '東京都豊島区池袋1-1-1',
      'hours': '10:00-20:00',
      'services': ['機種変更', 'プラン変更', '故障対応', '新規契約'],
    },
  ];

  final List<String> _services = [
    '機種変更',
    'プラン変更',
    '故障対応',
    '新規契約',
    'その他',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showStoreDetails(Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStoreDetailRow(Icons.location_on, store['address']),
            _buildStoreDetailRow(Icons.access_time, store['hours']),
            const SizedBox(height: 16),
            const Text(
              '対応サービス',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (store['services'] as List<String>).map((service) {
                return Chip(
                  label: Text(service),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedStore = store['name'];
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('この店舗を選択'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReservation() {
    if (_formKey.currentState!.validate()) {
      // 予約情報の処理
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('予約完了'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('店舗: $_selectedStore'),
              Text(
                  '日時: ${DateFormat('yyyy年MM月dd日').format(_selectedDate!)} ${_selectedTime!.format(context)}'),
              Text('サービス: $_selectedService'),
              Text('お名前: ${_nameController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店舗予約'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 店舗選択セクション
                const Text(
                  '店舗を選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStore,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('店舗を選択してください'),
                      items: _stores.map((store) {
                        return DropdownMenuItem<String>(
                          value: store['name'],
                          child: Row(
                            children: [
                              const Icon(Icons.store, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(store['name']),
                                    Text(
                                      store['address'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => _showStoreDetails(store),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStore = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 日時選択セクション
                const Text(
                  '日時を選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? '日付を選択'
                              : DateFormat('yyyy年MM月dd日')
                                  .format(_selectedDate!),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _selectedTime == null
                              ? '時間を選択'
                              : _selectedTime!.format(context),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // サービス選択セクション
                const Text(
                  'サービスを選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedService,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('サービスを選択してください'),
                      items: _services.map((service) {
                        return DropdownMenuItem<String>(
                          value: service,
                          child: Text(service),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // お客様情報セクション
                const Text(
                  'お客様情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'お名前',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'お名前を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '電話番号',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '電話番号を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    if (!value.contains('@')) {
                      return '有効なメールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: '備考',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // 予約ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitReservation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '予約を確定する',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
