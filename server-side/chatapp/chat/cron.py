from django.utils import timezone
from datetime import timedelta
from .models import ChatMessage

def delete_previous_messages():
    current_date = timezone.now().date()
    days_ago = current_date - timedelta(days=15)
    messages_to_delete = ChatMessage.objects.filter(datestamp__lt=days_ago)
    deleted_count = messages_to_delete.delete()[0]

delete_previous_messages()