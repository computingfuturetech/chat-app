import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatRoom, ChatMessage
from user.models import User,FriendRequest
from django.contrib.auth import get_user_model
from asgiref.sync import sync_to_async
from django.utils import timezone
from django.core.files.base import ContentFile
from PIL import Image
import io
import base64
import magic

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
            elif message_type == 'audio_type':
                await self.handle_audio_message(text_data_json, username, chat_room)
            elif message_type == 'document_type':
                await self.handle_document_message(text_data_json, username, chat_room)
            elif message_type == 'media_type':
                await self.handle_media_message(text_data_json, username, chat_room)

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
        image_data = data.get('message')
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
            image_url = f"/media/{chat_message.image}"
            await self.send_chat_message(username, image_url, timestamp, 'image_type')

    async def handle_audio_message(self, data, username, chat_room):
        try:
            audio_data = data.get('message')
            if audio_data:
                audio_bytes = bytes(audio_data)
                audio_format = "wav"  
                audio_file_content = ContentFile(audio_bytes, name='temp.mp3')
                user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
                chat_message = await sync_to_async(ChatMessage.objects.create)(
                    chat=chat_room,
                    user=user,
                    audio_file=audio_file_content
                )
                audio_url = f"/media/{chat_message.audio_file}"
                timestamp = chat_message.timestamp
                await self.send_chat_message(username, audio_url, timestamp, 'audio_type')
        except Exception as e:
            print(f"Error handling audio message: {e}")

    async def handle_document_message(self, data, username, chat_room):
        document_data = data.get('message')
        document_type = data.get('extension')
        if document_data and document_type:
            document_bytes = bytes(document_data) 
            document_file_content = ContentFile(document_bytes, name=f"temp.{document_type}" )
            user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
            chat_message = await sync_to_async(ChatMessage.objects.create)(
                chat=chat_room,
                user=user,
                document=document_file_content
            )
            document_url = f"/media/{chat_message.document}"
            timestamp = chat_message.timestamp
            await self.send_chat_message(username, document_url, timestamp, 'document_type')
    
    async def handle_media_message(self, data, username, chat_room):
        recieved_data = data.get('message')
        data_type = data.get('extension')
        if recieved_data and data_type:
            data_bytes = bytes(recieved_data)
            media_file_content = ContentFile(data_bytes, name=f"temp.{data_type}" )
            user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
            chat_message = await sync_to_async(ChatMessage.objects.create)(
                chat=chat_room,
                user=user,
                media=media_file_content
            )
            media_url = f"/media/{chat_message.media}"
            timestamp = chat_message.timestamp
            if data_type and data_type[0] in ['m', 'a', 'f']:
                await self.send_chat_message(username, media_url, timestamp, 'video_type')
            else:
                await self.send_chat_message(username, media_url, timestamp, 'image_type')

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


from channels.db import database_sync_to_async


class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.to_user_id = self.scope['url_route']['kwargs']['toUser']
        self.from_user_id = self.scope['url_route']['kwargs']['fromUser']

        to_user = await database_sync_to_async(User.objects.get)(id=self.to_user_id)
        from_user = await database_sync_to_async(User.objects.get)(id=self.from_user_id)

        if to_user and from_user:
            self.room_group_name = f"online_{self.to_user_id}"  # Use a more specific room name
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )
            await self.accept()
        else:
            await self.close()

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        try:
            text_data_json = json.loads(text_data)
            print(text_data_json)
            notification_type = text_data_json.get('type')
            message = text_data_json.get('message')

            if notification_type and message:
                from_user = await database_sync_to_async(User.objects.get)(id=self.from_user_id)
                from_username = from_user.username if from_user else "Unknown"
                await self.send(text_data=json.dumps({
                    'notification_type': notification_type,
                    'message': f"{from_username}{message}", 
                }))
                await self.send_friend_request(message, 'friend_request_type')  
            else:
                await self.send(text_data=json.dumps({
                    'error': 'Invalid notification data'
                }))
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'error': 'Invalid JSON format'
            }))

    async def send_friend_request(self, message, message_type):
        try:
            # Extract recipient user ID from message or context
            recipient_user_id = self.from_user_id
            if recipient_user_id:
                print('ok')
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'chat_message',
                        'message': message,
                        'message_type': message_type,
                        'recipient_user_id': recipient_user_id,  # Include recipient user ID
                    }
                )
        except Exception as e:
            print(f"Error sending friend request: {e}")

    async def chat_message(self, event):
        try:
            message = event['message']
            message_type = event['message_type']
            recipient_user_id = event.get('recipient_user_id')
            recipient_user = await database_sync_to_async(User.objects.get)(id=recipient_user_id)
            if message_type == 'friend_request_type':
                print('send')
                await self.send(text_data=json.dumps({
                    'notification_type': 'Friend Request',
                    'message': f"You received a friend request from {recipient_user.username}",
                }))
            else:
                pass  
        except Exception as e:
            print(f"Error handling chat message: {e}")

