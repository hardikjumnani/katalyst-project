from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django_ratelimit.decorators import ratelimit
from django.db.models import Q
from .models import Moment, MomentReaction, MomentComment, CommentReaction
from .serializers import MomentSerializer, MomentReactionSerializer, MomentCommentSerializer, CommentReactionSerializer

# Moment CRUD
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='5/m', method='POST', block=True)
def create_moment(request):
    serializer = MomentSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            "detail": "Moment created successfully",
            "data": serializer.data
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def moment_list(request):
    try:
        moments = Moment.objects.filter(disabled=False).order_by('-created_at')
        serializer = MomentSerializer(moments, many=True, context={'request': request})

        return Response({
            "detail": "Moments fetched successfully",
            "data": serializer.data
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response(
            {"detail": f"An error occurred: {str(e)}"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
# @ratelimit(key='ip', rate='10/m', block=True)
def disable_moment(request):
    moment_id = request.data.get('moment_id')

    if not moment_id:
        return Response({"detail": "moment_id is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        moment = Moment.objects.get(moment_id=moment_id)
    except Moment.DoesNotExist:
        return Response({"detail": "Moment not found."}, status=status.HTTP_404_NOT_FOUND)

    if moment.user != request.user:
        return Response({"detail": "You do not have permission to disable this moment."},
                        status=status.HTTP_403_FORBIDDEN)

    moment.disabled = True
    moment.save()

    return Response({"detail": "Moment disabled successfully."}, status=status.HTTP_200_OK)

# Moment Reactions
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', method='POST', block=True)
def toggle_moment_reaction(request):
    moment_id = request.data.get('moment')
    reaction = request.data.get('reaction')

    if not moment_id or not reaction:
        return Response({"detail": "moment and reaction are required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        moment_reaction = MomentReaction.objects.get(moment_id=moment_id, user=request.user)

        if moment_reaction.reaction == reaction:
            # Same reaction → remove it (toggle off)
            moment_reaction.delete()
            return Response({"detail": "Reaction removed."}, status=status.HTTP_204_NO_CONTENT)
        else:
            # Different reaction → update it
            moment_reaction.reaction = reaction
            moment_reaction.save()
            serializer = MomentReactionSerializer(moment_reaction)
            return Response(serializer.data, status=status.HTTP_200_OK)

    except MomentReaction.DoesNotExist:
        # No reaction yet → create new
        data = {
            "moment": moment_id,
            "reaction": reaction
        }
        serializer = MomentReactionSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['GET'])
@ratelimit(key='ip', rate='10/m', block=True)
def moment_reaction_list(request):
    reactions = MomentReaction.objects.all()
    serializer = MomentReactionSerializer(reactions, many=True)
    return Response(serializer.data)

# Moment Comments
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', method='POST', block=True)
def create_moment_comment(request):
    serializer = MomentCommentSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            "detail": "Comment created successfully",
            "data": serializer.data
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@ratelimit(key='ip', rate='20/m', block=True)
def moment_comment_list(request):
    moment_id = request.query_params.get('moment_id')
    if moment_id:
        comments = MomentComment.objects.filter(moment__moment_id=moment_id).order_by('-created_at')
    else:
        return Response(
            {"detail": "moment_id is required"},
            status=status.HTTP_400_BAD_REQUEST
        )

    serializer = MomentCommentSerializer(comments, many=True, context={'request': request})
    return Response({
        "detail": "Comments retrieved successfully",
        "data": serializer.data
    })

# Comment Reactions
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', method='POST', block=True)
def toggle_comment_reaction(request):
    comment_id = request.data.get('comment')
    reaction = request.data.get('reaction')

    if not comment_id or not reaction:
        return Response({"detail": "comment and reaction are required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        comment_reaction = CommentReaction.objects.get(comment_id=comment_id, user=request.user)

        if comment_reaction.reaction == reaction:
            # Same reaction → remove (toggle off)
            comment_reaction.delete()
            return Response({"detail": "Reaction removed."}, status=status.HTTP_204_NO_CONTENT)
        else:
            # Different reaction → update
            comment_reaction.reaction = reaction
            comment_reaction.save()
            serializer = CommentReactionSerializer(comment_reaction)
            return Response(serializer.data, status=status.HTTP_200_OK)

    except CommentReaction.DoesNotExist:
        # Create new reaction
        data = {
            "comment": comment_id,
            "reaction": reaction
        }
        serializer = CommentReactionSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@ratelimit(key='ip', rate='20/m', block=True)
def comment_reaction_list(request):
    comment_id = request.query_params.get('comment_id')
    if comment_id:
        reactions = CommentReaction.objects.filter(comment__comment_id=comment_id)
    else:
        reactions = CommentReaction.objects.all()

    serializer = CommentReactionSerializer(reactions, many=True)
    return Response(serializer.data)
