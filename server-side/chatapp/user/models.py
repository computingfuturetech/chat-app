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
    def __str__(self):
        return self.username

class EmailOtp(models.Model):
    email = models.ForeignKey(User, on_delete=models.CASCADE)
    otp = models.CharField(max_length=6)
    expiration_time = models.TimeField()

