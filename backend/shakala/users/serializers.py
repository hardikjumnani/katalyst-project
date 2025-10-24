from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from .models import User, Follow

class UserPersonalSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'name', 'gender', 'headline', 'about',
            'github_link', 'linkedin_link',
            'city', 'state', 'country',
            'profile_image'
        ]

class UserRegisterSerializer(serializers.ModelSerializer): # for registering first time
    profile_image = serializers.ImageField(required=False, allow_null=True)
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = [
            'email', 'password', 'password2', 'name', 'gender', 'headline',
            'phone_no', 'city', 'state', 'country',
            'profile_image',
        ]
        write_only_fields = ['password', 'password2']

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists.")
        return value

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": _("Passwords do not match.")})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)  # 🔐 Hashing is done here
        user.save()
        return user
    
class UserPublicProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'name', 'headline', 'about',
            'github_link', 'linkedin_link',
            'city', 'state', 'country', 'profile_image'
        ]
        read_only_fields = fields

class FollowSerializer(serializers.ModelSerializer):
    follower = serializers.ReadOnlyField(source='follower.id')
    followee = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())

    class Meta:
        model = Follow
        fields = ['id', 'follower', 'followee', 'followed_at']

# class UserDetailSerializer(serializers.ModelSerializer):
#     email = serializers.EmailField(read_only=True)  # Cannot change email after creation

#     class Meta:
#         model = User
#         exclude = ['password', 'is_staff', 'is_superuser', 'disabled', 'joined_at']

#     def update(self, instance, validated_data):
#         for attr, value in validated_data.items():
#             setattr(instance, attr, value)
#         instance.save()
#         return instance