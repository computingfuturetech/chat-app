from django.urls import path,include
from chat import views

urlpatterns=[
    path('send_message/', views.send_message, name='send_message'),
    path('create_chat_room/', views.create_chat_room, name='create_chat_room'),
]
