from django.urls import path
from .views import create_education, user_educations, update_education, public_user_educations

urlpatterns = [
    path('create/', create_education, name='education-create'),
    path('user/', user_educations, name='user-educations'),
    path('update/', update_education, name='education-update'),

    path('<uuid:user_id>/', public_user_educations, name='public-user-educations'),
]
