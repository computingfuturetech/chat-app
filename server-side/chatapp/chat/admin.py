from django.contrib import admin
from .models import ChatRoom, ChatMessage, AiModel,UserConnectedStatus

@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ['chat_room_id','chat_type', 'member_count']
    filter_horizontal = ['members']  

@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ['chat', 'user', 'message', 'audio_file','media','document','image', 'timestamp', 'datestamp']

@admin.register(AiModel)
class AiModelAdmin(admin.ModelAdmin):
    list_display = ['chat', 'user', 'request', 'response','timestamp','datestamp']


@admin.register(UserConnectedStatus)
class UserConnectedStatusModelAdmin(admin.ModelAdmin):
    list_display = [ 'user','status']