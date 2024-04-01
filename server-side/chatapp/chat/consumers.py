import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatRoom, ChatMessage
from django.contrib.auth import get_user_model
from asgiref.sync import sync_to_async
from django.utils import timezone
from django.core.files.base import ContentFile
from PIL import Image
import io
import base64

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['roomId']
        self.user_id = self.scope['url_route']['kwargs']['userId']

        room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
        user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)

        if room and user:
            self.room_group_name = f"chat_{self.room_id}"
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )
            await self.accept()
        else:
            await self.close()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        try:
            text_data_json = json.loads(text_data)
            message_type = text_data_json.get('type')
            username = text_data_json.get('username')
            chat_room = await self.get_chat_room()

            if message_type == 'text_type':
                await self.handle_text_message(text_data_json, username, chat_room)
            elif message_type == 'image_type':
                await self.handle_image_message(text_data_json, username, chat_room)
            

        except json.JSONDecodeError:
            return

    async def get_chat_room(self):
        try:
            return await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
        except ChatRoom.DoesNotExist:
            await self.send(text_data=json.dumps({
                'error': 'Room does not exist'
            }))
            raise

    async def handle_delete_message(self, data):
        message_id = data.get('message_id')
        await self.delete_message(message_id)

    async def handle_text_message(self, data, username, chat_room):
        message = data.get('message')
        user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
        chat_message = await sync_to_async(ChatMessage.objects.create)(
            chat=chat_room,
            user=user,
            message=message
        )
        timestamp = chat_message.timestamp
        await self.send_chat_message(username, message, timestamp, 'text_type')

    async def handle_image_message(self, data, username, chat_room):
        image_data = data.get('image')
        if image_data:
            image_bytes = bytes(image_data)
            image_base64 = base64.b64encode(image_bytes).decode('utf-8')
            image_content = ContentFile(image_bytes, name='temp.jpg')
            user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
            chat_message = await sync_to_async(ChatMessage.objects.create)(
                chat=chat_room,
                user=user,
                image=image_content
            )
            timestamp = chat_message.timestamp
            await self.send_chat_message(username, image_base64, timestamp, 'image_type')

    async def send_chat_message(self, username, content, timestamp, message_type):
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'username': username,
                'content': content,
                'user_id': self.user_id,
                'timestamp': timestamp.isoformat(),
                'message_type': message_type,
            }
        )

    async def chat_message(self, event):
        content = event.get('content')
        timestamp = event.get('timestamp')
        user_id = event.get('user_id')
        message_type = event.get('message_type')
        try:
            if user_id is not None:
                user = await sync_to_async(get_user_model().objects.get)(id=user_id)
                await self.send(text_data=json.dumps({
                    'username': user.username,
                    'content': content,
                    'timestamp': timestamp,
                    'user_id': user_id,
                    'message_type': message_type,
                }))
            else:
                print("User ID not provided in the WebSocket event")
        except get_user_model().DoesNotExist:
            print(f"User with ID {user_id} does not exist")
        except Exception as e:
            print(f"Error sending message: {e}")

        
    async def delete_message(self, message_id):
        try:
            message = await sync_to_async(ChatMessage.objects.get)(id=message_id)
            if message.user.id == self.user_id:
                await sync_to_async(message.delete)()
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'message_deleted',
                        'message_id': message_id
                    }
                )
            else:
                await self.send(text_data=json.dumps({
                    'error': 'You do not have permission to delete this message'
                }))
        except ChatMessage.DoesNotExist:
            await self.send(text_data=json.dumps({
                'error': 'Message does not exist'
            }))

    async def message_deleted(self, event):
        message_id = event['message_id']
        await self.send(text_data=json.dumps({
            'message_deleted': message_id
        }))

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        try:
            text_data_json = json.loads(text_data)
            notification_type = text_data_json.get('type')
            message = text_data_json.get('message')

            if notification_type and message:
                await self.send(text_data=json.dumps({
                    'notification_type': notification_type,
                    'message': message,
                }))
            else:
                await self.send(text_data=json.dumps({
                    'error': 'Invalid notification data'
                }))
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'error': 'Invalid JSON format'
            }))

