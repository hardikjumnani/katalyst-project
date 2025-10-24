from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_ratelimit.decorators import ratelimit
from .models import Education
from .serializers import EducationSerializer, PublicEducationSerializer

# POST /educations/create/
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def create_education(request):
    serializer = EducationSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({"detail": "Education created", "data": serializer.data}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# GET /educations/user/
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def user_educations(request):
    educations = Education.objects.filter(user=request.user, disabled=False)
    serializer = EducationSerializer(educations, many=True)
    return Response({
        "detail": "Fetched educations successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)

# PATCH /educations/update/
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def update_education(request):
    education_id = request.data.get('education_id')
    if not education_id:
        return Response({"detail": "education_id is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        education = Education.objects.get(education_id=education_id, user=request.user)
    except Education.DoesNotExist:
        return Response({"detail": "Education not found."}, status=status.HTTP_404_NOT_FOUND)

    serializer = EducationSerializer(
        education,
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
def public_user_educations(request, user_id):
    educations = Education.objects.filter(user__id=user_id, disabled=False)
    serializer = PublicEducationSerializer(educations, many=True)
    return Response({
        "detail": "Fetched educations successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)
