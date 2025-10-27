import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_driver/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_driver/modules/chat/models/conversation.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (uid.isNotEmpty) {
      context.read<ChatCubit>().loadConversations(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: BlocBuilder<ChatCubit, dynamic>(
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ConversationsLoaded) {
            final list = state.conversations;
            if (list.isEmpty) return Center(child: Text('No conversations yet'));
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final Conversation conv = list[index];
                final other = conv.participants.firstWhere((e) => e != uid, orElse: () => 'Unknown');
                return ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('User: $other'),
                  subtitle: Text(conv.lastMessage ?? ''),
                  trailing: Text(_formatTime(conv.lastUpdated)),
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(child: Text('Start a conversation'));
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.year}/${dt.month}/${dt.day}';
  }
}
