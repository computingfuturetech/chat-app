# Generated by Django 4.0.1 on 2024-03-26 06:14

import chat.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('chat', '0003_chatmessage_audio_file_chatmessage_duration_seconds_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='chatmessage',
            name='document',
            field=models.FileField(blank=True, null=True, upload_to=chat.models.user_document_path),
        ),
        migrations.AddField(
            model_name='chatmessage',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to=chat.models.user_image_path),
        ),
    ]
