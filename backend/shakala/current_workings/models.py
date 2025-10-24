from django.db import models
from users.models import User
import uuid

class CurrentWorking(models.Model):
    cw_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='current_workings')
    title = models.CharField(max_length=255)
    description = models.TextField(max_length=1024, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    disabled = models.BooleanField(default=False)
    impactful = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.title} ({self.cw_id})"

# class CWWith(models.Model):
#     cw_with_id = models.CharField(primary_key=True, max_length=255)
#     cw = models.ForeignKey(CurrentWorking, on_delete=models.CASCADE, related_name='cw_withs')
#     with_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cw_withs')

#     def __str__(self):
#         return f"With {self.with_user} in {self.cw} ({self.cw_with_id})"
