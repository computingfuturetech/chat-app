from django.db import models
from django.contrib.auth.models import User
from django.conf import settings
import os
import uuid

def user_voicemessages_path(instance, filename):
    unique_filename = f"chatbox_{uuid.uuid4().hex}"
    _, file_extension = os.path.splitext(filename)
    new_filename = f"{unique_filename}{file_extension}"
    return os.path.join('store/voice_messages', new_filename)

def user_image_path(instance, filename):
    unique_filename = f"chatbox_{uuid.uuid4().hex}"
    _, file_extension = os.path.splitext(filename)
    new_filename = f"{unique_filename}{file_extension}"
    return os.path.join('store/chat/images', new_filename)

def user_document_path(instance, filename):
    unique_filename = f"chatbox{uuid.uuid4().hex}"
    file_name = os.path.basename(filename)
    new_filename = f"{unique_filename}-{file_name}"
    return os.path.join('store/documents', new_filename)

def user_media_path(instance, filename):
    unique_filename = f"chatbox_{uuid.uuid4().hex}"
    _, file_extension = os.path.splitext(filename)
    new_filename = f"{unique_filename}{file_extension}"
    return os.path.join('store/media', new_filename)

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
    message = models.TextField(blank=True, null=True)
    audio_file = models.FileField(upload_to=user_voicemessages_path, blank=True, null=True)
    image = models.ImageField(upload_to=user_image_path, blank=True, null=True)
    document = models.FileField(upload_to=user_document_path, blank=True, null=True)
    media=models.FileField(upload_to=user_media_path,blank=True,null=True)
    timestamp = models.TimeField(auto_now_add=True)
    datestamp = models.DateField(auto_now_add=True)

    def __str__(self):
        return f'ChatMessage - {self.user.username}: {self.message}'


class AiModel(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    chat = models.ForeignKey(ChatRoom, on_delete=models.SET_NULL, null=True)
    request=models.TextField(blank=True, null=True)
    response=models.TextField(blank=True, null=True)
    timestamp = models.TimeField(auto_now_add=True)
    datestamp = models.DateField(auto_now_add=True)