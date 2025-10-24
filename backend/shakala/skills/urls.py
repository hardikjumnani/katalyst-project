from django.urls import path
from .views import create_skill, user_skills, update_skill, public_user_skills

urlpatterns = [
    path('create/', create_skill, name='skill-create'),
    path('user/', user_skills, name='user-skills'),
    path('update/', update_skill, name='skill-update'),

    path('<uuid:user_id>/', public_user_skills, name='public-user-skills'),
]