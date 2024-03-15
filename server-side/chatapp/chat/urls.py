from django.urls import path,include
from chat import views

urlpatterns=[
    path('send_message/', views.send_message, name='send_message'),
    path('chatrooms/', views.UserChatRoomsAPIView.as_view(), name='user_chat_rooms'),
]
