import json
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatRoom, ChatMessage
from django.contrib.auth import get_user_model
from asgiref.sync import sync_to_async
from django.utils import timezone

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
            chat_room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
            all_messages = await sync_to_async(ChatMessage.objects.filter)(chat=chat_room)
            message_history = await sync_to_async(lambda: [{
                        'username': msg.user.username,
                        'message': msg.message,
                        'user_id': msg.user.id,
                        'timestamp': msg.timestamp.isoformat()
                    } for msg in all_messages])()
            await self.send(text_data=json.dumps({
                'message_history': message_history
            }))
        else:
            await self.close()
    
    # async def send_chat_history(self):
    #     chat_room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
    #     all_messages = await sync_to_async(ChatMessage.objects.filter)(chat=chat_room)
    #     message_history = await sync_to_async(lambda: [{
    #                 'username': msg.user.username,
    #                 'message': msg.message,
    #                 'user_id': msg.user.id,
    #                 'timestamp': msg.timestamp.isoformat()
    #             } for msg in all_messages])()
        
    #     # Send the chat history to the client
    #     await self.send(text_data=json.dumps({
    #         'message_history': message_history
    #     }))

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        try:
            text_data_json = json.loads(text_data)
            message = text_data_json.get('message')
            username = text_data_json.get('username')
            print(message)

            if message:
                message_type = text_data_json.get('type')  
                if message_type == 'delete_message':
                    message_id = text_data_json.get('message_id')
                    await self.delete_message(message_id)

                try:
                    chat_room = await sync_to_async(ChatRoom.objects.get)(id=self.room_id)
                except ChatRoom.DoesNotExist:
                    await self.send(text_data=json.dumps({
                        'error': 'Room does not exist'
                    }))
                    return
                
                self.user_id = self.scope['url_route']['kwargs']['userId']
                user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
                chat_message = await sync_to_async(ChatMessage.objects.create)(
                    chat=chat_room,
                    user=user,
                    message=message
                )
                all_messages = await sync_to_async(ChatMessage.objects.filter)(chat=chat_room)
                timestamp = chat_message.timestamp
                print(timestamp)
                message_history = await sync_to_async(lambda: [{
                    'username': msg.user.username,
                    'message': msg.message,
                    'user_id': msg.user.id,
                    'timestamp': msg.timestamp.isoformat()
                } for msg in all_messages])()

                print(message_history)
                
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'chat_message',
                        'username': username,
                        'message': message,
                        'user_id': self.user_id,
                        'timestamp': timestamp.isoformat(),
                        'message_history': message_history 
                    }
                )
        except json.JSONDecodeError:
            return

    async def chat_message(self, event):
        message = event.get('message')
        timestamp = event.get('timestamp')
        message_history = event.get('message_history')

        if message:
            try:
                user_id = event.get('user_id') 
                if user_id is not None:
                    user = await sync_to_async(get_user_model().objects.get)(id=user_id)
                    
                    await self.send(text_data=json.dumps({
                        'username': user.username,  
                        'message': message,
                        'timestamp':timestamp,
                        'message_history': message_history
                    }))
                else:
                    print("User ID not provided in the WebSocket event")
            except get_user_model().DoesNotExist:
                print(f"User with ID {user_id} does not exist")
            except Exception as e:
                print(f"Error sending message: {e}")
        else:
            print("Incomplete message data received")
        
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

