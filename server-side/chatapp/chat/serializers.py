from rest_framework import serializers
from .models import ChatRoom,ChatMessage

class ChatRoomSerializer(serializers.ModelSerializer):
    members_info = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ['chat_room_id', 'chat_type', 'member_count', 'members_info']

    def get_members_info(self, obj):
        request = self.context.get('request')
        user_info = []
        for member in obj.members.all():
            if member.id != request.user.id:  
                user_info.append({
                    'id':member.id,
                    'first_name': member.first_name,
                    'last_name': member.last_name,
                    'bio': member.bio,
                    'image': member.image.url if member.image else None
                })
        return user_info

