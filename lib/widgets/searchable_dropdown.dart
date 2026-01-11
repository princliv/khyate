import 'package:flutter/material.dart';

/// A searchable dropdown widget for selecting items from a large list
class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String? value;
  final List<T> items;
  final String Function(T) displayText;
  final String Function(T) getValue;
  final void Function(String?) onChanged;
  final String? hintText;
  final bool isRequired;
  final IconData? prefixIcon;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.displayText,
    required this.getValue,
    required this.onChanged,
    this.hintText,
    this.isRequired = false,
    this.prefixIcon,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = List<T>.from(widget.items);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = List<T>.from(widget.items);
      _searchController.clear();
    }
  }

  void _filterItems(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List<T>.from(widget.items);
      } else {
        _filteredItems = widget.items.where((item) {
          try {
            final text = widget.displayText(item).toLowerCase();
            return text.contains(query.toLowerCase());
          } catch (e) {
            return false;
          }
        }).toList();
      }
    });
  }

  void _showSearchDialog() {
    if (widget.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ${widget.label.toLowerCase()} available')),
      );
      return;
    }
    
    _searchController.clear();
    _filteredItems = List<T>.from(widget.items);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Search field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.label.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: _filterItems,
                  autofocus: true,
                ),
              ),
              // List of items
              Flexible(
                child: _filteredItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No items found'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          if (index >= _filteredItems.length) {
                            return const SizedBox.shrink();
                          }
                          try {
                            final item = _filteredItems[index];
                            if (item == null) {
                              return const SizedBox.shrink();
                            }
                            final itemValue = widget.getValue(item);
                            final isSelected = widget.value != null && widget.value == itemValue;
                            
                            return ListTile(
                              title: Text(
                                widget.displayText(item),
                                style: const TextStyle(fontSize: 16),
                              ),
                              selected: isSelected,
                              selectedTileColor: Colors.blue.shade50,
                              leading: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.blue, size: 24)
                                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
                              onTap: () {
                                final value = widget.getValue(item);
                                if (value.isNotEmpty) {
                                  widget.onChanged(value);
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                            );
                          } catch (e) {
                            print('Error in searchable dropdown item: $e');
                            return ListTile(
                              title: Text('Error loading item', style: TextStyle(color: Colors.red.shade700)),
                              enabled: false,
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    T? selectedItem;
    try {
      if (widget.items.isNotEmpty && widget.value != null) {
        selectedItem = widget.items.firstWhere(
          (item) => widget.getValue(item) == widget.value,
          orElse: () => widget.items.first,
        );
        // Verify it's actually the selected one
        if (selectedItem != null && widget.getValue(selectedItem) != widget.value) {
          selectedItem = null;
        }
      }
    } catch (e) {
      selectedItem = null;
    }
    
    final displayValue = widget.value != null && selectedItem != null
        ? widget.displayText(selectedItem!)
        : widget.hintText ?? 'Select ${widget.label}';

    return InkWell(
      onTap: _showSearchDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(widget.prefixIcon, color: Colors.grey.shade600),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label + (widget.isRequired ? ' *' : ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.value != null ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

