from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_ratelimit.decorators import ratelimit
from .models import Experience
from .serializers import ExperienceSerializer, PublicExperienceSerializer

# POST /experiences/create/
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def create_experience(request):
    serializer = ExperienceSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({"detail": "Experience created", "data": serializer.data}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# GET /experiences/user/
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def user_experiences(request):
    experiences = Experience.objects.filter(user=request.user, disabled=False)
    serializer = ExperienceSerializer(experiences, many=True)
    return Response({
        "detail": "Fetched experiences successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)

# PATCH /experiences/update/
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def update_experience(request):
    experience_id = request.data.get('experience_id')
    if not experience_id:
        return Response({"detail": "experience_id is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        experience = Experience.objects.get(experience_id=experience_id, user=request.user)
    except Experience.DoesNotExist:
        return Response({"detail": "Experience not found."}, status=status.HTTP_404_NOT_FOUND)

    serializer = ExperienceSerializer(
        experience,
        data=request.data,
        context={'request': request},
        partial=True
    )
    if serializer.is_valid():
        serializer.save()
        return Response({"detail": "Updated successfully", "data": serializer.data}, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='15/m', block=True)
def public_user_experiences(request, user_id):
    experiences = Experience.objects.filter(user__id=user_id, disabled=False)
    serializer = PublicExperienceSerializer(experiences, many=True)
    return Response({
        "detail": "Fetched experiences successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)
