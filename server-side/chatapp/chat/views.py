from django.shortcuts import render
from django.http import JsonResponse
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from .models import ChatRoom
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
@login_required
def create_chat_room(request):
    if request.method == 'POST':
        chat_type = request.POST.get('chat_type')
        member_ids = request.POST.getlist('member_ids[]') 
        chat_room = ChatRoom.objects.create(chat_type=chat_type)
        chat_room.members.add(*member_ids)
        return JsonResponse({'id': chat_room.id, 'chat_type': chat_room.chat_type, 'member_count': chat_room.member_count})
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

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

