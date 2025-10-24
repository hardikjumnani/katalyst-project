from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.forms import ReadOnlyPasswordHashField
from django import forms

from .models import User, Follow


# 1. Custom form for adding users
class UserCreationForm(forms.ModelForm):
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput)
    password2 = forms.CharField(label='Confirm Password', widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = ('email', 'name', 'gender', 'phone_no', 'city', 'state', 'country')

    def clean_password2(self):
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise forms.ValidationError("Passwords do not match.")
        return password2

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])  # 🔐 Secure password hashing
        if commit:
            user.save()
        return user


# 2. Custom form for updating users
class UserChangeForm(forms.ModelForm):
    password = ReadOnlyPasswordHashField(label=_("Password"))

    class Meta:
        model = User
        fields = '__all__'

    def clean_password(self):
        return self.initial["password"]


# 3. Admin interface
class UserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = UserCreationForm
    model = User

    list_display = ('email', 'id', 'name', 'profile_image', 'is_staff', 'is_superuser', 'disabled')
    list_filter = ('is_staff', 'is_superuser', 'gender', 'country', 'disabled')
    search_fields = ('email', 'name', 'phone_no')
    ordering = ('email',)
    readonly_fields = ('last_login', 'joined_at')

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal Info'), {'fields': ('name', 'gender', 'headline', 'about', 'phone_no', 'city', 'state', 'country')}),
        (_('Social Links'), {'fields': ('github_link', 'linkedin_link')}),
        (_('Permissions'), {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Important Dates'), {'fields': ('last_login', 'joined_at')}),
        (_('Status'), {'fields': ('disabled',)}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'name', 'gender', 'phone_no', 'city', 'state', 'country', 'password1', 'password2')}
        ),
    )

class FollowAdmin(admin.ModelAdmin):
    list_display = ('follower', 'followee', 'followed_at')
    search_fields = ('follower__email', 'followee__email')
    list_filter = ('followed_at',)
    ordering = ('-followed_at',)


admin.site.register(User, UserAdmin)
admin.site.register(Follow, FollowAdmin)
