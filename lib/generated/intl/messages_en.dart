// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "chooseFiles": MessageLookupByLibrary.simpleMessage("Choose files"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "dropFilesHere": MessageLookupByLibrary.simpleMessage("Drop files here"),
    "dropFilesOrUseButtonBelow": MessageLookupByLibrary.simpleMessage(
      "Drop files or use button below",
    ),
    "dropFilesToAddMedia": MessageLookupByLibrary.simpleMessage(
      "Drop files to add media",
    ),
    "failedToPickFilesE": MessageLookupByLibrary.simpleMessage(
      "Failed to pick files: \$e",
    ),
    "loadingError": MessageLookupByLibrary.simpleMessage("Loading error"),
    "maximumWidgetmaxselectionFilesAllowed":
        MessageLookupByLibrary.simpleMessage(
          "Maximum \${widget.maxSelection} files allowed",
        ),
    "noMedia": MessageLookupByLibrary.simpleMessage("No media"),
    "noMediaAvailable": MessageLookupByLibrary.simpleMessage(
      "No media available",
    ),
    "noMediaFiles": MessageLookupByLibrary.simpleMessage("No media files"),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permission denied",
    ),
    "selectMedia": MessageLookupByLibrary.simpleMessage("Select Media"),
    "thereAreNoAvailableImages": MessageLookupByLibrary.simpleMessage(
      "There are no available images",
    ),
  };
}
