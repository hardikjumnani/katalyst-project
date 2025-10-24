from django.contrib import admin
from .models import Report

@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ("report_id", "user", "moment", "comment", "created_at", "reviewed")
    list_editable = ("reviewed",)