from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.register_user, name='register'),
    path('login/', views.login_user, name='login'),
    path('me/', views.user_me, name='user-me'),
    path('list/', views.all_users, name='all-users'),

    path('follow/', views.follow_user, name='follow-user'),
    path('unfollow/', views.unfollow_user, name='unfollow-user'),

    path('connections/', views.list_connections, name='list-connections'),

    path('<str:user_id>/followers/', views.list_followers, name='list-followers'),
    path('<str:user_id>/following/', views.list_following, name='list-following'),
    path('<str:user_id>/', views.public_user_profile, name='user-public-profile'),
]