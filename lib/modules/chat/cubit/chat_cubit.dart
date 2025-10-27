import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stichanda_driver/modules/chat/models/chat_message.dart';
import 'package:stichanda_driver/modules/chat/models/conversation.dart';
import 'package:stichanda_driver/modules/chat/repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repo;
  StreamSubscription<List<Conversation>>? _convSub;
  StreamSubscription<List<ChatMessage>>? _msgSub;

  ChatCubit(this._repo) : super(ChatInitial());

  void loadConversations(String uid) {
    emit(ConversationsLoading());
    _convSub?.cancel();
    _convSub = _repo.conversationStream(uid).listen((list) {
      emit(ConversationsLoaded(list));
    }, onError: (e) {
      emit(ChatError(e.toString()));
    });
  }

  Future<Conversation> startConversation(String me, String other) async {
    final conv = await _repo.createOrGetConversation(me, other);
    return conv;
  }

  void subscribeMessages(String conversationId) {
    emit(MessagesLoading());
    _msgSub?.cancel();
    _msgSub = _repo.messageStream(conversationId).listen((messages) {
      emit(MessagesLoaded(messages));
    }, onError: (e) {
      emit(ChatError(e.toString()));
    });
  }

  Future<void> sendMessage(String conversationId, ChatMessage message) async {
    try {
      await _repo.sendMessage(conversationId, message);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> markRead(String conversationId, String messageId, String uid) async {
    try {
      await _repo.markMessageRead(conversationId, messageId, uid);
    } catch (e) {
      // ignore
    }
  }

  @override
  Future<void> close() {
    _convSub?.cancel();
    _msgSub?.cancel();
    return super.close();
  }
}

