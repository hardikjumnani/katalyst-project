from rest_framework import serializers
from .models import Education
from django.utils import timezone
import uuid

class EducationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Education
        fields = '__all__'
        read_only_fields = ('education_id', 'user', 'disabled', 'impactful')

    def validate(self, data):
        start_date = data.get('start_date')
        end_date = data.get('end_date')

        request_end_date = self.initial_data.get('end_date')

        if request_end_date == 'Present':
            end_date = timezone.now().date()
            data['end_date'] = end_date

        if end_date and start_date and end_date < start_date:
            raise serializers.ValidationError(
                {"end_date": "End date must be after start date."}
            )

        return data

    def create(self, validated_data):
        return Education.objects.create(
            user=self.context["request"].user,
            education_id=uuid.uuid4(),
            **validated_data
        )

class PublicEducationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Education
        fields = [
            'school_name', 'degree', 'field_of_study',
            'start_date', 'end_date'
        ]
        read_only_fields = fields