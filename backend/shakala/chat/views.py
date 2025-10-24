import uuid
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django_ratelimit.decorators import ratelimit
from django.shortcuts import get_object_or_404

from users.models import User
from .models import Thread, Message
from .serializers import ThreadCreateSerializer, ThreadSerializer, MessageSerializer


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='30/m', block=True)
def get_or_create_thread(request):
    """
    Get or create a private DM thread between the authenticated user and the target user.
    """
    serializer = ThreadCreateSerializer(data=request.data)

    if not serializer.is_valid():
        return Response(
            {"detail": "Invalid data", "errors": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST
        )

    target_user = serializer.target_user

    if str(request.user.id) == str(target_user.id):
        return Response(
            {"detail": "You cannot create a thread with yourself."},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Enforce consistent user1 < user2 ordering
    user1, user2 = sorted([request.user, target_user], key=lambda u: uuid.UUID(str(u.id)))

    thread, created = Thread.objects.get_or_create(user1=user1, user2=user2)
    thread_serializer = ThreadSerializer(thread)

    return Response({
        "detail": "Thread created" if created else "Thread fetched",
        "data": thread_serializer.data
    }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='30/m', block=True)
def get_thread_messages(request, thread_id):
    try:
        thread = Thread.objects.get(id=thread_id)
    except Thread.DoesNotExist:
        return Response({"detail": "Thread not found."}, status=status.HTTP_404_NOT_FOUND)

    # Check user membership
    if request.user != thread.user1 and request.user != thread.user2:
        return Response({"detail": "Unauthorized."}, status=status.HTTP_403_FORBIDDEN)

    messages = Message.objects.filter(thread=thread).order_by('timestamp')
    serializer = MessageSerializer(messages, many=True)

    return Response({"detail": "Chat history retrived successfully.", "data": serializer.data}, status=status.HTTP_200_OK)
