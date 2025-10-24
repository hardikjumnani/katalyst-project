from rest_framework import serializers
from .models import CurrentWorking # , CWWith
import uuid

class CurrentWorkingSerializer(serializers.ModelSerializer):
    class Meta:
        model = CurrentWorking
        fields = '__all__'
        read_only_fields = ("cw_id", "user", "created_at", "disabled", "impactful")
    
    def create(self, validated_data):
        return CurrentWorking.objects.create(
            user=self.context["request"].user,
            cw_id=str(uuid.uuid4()),
            **validated_data
        )

class PublicCurrentWorkingSerializer(serializers.ModelSerializer):
    class Meta:
        model = CurrentWorking
        fields = [
            'title', 'description',
            'created_at'
        ]
        read_only_fields = fields

# class CWWithSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = CWWith
#         fields = '__all__'
