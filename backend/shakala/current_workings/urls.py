from django.urls import path
from .views import (
    create_current_working,
    user_current_workings,
    update_current_working,
    public_user_current_workings,
    # current_working_list,
    # current_working_detail,
    # current_working_search,
    # create_cw_with,
    # cw_with_list,
    # cw_with_detail,
    # cw_with_for_cw,
)

urlpatterns = [
    path('create/', create_current_working, name='current-working-create'),
    path('user/', user_current_workings, name='user-current-workings'),
    path('update/', update_current_working, name='user-current-workings'),

    path('<uuid:user_id>/', public_user_current_workings, name='public-user-current-workings'),
    # path('list/', current_working_list, name='current-working-list'),
    # path('<str:cw_id>/', current_working_detail, name='current-working-detail'),
    # path('search/', current_working_search, name='current-working-search'),

    # path('with/create/', create_cw_with, name='cw-with-create'),
    # path('with/list/', cw_with_list, name='cw-with-list'),
    # path('with/<str:cw_with_id>/', cw_with_detail, name='cw-with-detail'),
    # path('with/cw/<str:cw_id>/', cw_with_for_cw, name='cw-with-for-cw'),
]
