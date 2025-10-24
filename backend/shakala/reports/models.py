from django.db import models
from django.forms import ValidationError
from users.models import User
from moments.models import Moment, MomentComment
import uuid

class Report(models.Model):
    report_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reports')
    moment = models.ForeignKey(Moment, on_delete=models.CASCADE, null=True, blank=True, related_name='reports')
    comment = models.ForeignKey(MomentComment, on_delete=models.CASCADE, null=True, blank=True, related_name='reports')
    created_at = models.DateTimeField(auto_now_add=True)
    reviewed = models.BooleanField(default=False)

    def clean(self):
        # Validate that only one of moment or comment is provided
        if (self.moment is None and self.comment is None) or (self.moment and self.comment):
            raise ValidationError("Exactly one of 'moment' or 'comment' must be provided.")

    def __str__(self):
        if self.moment:
            return f"Report on Moment {self.moment.moment_id} by {self.user}"
        elif self.comment:
            return f"Report on Comment {self.comment.comment_id} by {self.user}"
        return f"Invalid Report by {self.user}"
