from django.shortcuts import render
from .models import ChatRoom
from rest_framework import status
from .serializers import ChatRoomSerializer,ChatMessageSerializer
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import ListAPIView
from django.shortcuts import render

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
                if last_message.image:
                    data['last_message'] = {
                        'message': 'Image',
                        'user_id': last_message.user_id,
                        'timestamp': last_message.timestamp
                    }
                elif last_message.audio_file:
                    data['last_message'] = {
                        'message': 'Audio_file',
                        'user_id': last_message.user_id,
                        'timestamp': last_message.timestamp
                    }
                elif last_message.document:
                    data['last_message'] = {
                        'message': 'document',
                        'user_id': last_message.user_id,
                        'timestamp': last_message.timestamp
                    }
                else:
                    data['last_message'] = {
                        'message': last_message.message,
                        'user_id': last_message.user_id,
                        'timestamp': last_message.timestamp
                    }
            else:
                data['last_message'] = {
                    'message': 'Say Hello!',
                    'user_id': '',
                    'timestamp': ''
                }
        return Response(serializer.data, status=status.HTTP_200_OK)


class ChatRoomView(APIView):
	def get(self, request, userId):
		chatRooms = ChatRoom.objects.filter(member=userId)
		serializer = ChatRoomSerializer(
			chatRooms, many=True, context={"request": request}
		)
		return Response(serializer.data, status=status.HTTP_200_OK)

	def post(self, request):
		serializer = ChatRoomSerializer(
			data=request.data, context={"request": request}
		)
		if serializer.is_valid():
			serializer.save()
			return Response(serializer.data, status=status.HTTP_200_OK)
		return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class MessagesView(ListAPIView):
	serializer_class = ChatMessageSerializer
