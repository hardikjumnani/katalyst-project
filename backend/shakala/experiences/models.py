from django.db import models
from users.models import User
import uuid

class Experience(models.Model):
    experience_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='experiences')
    company_name = models.CharField(max_length=255)
    title = models.CharField(max_length=64)
    description = models.CharField(max_length=1024, null=True)
    city_or_online = models.CharField(max_length=64, blank=True, null=True) # <ONLINE>
    state = models.CharField(max_length=64, blank=True, null=True)
    country = models.CharField(max_length=64, blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField(blank=True, null=True)
    disabled = models.BooleanField(default=False)
    impactful = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.title} at {self.company_name} ({self.experience_id})"
