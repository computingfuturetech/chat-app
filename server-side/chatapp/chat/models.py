from django.db import models
from django.contrib.auth.models import User
from django.conf import settings

class ChatRoom(models.Model):
    ONE_TO_ONE = 'one_to_one'
    GROUP = 'group'

    CHAT_TYPE_CHOICES = [
        (ONE_TO_ONE, 'One to One'),
        (GROUP, 'Group'),
    ]
    chat_room_id = models.CharField(max_length=100, unique=True)
    chat_type = models.CharField(max_length=20, choices=CHAT_TYPE_CHOICES, default='one_to_one')
    member_count = models.PositiveIntegerField(default=0)
    members = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='chat_rooms')
    def __str__(self):
        return self.chat_room_id


class ChatMessage(models.Model):
    chat = models.ForeignKey(ChatRoom, on_delete=models.SET_NULL, null=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    message = models.CharField(max_length=255)
    
    timestamp = models.TimeField(auto_now_add=True)
    datestamp = models.DateField(auto_now_add=True)

    def __str__(self):
        return self.message
