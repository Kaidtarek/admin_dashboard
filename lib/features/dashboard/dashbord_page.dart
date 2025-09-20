import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intersperse/intersperse.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../widgets/widgets.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final Set<String> selectedIds = {};

  void _acceptSelected() async {
    final batch = FirebaseFirestore.instance.batch();

    for (final id in selectedIds) {
      final docRef = FirebaseFirestore.instance.collection('products').doc(id);
      batch.update(docRef, {'accepted': true});
    }

    try {
      await batch.commit();
      setState(() {
        selectedIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected items have been accepted ")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating: $e")),
      );
    }
  }

  Future<Map<String, dynamic>> _getSummaryData() async {
    double totalSales = 0;
    int acceptedCount = 0;
    int totalProducts = 0;

    final productsSnap =
        await FirebaseFirestore.instance.collection('products').get();

    totalProducts = productsSnap.docs.length;

    for (var doc in productsSnap.docs) {
      final data = doc.data();
      final priceRaw = data['price'] ?? 0;
      final price = priceRaw is num
          ? priceRaw.toDouble()
          : double.tryParse(priceRaw.toString()) ?? 0.0;
      final accepted = data['accepted'] ?? false;

      if (accepted == true) {
        totalSales += price;
        acceptedCount++;
      }
    }

    final usersSnap =
        await FirebaseFirestore.instance.collection('users').get();
    final totalUsers = usersSnap.docs.length;

    final acceptedRate =
        totalProducts == 0 ? 0 : (acceptedCount / totalProducts) * 100;

    return {
      'totalSales': totalSales,
      'totalUsers': totalUsers,
      'acceptedRate': acceptedRate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return ContentView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Dashboard',
            description: 'A summary of key data and insights on your project.',
          ),
          const Gap(16),

          FutureBuilder<Map<String, dynamic>>(
            future: _getSummaryData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!;
              final summaryCards = [
                SummaryCard(
                  title: 'Total Sales',
                  value: '\$${data['totalSales'].toStringAsFixed(2)}',
                ),
                SummaryCard(
                  title: 'Total Users',
                  value: data['totalUsers'].toString(),
                ),
                SummaryCard(
                  title: 'Accepted Products Rate',
                  value: '${data['acceptedRate'].toStringAsFixed(1)}%',
                ),
              ];

              if (responsive.isMobile) {
                return Column(children: summaryCards);
              } else {
                return Row(
                  children: summaryCards
                      .map<Widget>((card) => Expanded(child: card))
                      .intersperse(const Gap(16))
                      .toList(),
                );
              }
            },
          ),

          const Gap(16),

          Expanded(
            child: _TableView(
              selectedIds: selectedIds,
              onToggleSelection: (id) {
                setState(() {
                  if (selectedIds.contains(id)) {
                    selectedIds.remove(id);
                  } else {
                    selectedIds.add(id);
                  }
                });
              },
            ),
          ),

          const Gap(12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: selectedIds.isEmpty ? null : _acceptSelected,
              icon: const Icon(Icons.send),
              label: const Text("Accept"),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableView extends StatelessWidget {
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelection;

  const _TableView({
    required this.selectedIds,
    required this.onToggleSelection,
  });

  bool _isAcceptedFalse(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val == false;
    return val.toString().toLowerCase() == 'false';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('accepted', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading products"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No unaccepted products found"));
        }

        return Card(
          clipBehavior: Clip.antiAlias,
          child: TableView.builder(
            columnCount: 9 + 1,
            rowCount: docs.length + 1,
            pinnedRowCount: 1,
            pinnedColumnCount: 1,
            columnBuilder: (index) {
              return TableSpan(
                extent: const FractionalTableSpanExtent(1 / 8),
              );
            },
            rowBuilder: (index) {
              return TableSpan(
                extent: const FixedTableSpanExtent(50),
              );
            },
            cellBuilder: (context, vicinity) {
              final isHeader = vicinity.yIndex == 0;
              final isCheckboxCol = vicinity.xIndex == 0;

              if (isHeader) {
                final headers = [
                  "✔",
                  'Name',
                  'Category',
                  'Price',
                  'Quantity',
                  'Unit',
                  'Description',
                  'Owner ID',
                  'Accepted',
                  'Created At',
                ];
                return TableViewCell(
                  child: Center(
                    child: Text(
                      headers[vicinity.xIndex],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }

              final doc = docs[vicinity.yIndex - 1];
              final data = doc.data() as Map<String, dynamic>;

              if (isCheckboxCol) {
                return TableViewCell(
                  child: Checkbox(
                    value: selectedIds.contains(doc.id),
                    onChanged: (_) => onToggleSelection(doc.id),
                  ),
                );
              } else {
                final fields = [
                  data['name']?.toString() ?? '',
                  data['category']?.toString() ?? '',
                  data['price']?.toString() ?? '',
                  data['quantity']?.toString() ?? '',
                  data['unit']?.toString() ?? '',
                  data['description']?.toString() ?? '',
                  data['ownerId']?.toString() ?? '',
                  _isAcceptedFalse(data['accepted']) ? "No" : "Yes",
                  (data['createdAt'] != null)
                      ? (data['createdAt'] as Timestamp).toDate().toString()
                      : '',
                ];

                return TableViewCell(
                  child: Center(
                    child: Text(
                      fields[vicinity.xIndex - 1],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
