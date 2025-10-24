
from django.contrib import admin
from .models import Skill

@admin.register(Skill)
class SkillAdmin(admin.ModelAdmin):
    list_display = ("skill_id", "user", "name", "level", "created_at", "disabled")
