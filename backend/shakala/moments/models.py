from django.db import models
from users.models import User
import uuid

class Reaction(models.TextChoices):
    LIKE = 'LIKE', 'Like'
    CHEERS = 'CHEERS', 'Cheers'
    LOL = 'LOL', 'LOL'
    THANKS = 'THANKS', 'Thanks'
    HAIL = 'HAIL', 'Hail'

class Moment(models.Model):
    moment_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='moments')
    title = models.TextField(max_length=255, null=True)
    description = models.TextField(max_length=2048)
    created_at = models.DateTimeField(auto_now_add=True)
    image = models.ImageField(upload_to='moments/', blank=True, null=True)
    disabled = models.BooleanField(default=False)
    impactful = models.BooleanField(default=False)

    def __str__(self):
        return f"Moment {self.moment_id} by {self.user}"

class MomentReaction(models.Model):
    moment = models.ForeignKey(Moment, on_delete=models.CASCADE, related_name='reactions')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='moment_reactions')
    reaction = models.CharField(max_length=10, choices=Reaction.choices)

    class Meta:
        unique_together = ('moment', 'user')

    def __str__(self):
        return f"{self.reaction} by {self.user} on {self.moment}"

class MomentComment(models.Model):
    comment_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    moment = models.ForeignKey(Moment, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='moment_comments')
    description = models.TextField()

    def __str__(self):
        return f"Comment {self.comment_id} by {self.user}"

class CommentReaction(models.Model):
    comment = models.ForeignKey(MomentComment, on_delete=models.CASCADE, related_name='reactions')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comment_reactions')
    reaction = models.CharField(max_length=10, choices=Reaction.choices)

    class Meta:
        unique_together = ('comment', 'user')

    def __str__(self):
        return f"{self.reaction} by {self.user} on comment {self.comment.comment_id}"
