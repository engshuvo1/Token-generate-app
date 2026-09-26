import 'package:flutter/material.dart';

class TokenInputWidget extends StatelessWidget {
  final String prefix;
  final int currentNumber;
  final String selectedDepartment;
  final String counterText;
  final List<String> departments;
  final ValueChanged<String> onPrefixChanged;
  final ValueChanged<int> onNumberChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onCounterChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  const TokenInputWidget({
    super.key,
    required this.prefix,
    required this.currentNumber,
    required this.selectedDepartment,
    required this.counterText,
    required this.departments,
    required this.onPrefixChanged,
    required this.onNumberChanged,
    required this.onDepartmentChanged,
    required this.onCounterChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedNumber = currentNumber.toString().padLeft(3, '0');
    final fullToken = '$prefix-$formattedNumber';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Token Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'TOKEN NUMBER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fullToken,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedDepartment,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Token Number Controls (+, -, Reset)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Counter Sequence',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove),
                      onPressed: currentNumber > 1 ? onDecrement : null,
                      tooltip: 'Previous Token',
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        formattedNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      onPressed: onIncrement,
                      tooltip: 'Next Token',
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      icon: const Icon(Icons.restart_alt),
                      onPressed: onReset,
                      tooltip: 'Reset to 1',
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // Token Prefix Selector
            const Text(
              'Token Prefix',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['A', 'B', 'C', 'D', 'T', 'VIP'].map((p) {
                  final isSelected = prefix == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(p),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) onPrefixChanged(p);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Department Selection
            const Text(
              'Department / Service',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: departments.map((dept) {
                final isSelected = selectedDepartment == dept;
                return FilterChip(
                  label: Text(dept),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onDepartmentChanged(dept);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
