from rest_framework import serializers
from .models import Report
from moments.models import Moment, MomentComment
from django.core.exceptions import ValidationError

class ReportSerializer(serializers.ModelSerializer):
    moment = serializers.PrimaryKeyRelatedField(
        queryset=Moment.objects.all(), allow_null=True, required=False
    )
    comment = serializers.PrimaryKeyRelatedField(
        queryset=MomentComment.objects.all(), allow_null=True, required=False
    )

    class Meta:
        model = Report
        fields = '__all__'
        read_only_fields = ('user', 'reviewed', 'report_id', 'created_at')

    def validate(self, data):
        moment = data.get('moment')
        comment = data.get('comment')

        if (moment is None and comment is None) or (moment and comment):
            raise serializers.ValidationError("Exactly one of 'moment' or 'comment' must be provided.")

        return data

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)