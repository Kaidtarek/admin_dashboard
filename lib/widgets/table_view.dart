
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

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
