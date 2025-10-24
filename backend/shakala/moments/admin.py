
from django.contrib import admin
from .models import Moment, MomentReaction, MomentComment, CommentReaction

@admin.register(Moment)
class MomentAdmin(admin.ModelAdmin):
    list_display = ("moment_id", "user", "title", "description", "created_at", "image", "disabled", "impactful")

@admin.register(MomentReaction)
class MomentReactionAdmin(admin.ModelAdmin):
    list_display = ("moment", "user", "reaction")

@admin.register(MomentComment)
class MomentCommentAdmin(admin.ModelAdmin):
    list_display = ("comment_id", "moment", "user", "description")

@admin.register(CommentReaction)
class CommentReactionAdmin(admin.ModelAdmin):
    list_display = ("comment", "user", "reaction")
