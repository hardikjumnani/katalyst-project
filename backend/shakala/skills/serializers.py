from rest_framework import serializers
from .models import Skill
import uuid

class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = '__all__'
        read_only_fields = ("skill_id", "user", "created_at", "disabled")

    def create(self, validated_data):
        return Skill.objects.create(
            user=self.context['request'].user,
            skill_id=str(uuid.uuid4()),
            **validated_data
        )
    
class PublicSkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = [
            'name', 'level',
            'created_at'
        ]
        read_only_fields = fields
