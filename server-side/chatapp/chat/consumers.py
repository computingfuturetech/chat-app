import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatRoom, ChatMessage
from user.models import User,FriendRequest
from django.contrib.auth import get_user_model
from asgiref.sync import sync_to_async
from django.core.files.base import ContentFile
import base64
import json
import firebase_admin
from firebase_admin import messaging
from django.db.models import ObjectDoesNotExist
from firebase_admin import credentials
from channels.db import database_sync_to_async

cred = credentials.Certificate('chat/chat-box-cft-firebase-adminsdk-61r28-0745b75238.json')
firebase_admin.initialize_app(cred)

import os
from django.conf import settings

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

    # async def disconnect(self, close_code):
    #     if hasattr(self, 'room_group_name'):
    #         await self.channel_layer.group_discard(
    #             self.room_group_name,
    #             self.channel_name
    #         )

    async def receive(self, text_data):
        try:
            text_data_json = json.loads(text_data)
            message_type = text_data_json.get('type')
            username = text_data_json.get('username')
            chat_room = await self.get_chat_room()
            self.room_id = self.scope['url_route']['kwargs']['roomId']
            room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
            self.current_user_id = int(self.scope['url_route']['kwargs']['userId'])
            room_members = await database_sync_to_async(list)(room.members.all())
            member_ids = []
            for member in room_members:
                if member.id != self.current_user_id:
                    member_ids.append(member.id)

            if message_type == 'text_type':
                await self.handle_text_message(text_data_json, username, chat_room,member_ids)
            elif message_type == 'image_type':
                await self.handle_image_message(text_data_json, username, chat_room,member_ids)
            elif message_type == 'audio_type':
                await self.handle_audio_message(text_data_json, username, chat_room,member_ids)
            elif message_type == 'document_type':
                await self.handle_document_message(text_data_json, username, chat_room,member_ids)
            elif message_type == 'media_type':
                await self.handle_media_message(text_data_json, username, chat_room,member_ids)

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

    async def handle_text_message(self, data, username, chat_room, member_ids):
        message = data.get('message')
        self.user_id = int(self.scope['url_route']['kwargs']['userId'])
        sender_user=await sync_to_async(User.objects.get)(id=self.user_id)
        title=f'{sender_user.first_name} {sender_user.last_name}'
        id=data.get('toID')
        to_user_id=int(id)
        to_user = await database_sync_to_async(User.objects.get)(id=to_user_id)
        user_token = await sync_to_async(User.objects.get)(id=to_user.id)
        if user_token:
            fcm_token=user_token.fcm_token
        user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
        chat_message = await sync_to_async(ChatMessage.objects.create)(
            chat=chat_room,
            user=user,
            message=message
        )
        timestamp = chat_message.timestamp
        await self.send_chat_notification(message, title, fcm_token)
        await self.send_chat_message(username, message, timestamp, 'text_type')

    async def handle_image_message(self, data, username, chat_room,member_ids):
        image_data = data.get('message')
        self.user_id = int(self.scope['url_route']['kwargs']['userId'])
        sender_user=await sync_to_async(User.objects.get)(id=self.user_id)
        title=f'{sender_user.first_name} {sender_user.last_name}'
        id=data.get('toID')
        to_user_id=int(id)
        to_user = await database_sync_to_async(User.objects.get)(id=to_user_id)
        user_token = await sync_to_async(User.objects.get)(id=to_user.id)
        if user_token:
            fcm_token=user_token.fcm_token
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
            message='Image'
            await self.send_chat_notification(message, title, fcm_token)
            await self.send_chat_message(username, image_url, timestamp, 'image_type')

    async def handle_audio_message(self, data, username, chat_room,member_ids):
        try:
            audio_data = data.get('message')
            self.user_id = int(self.scope['url_route']['kwargs']['userId'])
            sender_user=await sync_to_async(User.objects.get)(id=self.user_id)
            title=f'{sender_user.first_name} {sender_user.last_name}'
            id=data.get('toID')
            to_user_id=int(id)
            to_user = await database_sync_to_async(User.objects.get)(id=to_user_id)
            user_token = await sync_to_async(User.objects.get)(id=to_user.id)
            if user_token:
                fcm_token=user_token.fcm_token
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
                message='Audio'
                audio_url = f"/media/{chat_message.audio_file}"
                timestamp = chat_message.timestamp
                await self.send_chat_notification(message, title, fcm_token)
                await self.send_chat_message(username, audio_url, timestamp, 'audio_type')
        except Exception as e:
            print(f"Error handling audio message: {e}")

    async def handle_document_message(self, data, username, chat_room,member_ids):
        document_data = data.get('message')
        document_type = data.get('extension')
        file_name = data.get('name')
        self.user_id = int(self.scope['url_route']['kwargs']['userId'])
        sender_user=await sync_to_async(User.objects.get)(id=self.user_id)
        title=f'{sender_user.first_name} {sender_user.last_name}'
        id=data.get('toID')
        to_user_id=int(id)
        to_user = await database_sync_to_async(User.objects.get)(id=to_user_id)
        user_token = await sync_to_async(User.objects.get)(id=to_user.id)
        if user_token:
            fcm_token=user_token.fcm_token
        if document_data and document_type and file_name:
            document_bytes = bytes(document_data) 
            user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
            document_file_content = ContentFile(document_bytes, name=f"{user.id}-{file_name}" )
            chat_message = await sync_to_async(ChatMessage.objects.create)(
                chat=chat_room,
                user=user,
                document=document_file_content
            )
            message='Document'
            document_url = f"/media/{chat_message.document}"
            timestamp = chat_message.timestamp
            await self.send_chat_notification(message, title, fcm_token)
            await self.send_chat_message(username, document_url, timestamp, 'document_type')
    
    async def handle_media_message(self, data, username, chat_room,member_ids):
        recieved_data = data.get('message')
        data_type = data.get('extension')
        self.user_id = int(self.scope['url_route']['kwargs']['userId'])
        sender_user=await sync_to_async(User.objects.get)(id=self.user_id)
        title=f'{sender_user.first_name} {sender_user.last_name}'
        id=data.get('toID')
        to_user_id=int(id)
        to_user = await database_sync_to_async(User.objects.get)(id=to_user_id)
        user_token = await sync_to_async(User.objects.get)(id=to_user.id)
        if user_token:
            fcm_token=user_token.fcm_token
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
                if data_type in ['avif']:
                    message='Image'
                    await self.send_chat_notification(message, title, fcm_token)
                    await self.send_chat_message(username, media_url, timestamp, 'image_type')
                else:
                    message='Video'
                    await self.send_chat_notification(message, title, fcm_token)
                    await self.send_chat_message(username, media_url, timestamp, 'video_type')
            else:
                message='Image'
                await self.send_chat_notification(message, title, fcm_token)
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
    
    async def send_chat_notification(self, message, title, fcm_token):
        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=message),
                token=fcm_token,
            )
            response = await sync_to_async(messaging.send)(message)
            print('Successfully sent message:', response)
        except Exception as e:
            print(f"Error sending push notification: {e}")

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.to_user_id = self.scope['url_route']['kwargs']['toUser']
        to_user = await database_sync_to_async(User.objects.get)(id=self.to_user_id)
        if to_user:
            self.room_group_name = f"online_{self.to_user_id}" 
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )
            await self.accept()
        else:
            await self.close()

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        notification_type = text_data_json.get('type')
        message = text_data_json.get('message')
        user_id = text_data_json.get('userID')
        try:
            user = await sync_to_async(User.objects.get)(id=user_id)
            if user:
                message = f"{user.username} {message}"
        except User.DoesNotExist:
            print("User not found")
        to_user = await database_sync_to_async(User.objects.get)(id=self.to_user_id)
        user_token = await sync_to_async(User.objects.get)(id=to_user.id)
        if user_token:
            fcm_token=user_token.fcm_token
        if notification_type and message:
            await self.send_push_notification(message, 'Friend Request',fcm_token)

    async def send_push_notification(self, message, title, fcm_token):
        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=message),
                token=fcm_token
            )
            response = await sync_to_async(messaging.send)(message)
            print('Successfully sent message:', response)
        except Exception as e:
            print(f"Error sending push notification: {e}")