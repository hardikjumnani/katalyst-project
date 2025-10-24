from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_ratelimit.decorators import ratelimit
from .models import Report
from .serializers import ReportSerializer

@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def create_report(request):
    serializer = ReportSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)