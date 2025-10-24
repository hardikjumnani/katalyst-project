from django.urls import path, re_path
from .views import (
    create_moment,
    moment_list,
    disable_moment,

    toggle_moment_reaction,

    create_moment_comment,
    moment_comment_list,
    
    toggle_comment_reaction,
    comment_reaction_list,
)

urlpatterns = [
    path('create/', create_moment, name='moment-create'),
    path('list/', moment_list, name='moment-list'),
    path('disable/', disable_moment, name='moment-disable'),

    path('reactions/toggle/', toggle_moment_reaction, name='moment-reaction-toggle'),

    path('comments/create/', create_moment_comment, name='moment-comment-create'),
    path('comments/', moment_comment_list, name='moment-comment-list'),

    path('comment-reactions/toggle/', toggle_comment_reaction, name='comment-reaction-toggle'),
    path('comment-reactions/', comment_reaction_list, name='comment-reaction-list'),
]

# path('<str:moment_id>/', moment_detail, name='moment-detail'),
# path('user/<str:user_id>/', user_moments, name='user-moments'),
# path('search/', moment_search, name='moment-search'),
# path('reactions/', moment_reaction_list, name='moment-reaction-list'),
# path('reactions/<str:moment_id>/<str:user_id>/', moment_reaction_detail, name='moment-reaction-detail'),
# path('reactions/<str:moment_id>/', moment_reactions_for_moment, name='moment-reactions-for-moment'),
# path('comments/<str:comment_id>/', moment_comment_detail, name='moment-comment-detail'),
# path('comments/moment/<str:moment_id>/', moment_comments_for_moment, name='moment-comments-for-moment'),
# path('comment-reactions/<str:comment_id>/<str:user_id>/', comment_reaction_detail, name='comment-reaction-detail'),
# path('comment-reactions/<str:comment_id>/', comment_reactions_for_comment, name='comment-reactions-for-comment'),