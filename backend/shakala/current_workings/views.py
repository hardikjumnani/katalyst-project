from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_ratelimit.decorators import ratelimit
from django.shortcuts import get_object_or_404
from django.db.models import Q
from .models import CurrentWorking #, CWWith
from .serializers import CurrentWorkingSerializer, PublicCurrentWorkingSerializer # , CWWithSerializer

@api_view(['POST'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def create_current_working(request):
    serializer = CurrentWorkingSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        try:
            serializer.save()
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({"detail": "Data saved", "data": serializer.data}, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def user_current_workings(request):
    current_workings = CurrentWorking.objects.filter(user=request.user)
    serializer = CurrentWorkingSerializer(current_workings, many=True)
    return Response({
        "detail": "Fetched current workings successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='10/m', block=True)
def update_current_working(request):
    cw_id = request.data.get('cw_id')

    if not cw_id:
        return Response({"detail": "cw_id is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        current_working = CurrentWorking.objects.get(cw_id=cw_id, user=request.user)
    except CurrentWorking.DoesNotExist:
        return Response({"detail": "Current working entry not found."}, status=status.HTTP_404_NOT_FOUND)

    serializer = CurrentWorkingSerializer(
        current_working,
        data=request.data,
        context={'request': request},
        partial=True  # Allows partial updates
    )

    if serializer.is_valid():
        serializer.save()
        return Response({"detail": "Updated successfully", "data": serializer.data}, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@ratelimit(key='ip', rate='12/m', block=True)
def public_user_current_workings(request, user_id):
    current_workings = CurrentWorking.objects.filter(user__id=user_id, disabled=False)
    serializer = PublicCurrentWorkingSerializer(current_workings, many=True)
    return Response({
        "detail": "Fetched current workings successfully.",
        "data": serializer.data
    }, status=status.HTTP_200_OK)

# @api_view(['GET'])
# def current_working_list(request):
#     current_workings = CurrentWorking.objects.all()
#     serializer = CurrentWorkingSerializer(current_workings, many=True)
#     return Response(serializer.data)

# @api_view(['GET', 'PUT', 'DELETE'])
# def current_working_detail(request, cw_id):
#     cw = get_object_or_404(CurrentWorking, cw_id=cw_id)
#     if request.method == 'GET':
#         serializer = CurrentWorkingSerializer(cw)
#         return Response(serializer.data)
#     elif request.method == 'PUT':
#         serializer = CurrentWorkingSerializer(cw, data=request.data, partial=True)
#         if serializer.is_valid():
#             serializer.save()
#             return Response(serializer.data)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
#     elif request.method == 'DELETE':
#         cw.delete()
#         return Response({'detail': 'CurrentWorking deleted.'}, status=status.HTTP_204_NO_CONTENT)

# @api_view(['GET'])
# def current_working_search(request):
#     query = request.GET.get('q', '')
#     current_workings = CurrentWorking.objects.filter(
#         Q(title__icontains=query) |
#         Q(description__icontains=query)
#     )
#     serializer = CurrentWorkingSerializer(current_workings, many=True)
#     return Response(serializer.data)

# # CRUD for CWWith
# @api_view(['POST'])
# def create_cw_with(request):
#     serializer = CWWithSerializer(data=request.data)
#     if serializer.is_valid():
#         serializer.save()
#         return Response(serializer.data, status=status.HTTP_201_CREATED)
#     return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# @api_view(['GET'])
# def cw_with_list(request):
#     cw_withs = CWWith.objects.all()
#     serializer = CWWithSerializer(cw_withs, many=True)
#     return Response(serializer.data)

# @api_view(['GET', 'DELETE'])
# def cw_with_detail(request, cw_with_id):
#     cw_with = get_object_or_404(CWWith, cw_with_id=cw_with_id)
#     if request.method == 'GET':
#         serializer = CWWithSerializer(cw_with)
#         return Response(serializer.data)
#     elif request.method == 'DELETE':
#         cw_with.delete()
#         return Response({'detail': 'CWWith deleted.'}, status=status.HTTP_204_NO_CONTENT)

# @api_view(['GET'])
# def cw_with_for_cw(request, cw_id):
#     cw_withs = CWWith.objects.filter(cw__cw_id=cw_id)
#     serializer = CWWithSerializer(cw_withs, many=True)
#     return Response(serializer.data)
