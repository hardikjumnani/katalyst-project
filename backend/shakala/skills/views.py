from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_ratelimit.decorators import ratelimit
from .models import Skill
from .serializers import SkillSerializer, PublicSkillSerializer

# POST /skills/create/
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def create_skill(request):
    serializer = SkillSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({"detail": "Skill saved", "data": serializer.data}, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# GET /skills/user/
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def user_skills(request):
    skills = Skill.objects.filter(user=request.user, disabled=False)
    serializer = SkillSerializer(skills, many=True)
    return Response({
        "detail": "Fetched skills successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)

# PATCH /skills/update/
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='5/m', block=True)
def update_skill(request):
    skill_id = request.data.get('skill_id')
    if not skill_id:
        return Response({"detail": "skill_id is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        skill = Skill.objects.get(skill_id=skill_id, user=request.user)
    except Skill.DoesNotExist:
        return Response({"detail": "Skill not found."}, status=status.HTTP_404_NOT_FOUND)

    serializer = SkillSerializer(skill, data=request.data, context={'request': request}, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response({"detail": "Updated successfully", "data": serializer.data}, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='20/m', block=True)
def public_user_skills(request, user_id):
    skills = Skill.objects.filter(user__id=user_id, disabled=False)
    serializer = PublicSkillSerializer(skills, many=True)
    return Response({
        "detail": "Fetched skills successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)