from django.db import models
from django.contrib.auth.models import AbstractUser
import os
from django.db import models

def user_image_path(instance, filename):
    user_id = instance.id
    _, file_extension = os.path.splitext(filename)
    new_filename = f"{user_id}pfp{file_extension}"
    return os.path.join('store/images', new_filename)

class User(AbstractUser):
    email=models.EmailField(unique=True)
    phone=models.CharField(max_length=11, default="")
    image = models.ImageField(upload_to=user_image_path, blank=True, null=True)
    is_social_login = models.BooleanField(default=False)
    is_online = models.BooleanField(default=False)
    bio = models.TextField(blank=True,default='Hey there! i am using chatbox')
    def __str__(self):
        return self.username

class FriendRequest(models.Model):
    from_user = models.ForeignKey(User, related_name='sent_friend_requests', on_delete=models.CASCADE)
    to_user = models.ForeignKey(User, related_name='received_friend_requests', on_delete=models.CASCADE)
    request_sent=models.BooleanField(default=False)
    is_accepted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

class EmailOtp(models.Model):
    email = models.ForeignKey(User, on_delete=models.CASCADE)
    otp = models.CharField(max_length=6)
    expiration_time = models.TimeField()

