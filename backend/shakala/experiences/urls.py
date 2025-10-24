from django.urls import path
from .views import create_experience, user_experiences, update_experience, public_user_experiences

urlpatterns = [
    path('create/', create_experience, name='experience-create'),
    path('user/', user_experiences, name='user-experiences'),
    path('update/', update_experience, name='experience-update'),

    path('<uuid:user_id>/', public_user_experiences, name='public-user-experiences'),
]
