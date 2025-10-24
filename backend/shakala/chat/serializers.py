# chat/serializers.py

from rest_framework import serializers
from .models import Message, Thread
from users.models import User
from users.serializers import UserPublicProfileSerializer

class MessageSerializer(serializers.ModelSerializer):
    sender = UserPublicProfileSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'thread', 'sender', 'content', 'timestamp']


class ThreadSerializer(serializers.ModelSerializer):
    user1 = UserPublicProfileSerializer()
    user2 = UserPublicProfileSerializer()

    class Meta:
        model = Thread
        fields = ['id', 'user1', 'user2', 'created_at']


class ThreadCreateSerializer(serializers.Serializer):
    id = serializers.UUIDField(read_only=True)
    target_user_id = serializers.UUIDField()
    target_user = None # will be set in validation

    def validate_target_user_id(self, value):
        try:
            self.target_user = User.objects.get(id=value)
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found.")
        return value