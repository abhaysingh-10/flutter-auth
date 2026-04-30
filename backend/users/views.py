from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import RegisterSerializer, UserSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.db.models import Q

from rest_framework import serializers

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Remove the field automatically added by SimpleJWT based on USERNAME_FIELD
        if User.USERNAME_FIELD in self.fields:
            del self.fields[User.USERNAME_FIELD]
        # Add our custom 'username' field which will take either email or username
        self.fields['username'] = serializers.CharField()

    def validate(self, attrs):
        identifier = attrs.get("username")
        password = attrs.get("password")

        user = User.objects.filter(Q(email=identifier) | Q(username=identifier)).first()

        if user and user.check_password(password):
            self.user = user
            refresh = self.get_token(self.user)

            data = {}
            data["refresh"] = str(refresh)
            data["access"] = str(refresh.access_token)
            return data

        raise serializers.ValidationError("No active account found with the given credentials")

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['email'] = user.email
        token['username'] = user.username
        return token

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

import random
from django.utils import timezone
from datetime import timedelta

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

    def perform_create(self, serializer):
        user = serializer.save()
        # Generate 6-digit OTP
        otp = f"{random.randint(100000, 999999)}"
        user.otp = otp
        user.otp_expiry = timezone.now() + timedelta(minutes=10)
        user.save()
        
        # PRODUCTION NOTE: Here you would use an email service (SendGrid/AWS SES)
        print(f"\n\n[PRODUCTION SIMULATION] Sending OTP {otp} to {user.email}\n\n")

class VerifyEmailView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        email = request.data.get('email')
        otp = request.data.get('otp')
        
        try:
            user = User.objects.get(email=email, otp=otp, otp_expiry__gt=timezone.now())
            user.is_verified = True
            user.otp = None
            user.otp_expiry = None
            user.save()
            return Response({"message": "Email verified successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "Invalid or expired OTP"}, status=status.HTTP_400_BAD_REQUEST)

class ResendOTPView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        email = request.data.get('email')
        try:
            user = User.objects.get(email=email)
            otp = f"{random.randint(100000, 999999)}"
            user.otp = otp
            user.otp_expiry = timezone.now() + timedelta(minutes=10)
            user.save()
            print(f"\n\n[PRODUCTION SIMULATION] Resending OTP {otp} to {user.email}\n\n")
            return Response({"message": "OTP resent successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class LogoutView(generics.GenericAPIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        try:
            refresh_token = request.data["refresh"]
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response(status=status.HTTP_205_RESET_CONTENT)
        except Exception:
            return Response(status=status.HTTP_400_BAD_REQUEST)

class UserDetailView(generics.RetrieveAPIView):
    permission_classes = (permissions.IsAuthenticated,)
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user
