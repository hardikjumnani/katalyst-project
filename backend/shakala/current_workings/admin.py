from django.contrib import admin
from .models import CurrentWorking # , CWWith

@admin.register(CurrentWorking)
class CurrentWorkingAdmin(admin.ModelAdmin):
    list_display = ("cw_id", "user", "title", "description", "created_at", "disabled", "impactful")

# @admin.register(CWWith)
# class CWWithAdmin(admin.ModelAdmin):
#     list_display = ("cw_with_id", "cw", "with_user")
