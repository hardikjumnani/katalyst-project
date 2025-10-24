
from django.contrib import admin
from .models import Experience

@admin.register(Experience)
class ExperienceAdmin(admin.ModelAdmin):
    list_display = ("experience_id", "user", "company_name", "title", "description", "city_or_online", "state", "country", "start_date", "end_date", "disabled", "impactful")
