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

# def detect_document_type(document_data):
#     if isinstance(document_data, list):
#         document_data = bytes(document_data)  # Convert list to bytes

#     magic_bytes = {
#         b'%PDF-': 'PDF',
#         b'\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1': 'PPT',
#         b'\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1': 'DOC',
#         b'\xFF\xFB': 'MP3',
#         b'\x50\x4B\x03\x04': 'ZIP',  # Adjust this for Word documents
#         b'\x52\x49\x46\x46': 'WAV',  # RIFF header
#         b'\x1A\x45\xDF\xA3': 'MKV',
#         b'\x6D\x6F\x6F\x76': 'MOV',
#         b'\x46\x4C\x56\x01': 'FLV',
#         b'\x4F\x67\x67\x53': 'OGG',
#         b'\xEF\xBB\xBF': 'TXT',  # UTF-8 encoded
#         b'\x7B\x22\x74\x65\x73\x74\x22\x3A': 'JSON',
#         b'\x3C\x3F\x78\x6D\x6C\x20': 'XML',
#         b'\x3C\x21\x44\x4F\x43\x54\x59': 'HTML',
#         b'\x3C\x3F\x78\x6D\x6C\x20': 'SVG',
#         b'\x22\x22\x22': 'CSV',  # CSV with quotes
#         b'\x50\x4B\x03\x04\x14\x00\x06\x00': 'PPTX',
#         # Add more magic bytes for other document types
#     }

#     for magic, doc_type in magic_bytes.items():
#         if magic in document_data:
#             return doc_type

#     return 'Unknown'  # If the document type cannot be determined

import magic

def detect_document_type(document_data):
    document_bytes = bytes(document_data)
    m = magic.Magic()
    file_type = m.from_buffer(document_bytes)

    if "PDF document" in file_type:
        return "pdf"
    elif "Microsoft PowerPoint" in file_type:
        return "ppt"
    elif "Composite Document File" in file_type:
        return "doc"
    elif "Audio file with ID3" in file_type:
        return "mp3"
    elif "Audio file with MIME" in file_type:
        return "m4a"
    elif "JPEG image data" in file_type:
        return "jpeg"
    elif "PNG image data" in file_type:
        return "png"
    elif "GIF image data" in file_type:
        return "gif"
    elif "TIFF image data" in file_type:
        return "tiff"
    elif "BMP image data" in file_type:
        return "bmp"
    elif "ICO image data" in file_type:
        return "ico"
    elif "ZIP archive data" in file_type:
        return "zip"
    elif "RAR archive data" in file_type:
        return "rar"
    elif "7z archive data" in file_type:
        return "7z"
    elif "MP4 video" in file_type:
        return "mp4"
    elif "MKV video" in file_type:
        return "mkv"
    elif "MOV video" in file_type:
        return "mov"
    elif "FLV video" in file_type:
        return "flv"
    elif "OGG video" in file_type:
        return "ogg"
    elif "JSON data" in file_type:
        return "json"
    elif "XML document text" in file_type:
        return "xml"
    elif "HTML document" in file_type:
        return "html"
    elif "CSV text" in file_type:
        return "csv"
    elif "PowerPoint Open XML document" in file_type:
        return "pptx"
    else:
        return "unknown"

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
            
            # print(text_data_json)
            if message_type == 'text_type':
                await self.handle_text_message(text_data_json, username, chat_room)
            elif message_type == 'image_type':
                await self.handle_image_message(text_data_json, username, chat_room)
            elif message_type == 'audio_type':
                await self.handle_audio_message(text_data_json, username, chat_room)
            elif message_type == 'document_type':
                await self.handle_document_message(text_data_json, username, chat_room)

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
                audio_file_content = ContentFile(audio_bytes, name='temp.m4a')
                # with open(audio_file_path, "wb") as audio_file:
                #     audio_file.write(audio_bytes)
                user = await sync_to_async(get_user_model().objects.get)(id=self.user_id)
                chat_message = await sync_to_async(ChatMessage.objects.create)(
                    chat=chat_room,
                    user=user,
                    audio_file=audio_file_content
                )
                audio_url = f"/media/{chat_message.audio_file}"
                timestamp = chat_message.timestamp
                await self.send_chat_message(username, audio_url, timestamp, 'audio_type')
                print('Audio message sent successfully')
        except Exception as e:
            print(f"Error handling audio message: {e}")

    async def handle_document_message(self, data, username, chat_room):
        document_data = data.get('message')
        if document_data:
            document_type = detect_document_type(document_data)
            print(document_type)
            document_bytes = bytes(document_data)
            document_format = document_type  
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