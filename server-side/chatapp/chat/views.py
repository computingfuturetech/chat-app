from django.shortcuts import render
from django.http import JsonResponse
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from .models import ChatRoom
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from rest_framework import generics,status
from .serializers import ChatRoomSerializer
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
        User = get_user_model()
        # user = get_object_or_404(User, pk=user_id)
        chat_rooms = ChatRoom.objects.filter(members=user_id)
        serializer = ChatRoomSerializer(chat_rooms, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


@login_required
def send_message(request):
    chat_room_id = request.GET.get('chat_room_id')
    message = request.GET.get('message')
    user_id = request.GET.get('user_id')

    if chat_room_id and message and user_id:
        room_group_name = f'chat_{chat_room_id}'
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'user_id': user_id,
            }
        )
        return JsonResponse({'status': 'Message sent successfully'})
    else:
        return JsonResponse({'error': 'Missing parameters'}, status=400)

