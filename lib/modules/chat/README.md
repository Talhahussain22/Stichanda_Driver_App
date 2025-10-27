[//]: # (Chat module)

[//]: # ()
[//]: # (How to use:)

[//]: # ()
[//]: # (- Provide ChatCubit at an appropriate scope, for example in `main.dart` where other cubits are provided:)

[//]: # ()
[//]: # (```dart)

[//]: # (BlocProvider&#40;)

[//]: # (  create: &#40;_&#41; => ChatCubit&#40;ChatRepository&#40;&#41;&#41;,)

[//]: # (&#41;,)

[//]: # (```)

[//]: # ()
[//]: # (- Navigate to `ConversationsScreen&#40;&#41;` to list conversations. Chat uses Firestore collections:)

[//]: # (  - `conversations` documents with fields `participants` &#40;array of uids&#41;, `last_message`, `last_updated`)

[//]: # (  - subcollection `conversations/{conversationId}/messages` with documents having `sender_id`, `text`, `type`, `timestamp`, `read_by`)

[//]: # ()
[//]: # (Notes:)

[//]: # (- Conversation id is deterministic and built by sorting both user ids and joining with `_`. This allows `createOrGetConversation` to return the existing doc.)

[//]: # (- Messages are loaded in descending order &#40;newest first&#41; and UI reverses the list to show newest at bottom.)

[//]: # (- This module is intentionally minimal and focuses on one-to-one chat. You can extend it for typing indicators, presence, attachments etc.)

[//]: # ()
