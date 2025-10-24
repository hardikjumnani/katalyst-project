from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django_ratelimit.decorators import ratelimit

from django.contrib.auth import get_user_model, authenticate
from django.shortcuts import get_object_or_404
from .serializers import (
    UserRegisterSerializer,
    UserPersonalSerializer,
    UserPublicProfileSerializer,
    FollowSerializer
    # UserDetailSerializer.
)
from .models import Follow

User = get_user_model()

# POST /users/register/
@api_view(['POST'])
@ratelimit(key='ip', rate='5/m', block=True)
def register_user(request):
    """
    Register a new user. Ratelimited to 5 requests per minute per IP.
    """
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()

        # Generate tokens
        token = TokenObtainPairSerializer.get_token(user)
        access_token = str(token.access_token)
        refresh_token = str(token)

        public_serializer = UserPersonalSerializer(user)
        return Response({
            "user": public_serializer.data,
            "access_token": access_token,
            "refresh_token": refresh_token,
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# POST /users/login/
@api_view(['POST'])
@ratelimit(key='ip', rate='5/m', block=True)
def login_user(request):
    """
    Login with email and password.
    Returns access and refresh tokens along with user data.
    """
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {"detail": "Both email and password are required."},
            status=status.HTTP_400_BAD_REQUEST
        )

    user = authenticate(request, username=email, password=password)

    if user is not None:
        if not user.is_active:
            return Response(
                {"detail": "This account is disabled."},
                status=status.HTTP_403_FORBIDDEN
            )

        # 👇 Generate JWT tokens
        token_serializer = TokenObtainPairSerializer()
        tokens = token_serializer.get_token(user)
        access_token = str(tokens.access_token)
        refresh_token = str(tokens)

        user_serializer = UserPersonalSerializer(user)

        return Response({
            "user": user_serializer.data,
            "access_token": access_token,
            "refresh_token": refresh_token,
        }, status=status.HTTP_200_OK)

    return Response(
        {"detail": "Invalid email or password."},
        status=status.HTTP_401_UNAUTHORIZED
    )

# GET,PATCH /users/me/
@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', block=True)
def user_me(request):
    user = request.user

    if request.method == 'GET':
        serializer = UserPersonalSerializer(user)
        return Response({
            "detail": "User fetched successfully",
            "data": serializer.data
        }, status=status.HTTP_200_OK)

    elif request.method == 'PATCH':
        serializer = UserPersonalSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                "detail": "User updated successfully",
                "data": serializer.data
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', block=True)
def public_user_profile(request, user_id):
    user = get_object_or_404(User, id=user_id)
    serializer = UserPublicProfileSerializer(user)
    return Response({
        "detail": "User fetched successfully",
        "data": serializer.data
    }, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='15/m', block=True)
def all_users(request):
    try:
        users = User.objects.filter(is_active=True, is_staff=False, disabled=False)
        serializer = UserPublicProfileSerializer(users, many=True)
        return Response({
                "detail": "Users fetched successfully",
                "data": serializer.data
            }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {"detail": f"An error occurred: {str(e)}"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


# # ========FOLLOWING=============
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='30/m', block=True)
def follow_user(request):
    """
    Authenticated user follows another user.
    Payload: { "followee": "<user_id>" }
    """
    follower = request.user
    followee_id = request.data.get('followee')

    if str(follower.id) == followee_id:
        return Response({"detail": "You cannot follow yourself."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        followee = User.objects.get(id=followee_id)
    except User.DoesNotExist:
        return Response({"detail": "User to follow not found."}, status=status.HTTP_404_NOT_FOUND)

    # Check if already following
    if Follow.objects.filter(follower=follower, followee=followee).exists():
        return Response({"detail": "You are already following this user."}, status=status.HTTP_400_BAD_REQUEST)

    follow = Follow.objects.create(follower=follower, followee=followee)
    serializer = FollowSerializer(follow)
    return Response({"detail": "Successfully followed.", "data": serializer.data}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='30/m', block=True)
def unfollow_user(request):
    """
    Authenticated user unfollows another user.
    Payload: { "followee": "<user_id>" }
    """
    follower = request.user
    followee_id = request.data.get('followee')

    try:
        followee = User.objects.get(id=followee_id)
    except User.DoesNotExist:
        return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)

    follow = Follow.objects.filter(follower=follower, followee=followee).first()
    if not follow:
        return Response({"detail": "You are not following this user."}, status=status.HTTP_400_BAD_REQUEST)

    follow.delete()
    return Response({"detail": "Successfully unfollowed."}, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', block=True)
def list_followers(request, user_id):
    """
    List all followers of a user.
    """
    user = get_object_or_404(User, id=user_id)
    followers = user.followers.all()
    serializer = UserPublicProfileSerializer([f.follower for f in followers], many=True)
    return Response({"detail": "Successfully fetched followers", "data": serializer.data}, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', block=True)
def list_following(request, user_id):
    """
    List all users the specified user is following.
    """
    user = get_object_or_404(User, id=user_id)
    following = user.following.all()
    serializer = UserPublicProfileSerializer([f.followee for f in following], many=True)
    return Response({"detail": "Successfully fetched followers", "data": serializer.data}, status=status.HTTP_200_OK)


# Connections
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', block=True)
def list_connections(request):
    """
    Get users the authenticated user is connected to (followers + following).
    """
    user = request.user

    followers = Follow.objects.filter(followee=user).values_list('follower', flat=True)
    following = Follow.objects.filter(follower=user).values_list('followee', flat=True)

    connected_user_ids = set(followers).intersection(set(following))
    connected_users = User.objects.filter(id__in=connected_user_ids)

    serializer = UserPublicProfileSerializer(connected_users, many=True)
    return Response({
        "detail": "Successfully fetched connections",
        "data": serializer.data
    }, status=status.HTTP_200_OK)


# # =========================

# # GET /users/list/
# @api_view(['GET'])
# def user_list(request):
#     users = User.objects.all()
#     serializer = UserSerializer(users, many=True)
#     return Response(serializer.data)

# # GET /users/search/?q=<query>
# @api_view(['GET'])
# @ratelimit(key='ip', rate='5/m', block=True)
# def user_search(request):
#     query = request.GET.get('q', '')
#     users = User.objects.filter(Q(name__icontains=query) | Q(email__icontains=query))
#     serializer = UserSerializer(users, many=True)
#     return Response(serializer.data)

# # POST /users/change-password/
# @api_view(['POST'])
# @ratelimit(key='ip', rate='1/m', block=True)
# @permission_classes([permissions.IsAuthenticated])
# def change_password(request):
#     user = request.user
#     user_obj = get_object_or_404(User, user_id=user.username)
#     old_password = request.data.get('old_password')
#     new_password = request.data.get('new_password')
#     if not old_password or not new_password:
#         return Response({'detail': 'Both old and new passwords are required.'}, status=status.HTTP_400_BAD_REQUEST)
#     if not check_password(old_password, user_obj.password):
#         return Response({'detail': 'Old password is incorrect.'}, status=status.HTTP_400_BAD_REQUEST)
#     user_obj.password = make_password(new_password)
#     user_obj.save()
#     return Response({'detail': 'Password changed successfully.'})

# # POST /users/reset-password/
# @api_view(['POST'])
# @ratelimit(key='ip', rate='1/m', block=True)
# def reset_password(request):
#     email = request.data.get('email')
#     new_password = request.data.get('new_password')
#     user_obj = User.objects.filter(email=email).first()
#     if not user_obj:
#         return Response({'detail': 'User with this email not found.'}, status=status.HTTP_404_NOT_FOUND)
#     if not new_password:
#         return Response({'detail': 'New password required.'}, status=status.HTTP_400_BAD_REQUEST)
#     user_obj.password = make_password(new_password)
#     user_obj.save()
#     return Response({'detail': 'Password reset successfully.'})
