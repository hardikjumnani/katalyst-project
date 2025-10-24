from django.db import models
from users.models import User
import uuid

class SkillLevel(models.TextChoices):
    EXPLORING = 'EXPLORING', 'Exploring'
    LEARNING = 'LEARNING', 'Learning'
    APPLYING = 'APPLYING', 'Applying'
    SPECIALIZING = 'SPECIALIZING', 'Specializing'
    MASTERING = 'MASTERING', 'Mastering'

class Skill(models.Model):
    skill_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='skills')
    name = models.CharField(max_length=64)
    level = models.CharField(max_length=32, choices=SkillLevel.choices)
    created_at = models.DateField(auto_now_add=True)
    disabled = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name}, {self.level} ({self.skill_id})"
