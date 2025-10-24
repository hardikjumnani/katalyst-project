from rest_framework import serializers
from .models import Experience
import uuid
from django.utils import timezone

class ExperienceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Experience
        fields = '__all__'
        read_only_fields = ('experience_id', 'user', 'disabled', 'impactful')

    def validate(self, data):
        start_date = data.get('start_date')
        end_date = data.get('end_date')

        # Handle 'Present' from frontend (which comes as string)
        request_end_date = self.initial_data.get('end_date')

        if request_end_date == 'Present':
            end_date = timezone.now().date()

        if end_date and start_date and end_date < start_date:
            raise serializers.ValidationError(
                {"end_date": "End date must be after start date."}
            )

        return data

    def create(self, validated_data):
        return Experience.objects.create(
            user=self.context["request"].user,
            experience_id=uuid.uuid4(),
            **validated_data
        )
    
class PublicExperienceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Experience
        fields = [
            'company_name', 'title', 'description',
            'city_or_online', 'state', 'country',
            'start_date', 'end_date'
        ]
        read_only_fields = fields