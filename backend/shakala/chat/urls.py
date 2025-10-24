from django.urls import path
from .views import get_or_create_thread, get_thread_messages

urlpatterns = [
    path('thread/', get_or_create_thread, name='get_or_create_thread'),
    path('messages/<uuid:thread_id>/', get_thread_messages, name='get_thread_messages')
]