import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatRoom, ChatMessage,AiModel,UserConnectedStatus
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
from openai import OpenAI
import os
from django.conf import settings
from django.db.models import Q

api_key = os.environ.get("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)

cred = credentials.Certificate('chat/chat-box-cft-firebase-adminsdk-61r28-0745b75238.json')
firebase_admin.initialize_app(cred)

def openai(client, content):
    completion = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": content}
        ]
    )
    response = completion.choices[0].message.content
    return response

def extract_recipient_id(chat_room_id, sender_id):
    sender, recipient = map(int, chat_room_id.split('.'))
    return recipient if sender == sender_id else sender


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['roomId']
        self.user_id = self.scope['url_route']['kwargs']['userId']
        user_instance = await sync_to_async(User.objects.get)(pk=self.user_id)
        user_status, created = await sync_to_async(UserConnectedStatus.objects.get_or_create)(
            user=user_instance
        )
        user_status.status = True
        await sync_to_async(user_status.save)()

        try:
            chat_room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
        except ChatRoom.DoesNotExist:
            await self.close()
            return

        user_ids = [int(user_id) for user_id in chat_room.chat_room_id.split('.')]
        try:
            users_in_room = await sync_to_async(User.objects.filter)(id__in=user_ids)
        except Exception as e:
            await self.close()
            return

        if not users_in_room:
            await self.close()
            return

        self.room_group_name = f"chat_{self.room_id}"
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.update_pending_messages()

        await self.accept()
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.group_send_count = 0

    async def update_pending_messages(self):
        try:
            chat_room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
            recipient_id = extract_recipient_id(chat_room.chat_room_id, self.user_id)
            pending_messages = await sync_to_async(ChatMessage.objects.filter)(
                Q(chat=chat_room.id) & ~Q(user_id=self.user_id) & Q(sent=False)
            )
            if pending_messages:
                previous_chat = []
                for message in pending_messages:
                    message.sent = True 
                    await sync_to_async(message.save)()
                    previous_chat.append(message)
                
                for message in previous_chat:
                    print(message)
                    self.group_send_count += 1
                    await self.channel_layer.group_send(
                        self.room_group_name,
                        {
                            'type': 'chat_message',
                            'username': message.user.username,  
                            'content': message.message,  
                            'user_id': message.user.id,  
                            'timestamp': message.timestamp.isoformat(),  
                            'message_type': message.chat_type, 
                            'excluder': 'excluder'
                        }
                    )
                # print("Number of group_send calls:", self.group_send_count)  # Print the count
            else:
                print("No pending messages for this room")
        except Exception as e:
            print(f"Error handling pending messages: {e}")



    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
        user_instance = await sync_to_async(User.objects.get)(pk=self.user_id)
        user_status, created = await sync_to_async(UserConnectedStatus.objects.get_or_create)(
            user=user_instance
        )
        user_status.status = False
        await sync_to_async(user_status.save)()

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
            elif message_type == 'ai_type':
                await self.handle_ai_message(text_data_json, username, chat_room,member_ids)

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
    
    async def handle_ai_message(self, data, username, chat_room, member_ids):
        last_messsage=data.get('last_message')
        message = data.get('message')

        requested_message=last_messsage + ' ' + message
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
        chat_message = await sync_to_async(AiModel.objects.create)(
            chat=chat_room,
            user=user,
            request=message,
        )
        timestamp = chat_message.timestamp
        await self.send_chat_message(username,message, timestamp, 'text_type',1)
        
        chat_message.response = await sync_to_async(openai)(client, requested_message)
        await sync_to_async(chat_message.save)()
        
        await self.send_chat_message('Chatbox_Ai', chat_message.response, timestamp, 'text_type',1)

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
            message=message,
            chat_type='text_type'
        )
        timestamp = chat_message.timestamp
        await self.send_chat_notification(message, title, fcm_token)
        await self.send_chat_message(username, message, timestamp, 'text_type',id)

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
                image=image_content,
                chat_type='image_type'
            )
            timestamp = chat_message.timestamp
            image_url = f"/media/{chat_message.image}"
            message='Image'
            await self.send_chat_notification(message, title, fcm_token)
            await self.send_chat_message(username, image_url, timestamp, 'image_type',1)

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
                    audio_file=audio_file_content,
                    chat_type='audio_type'
                )
                message='Audio'
                audio_url = f"/media/{chat_message.audio_file}"
                timestamp = chat_message.timestamp
                await self.send_chat_notification(message, title, fcm_token)
                await self.send_chat_message(username, audio_url, timestamp, 'audio_type',1)
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
                document=document_file_content,
                chat_type='document_type'
                
            )
            message='Document'
            document_url = f"/media/{chat_message.document}"
            timestamp = chat_message.timestamp
            await self.send_chat_notification(message, title, fcm_token)
            await self.send_chat_message(username, document_url, timestamp, 'document_type',1)
    
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
            if data_type and data_type[0] in ['m', 'a', 'f']:
                if data_type in ['avif']:
                    chat_type='image_type'
                else:
                    chat_type='video_type'
            else:
                chat_type='image_type'

            chat_message = await sync_to_async(ChatMessage.objects.create)(
                chat=chat_room,
                user=user,
                media=media_file_content,
                chat_type=chat_type
            )
            media_url = f"/media/{chat_message.media}"
            timestamp = chat_message.timestamp
            if data_type and data_type[0] in ['m', 'a', 'f']:
                if data_type in ['avif']:
                    message='Image'
                    await self.send_chat_notification(message, title, fcm_token)
                    await self.send_chat_message(username, media_url, timestamp, 'image_type',1)
                else:
                    message='Video'
                    await self.send_chat_notification(message, title, fcm_token)
                    await self.send_chat_message(username, media_url, timestamp, 'video_type',1)
            else:
                message='Image'
                await self.send_chat_notification(message, title, fcm_token)
                await self.send_chat_message(username, media_url, timestamp, 'image_type',1)

    async def send_chat_message(self, username, content, timestamp, message_type, member_ids):
        sender_channel_name = self.channel_name
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'username': username,
                'content': content,
                'user_id': self.user_id if username != 'Chatbox_Ai' else 2,
                'timestamp': timestamp.isoformat(),
                'message_type': message_type,
                'sender_channel_name': sender_channel_name, 
            }
        )
        if username == 'AI' or 'Chatbox_Ai':
            pass
        else:
            chat_room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
            recipient_id = extract_recipient_id(chat_room.chat_room_id, self.user_id)

            check_receiver_user_status = await sync_to_async(UserConnectedStatus.objects.get)(user=recipient_id)
            if check_receiver_user_status.status == True:
                await self.update_message()


    async def update_message(self):
        try:
            unsent_messages = await sync_to_async(ChatMessage.objects.filter)(sent=0)
            for message in unsent_messages:
                message.sent = 1
                await sync_to_async(message.save)()
        except Exception as e:
            print(f"Error updating message: {e}")



    async def chat_message(self, event):
        content = event.get('content')
        timestamp = event.get('timestamp')
        user_id = event.get('user_id')
        message_type = event.get('message_type')
        excluder=event.get('excluder')
        try:
            if excluder:
                if user_id is not None and user_id != self.user_id:
                    user = await sync_to_async(get_user_model().objects.get)(id=user_id)
                    await self.send(text_data=json.dumps({
                        'username': user.username,
                        'content': content,
                        'timestamp': timestamp,
                        'user_id': user_id,
                        'message_type': message_type,
                    }))
                else:
                    print("exclude")
            else:
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
                    print("User ID not provided in the WebSocket event or sender is excluded")
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
        except Exception as e:
            print(f"Error sending push notification: {e}")