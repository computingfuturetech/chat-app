# Generated by Django 4.0.1 on 2024-04-18 08:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('user', '0009_alter_user_groups_alter_user_user_permissions'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='fcm_token',
            field=models.TextField(default=None),
            preserve_default=False,
        ),
    ]