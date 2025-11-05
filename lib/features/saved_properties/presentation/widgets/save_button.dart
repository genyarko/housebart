import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/saved_property_bloc.dart';
import '../bloc/saved_property_event.dart';
import '../bloc/saved_property_state.dart';

class SaveButton extends StatelessWidget {
  final String propertyId;
  final bool isLarge;

  const SaveButton({
    super.key,
    required this.propertyId,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedPropertyBloc, SavedPropertyState>(
      builder: (context, state) {
        bool isSaved = false;

        if (state is SavedPropertyLoaded) {
          isSaved = state.savedStatusCache[propertyId] ?? false;
        }

        if (isLarge) {
          return ElevatedButton.icon(
            onPressed: () {
              context.read<SavedPropertyBloc>().add(
                    ToggleSaveProperty(propertyId: propertyId),
                  );
            },
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
            label: Text(isSaved ? 'Saved' : 'Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
          );
        }

        return IconButton(
          onPressed: () {
            context.read<SavedPropertyBloc>().add(
                  ToggleSaveProperty(propertyId: propertyId),
                );
          },
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: isSaved ? 'Remove from saved' : 'Save property',
        );
      },
    );
  }
}
