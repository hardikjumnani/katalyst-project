from django.db import models
from users.models import User
import uuid

class Education(models.Model):
    education_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='educations')
    school_name = models.CharField(max_length=255)
    degree = models.CharField(max_length=255)
    field_of_study = models.CharField(max_length=255, null=True)
    start_date = models.DateField()
    end_date = models.DateField(blank=True, null=True)
    disabled = models.BooleanField(default=False)
    impactful = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.degree} at {self.school_name} ({self.education_id})"
