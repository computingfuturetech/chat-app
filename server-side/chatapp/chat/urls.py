from django.urls import path,include
from chat import views

urlpatterns=[
    path('chatrooms/', views.UserChatRoomsAPIView.as_view(), name='user_chat_rooms'),
    path('chatrooms/ai/', views.UserAiChatRoomsAPIView.as_view(), name='user_chat_rooms'),
    path('chats', views.ChatRoomView.as_view(), name='chatRoom'),
	path('chats/<str:roomId>/messages', views.MessagesView.as_view(), name='messageList'),
	path('users/<int:userId>/chats', views.ChatRoomView.as_view(), name='chatRoomList'),
]
