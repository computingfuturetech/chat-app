from django.shortcuts import render
from django.http import JsonResponse
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from .models import ChatRoom,ChatMessage
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from rest_framework import generics,status
from .serializers import ChatRoomSerializer,ChatMessageSerializer
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

class UserChatRoomsAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        if not request.user.is_authenticated:
            return Response({'error': 'User not authenticated'}, status=status.HTTP_401_UNAUTHORIZED)
        user_id = request.user.id
        chat_rooms = ChatRoom.objects.filter(members=user_id)
        serializer = ChatRoomSerializer(chat_rooms, many=True, context={'request': request})
        for data in serializer.data:
            chat_room_id = data['chat_room_id']
            chat_room = get_object_or_404(ChatRoom, chat_room_id=chat_room_id)
            last_message = chat_room.chatmessage_set.last() 
            if last_message:
                data['last_message'] = {
                    'message': last_message.message,
                    'user_id': last_message.user_id,
                    'timestamp': last_message.timestamp
                }
            else:
                data['last_message'] = None
        return Response(serializer.data, status=status.HTTP_200_OK)


class SendMessageAPIView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        chat_room_id = request.data.get('chat')
        if not chat_room_id:
            return Response({'error': 'Chat room ID is missing'}, status=status.HTTP_400_BAD_REQUEST)

        chat_room_ids = chat_room_id.split('.')
        if len(chat_room_ids) != 2:
            return Response({'error': 'Invalid chat room ID format'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user1_id = int(chat_room_ids[0])
            user2_id = int(chat_room_ids[1])
        except ValueError:
            return Response({'error': 'Invalid user IDs in the chat room ID'}, status=status.HTTP_400_BAD_REQUEST)

        if not (user1_id == request.user.id or user2_id == request.user.id):
            return Response({'error': 'User is not a member of the specified chat room'}, status=status.HTTP_403_FORBIDDEN)

        chat_room = get_object_or_404(ChatRoom, chat_room_id=chat_room_id)

        if not chat_room:
            return Response({'error': 'Chat room not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = ChatMessageSerializer(data=request.data)
        if serializer.is_valid():
            serializer.validated_data['chat'] = chat_room 
            serializer.validated_data['user'] = request.user 
            room_group_name = f'chat_{chat_room.id}'
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                room_group_name,
                {
                    'type': 'chat.message',
                    'message': serializer.validated_data.get('message'),
                    'user_id': request.user.id,
                }
            )
            serializer.save()
            return Response({'status': 'Message sent successfully'}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


