from django.contrib import admin
from .models import Message, Thread

@admin.register(Thread)
class ThreadAdmin(admin.ModelAdmin):
    list_display = ('id', 'user1', 'user2', 'created_at')
    search_fields = ('user1__username', 'user2__username')

@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('id', 'thread', 'sender', 'receiver', 'short_content', 'timestamp')
    list_filter = ('timestamp',)
    search_fields = ('content', 'sender__username', 'thread__user1__username', 'thread__user2__username')

    def receiver(self, obj):
        # Receiver is the other user in the thread who is not the sender
        return obj.thread.get_other_user(obj.sender)
    receiver.short_description = 'Receiver'

    def short_content(self, obj):
        return obj.content[:50] + ('...' if len(obj.content) > 50 else '')
    short_content.short_description = 'Content Preview'
