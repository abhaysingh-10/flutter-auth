from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'full_name', 'auth_provider', 'is_verified', 'is_staff', 'created_at')
    search_fields = ('email', 'full_name')
    list_filter = ('auth_provider', 'is_verified', 'is_staff')
    ordering = ('-created_at',)
