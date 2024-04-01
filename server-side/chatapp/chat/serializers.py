from rest_framework import serializers
from .models import ChatRoom,ChatMessage
from django.db.models import Max
from rest_framework import serializers
from .models import ChatRoom, ChatMessage

class ChatRoomSerializer(serializers.ModelSerializer):
    members_info = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ['id','chat_room_id', 'chat_type', 'member_count', 'members_info']

    def get_members_info(self, obj):
        request = self.context.get('request')
        user_info = []
        for member in obj.members.all():
            if member.id != request.user.id:  
                user_info.append({
                    'id':member.id,
                    'first_name': member.first_name if member.first_name else member.username,
                    'last_name': member.last_name,
                    'bio': member.bio,
                    'image': member.image.url if member.image else ''
                })
        return user_info
    

class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model=ChatMessage
        fields=['user','message','image','video','document','audio_file']
    
