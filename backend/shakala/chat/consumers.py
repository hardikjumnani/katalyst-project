# chat/consumers.py

import uuid
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.db.models import Q
from .models import Thread, Message
from .serializers import MessageSerializer

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.thread_id = self.scope['url_route']['kwargs']['thread_id']
        self.room_group_name = f'chat_{self.thread_id}'
        self.user = self.scope['user']

        # Reject if not authenticated
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return

        # Reject if user is not in thread
        is_member = await self.is_user_in_thread(self.thread_id, self.user.id)
        if not is_member:
            await self.close()
            return

        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name') and self.room_group_name:
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']

        saved_message = await self.save_message(self.user.id, self.thread_id, message)

        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': saved_message['content'],
                'sender': saved_message['sender'],
                'timestamp': saved_message['timestamp']
            }
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event))

    @database_sync_to_async
    def is_user_in_thread(self, thread_id, user_id):
        return Thread.objects.filter(id=thread_id).filter(Q(user1_id=user_id) | Q(user2_id=user_id)).exists()

    @database_sync_to_async
    def save_message(self, user_id, thread_id, content):
        thread = Thread.objects.filter(
            id=thread_id
        ).filter(
            Q(user1_id=user_id) | Q(user2_id=user_id)
        ).first()

        if not thread:
            raise ValueError("Unauthorized message attempt.")

        message = Message.objects.create(
            thread=thread,
            sender_id=user_id,
            content=content
        )

        # Use the serializer to structure the data
        serialized = MessageSerializer(message).data

        return {
            'id': serialized['id'],
            'content': serialized['content'],
            'sender': serialized['sender'],         # Full user object
            'timestamp': serialized['timestamp'],
        }
    