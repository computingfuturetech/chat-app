# Generated by Django 4.0.1 on 2024-04-18 08:17

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('user', '0010_user_fcm_token'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='fcm_token',
            field=models.TextField(blank=True, null=True),
        ),
    ]
