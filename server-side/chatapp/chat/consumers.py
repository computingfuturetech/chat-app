# consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatMessage, ChatRoom

class ChatRoomConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = 'chat_%s' % self.room_name

        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']
        user_id = text_data_json['user_id']
        chat_room_id = text_data_json['chat_room_id']

        chat_message = ChatMessage.objects.create(
            chat_id=chat_room_id,
            user_id=user_id,
            message=message
        )

        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'user_id': user_id,
                'chat_room_id': chat_room_id
            }
        )

    async def chat_message(self, event):
        message = event['message']
        user_id = event['user_id']
        chat_room_id = event['chat_room_id']

        await self.send(text_data=json.dumps({
            'message': message,
            'user_id': user_id,
            'chat_room_id': chat_room_id
        }))
