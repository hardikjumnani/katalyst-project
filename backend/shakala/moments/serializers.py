from rest_framework import serializers
from .models import Moment, MomentReaction, MomentComment, CommentReaction
from users.serializers import UserPersonalSerializer
import uuid

from rest_framework import serializers

class MomentSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    user = UserPersonalSerializer(read_only=True)
    reaction_count = serializers.SerializerMethodField()
    has_reacted = serializers.SerializerMethodField()

    class Meta:
        model = Moment
        fields = '__all__'
        read_only_fields = ("moment_id", "user", "created_at", "disabled", "impactful")
        write_only_fields = ("image",)

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)  # ✅ full URL
        return None

    def create(self, validated_data):
        return Moment.objects.create(
            user=self.context["request"].user,
            moment_id=uuid.uuid4(),
            **validated_data
        )
    
    def get_reaction_count(self, obj): 
        return obj.reactions.count()
    
    def get_has_reacted(self, obj):
        user = self.context.get('request').user
        return obj.reactions.filter(user=user).exists()

class MomentReactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MomentReaction
        fields = '__all__'
        read_only_fields = ('user',)

class MomentCommentSerializer(serializers.ModelSerializer):
    user = UserPersonalSerializer(read_only=True)
    reaction_count = serializers.SerializerMethodField()
    has_reacted = serializers.SerializerMethodField()

    class Meta:
        model = MomentComment
        fields = '__all__'
        read_only_fields = ['user', 'comment_id', 'created_at']

    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['user'] = request.user
        return super().create(validated_data)
    
    def get_reaction_count(self, obj):
        return obj.reactions.count()
    
    def get_has_reacted(self, obj):
        user = self.context.get('request').user
        return obj.reactions.filter(user=user).exists()

class CommentReactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommentReaction
        fields = '__all__'
        read_only_fields = ('user',)
