
from django.contrib import admin
from .models import Education

@admin.register(Education)
class EducationAdmin(admin.ModelAdmin):
    list_display = ("education_id", "user", "school_name", "degree", "field_of_study", "start_date", "end_date", "disabled", "impactful")
