from .models import User,EmailOtp,FriendRequest
from rest_framework import generics,status
from .serializers import UserCreateSerializer,ChangePasswordserializer,UserUpdateSerializer,FriendRequestSerializer,ReceivedFriendRequestSerializer,AcceptFriendRequestSerializer,UserInformationSerializer,UserOnlineStatusSerializer
from .permissions import IsOwnerOrAdmin
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth import authenticate,login
from rest_framework_simplejwt.tokens import RefreshToken
import random
from django.core.mail import send_mail
from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from rest_framework.views import APIView
import os
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.password_validation import validate_password
from allauth.socialaccount.models import SocialAccount
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.core.files.base import ContentFile
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import requests
from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404
from rest_framework.permissions import IsAuthenticated
from chat.models import ChatRoom
from django.db.models import Q


class UserCreateViewSet(generics.CreateAPIView):
    queryset=User.objects.all()
    serializer_class=UserCreateSerializer
    permission_classes = [IsOwnerOrAdmin]
    def post(self, request, *args, **kwargs):
        try:
            username = request.data.get('username')
            email = request.data.get('email')
            exist_username = User.objects.filter(username=username).exists()
            exist_email = User.objects.filter(email=email).exists()               
            if exist_username:
                return Response({'status': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)               
            if exist_email:
                return Response({'status': 'Email already exists'}, status=status.HTTP_400_BAD_REQUEST)
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            headers = self.get_success_headers(serializer.data)
            return Response({'status': 'User created successfully'}, status=status.HTTP_201_CREATED, headers=headers)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        

@api_view(['POST'])
@permission_classes([])
def login_view(request):
    if request.method == 'POST':
        email_or_username = request.data.get('email')
        password = request.data.get('password')
        if not email_or_username or not password:
            return Response({'error': 'Please provide both email or username and password.'}, status=status.HTTP_400_BAD_REQUEST)
        if '@' in email_or_username:
            user = authenticate(request, email=email_or_username, password=password)
        else:
            user = authenticate(request, username=email_or_username, password=password)

        if user is not None:
            login(request, user)
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)
            response_data = {
                'token': access_token,
                'user_id': user.id,
                'status':'Successfully login',
            }
            return Response(response_data, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    else:
        return Response({'error': 'Method not allowed'}, status=status.HTTP_405_METHOD_NOT_ALLOWED)


class ChangePasswordViewSet(generics.UpdateAPIView):
    queryset=User.objects.all()
    serializer_class=ChangePasswordserializer
    permission_classes=[IsOwnerOrAdmin]
    def put(self, request, *args, **kwargs):
        user=self.request.user
        instance=User.objects.filter(pk=user.id)
        serializer=self.get_serializer(instance,data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_data={
                'status':'Successfully Change password'
            }
            return Response(response_data)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)




class SendOtpToUser(generics.CreateAPIView):
    def post(self, request, *args, **kwargs):
        try:
            email = request.data.get('email')
            exist_email = User.objects.filter(email=email)                           
            if exist_email:
                emaill = User.objects.get(email=email)
                otp = str(random.randint(100000, 999999))
                EmailOtp.objects.filter(email=emaill.id).delete()
                current_time = timezone.localtime()
                new_time = current_time + timedelta(minutes=5)
                time_string = new_time.strftime('%H:%M:%S')
                write=EmailOtp.objects.create(email=emaill,otp=otp,expiration_time=time_string)
                if write:
                    send_mail(
                    'Your OTP',
                    f'Your OTP is: {otp}',
                    settings.EMAIL_HOST_USER, 
                    [email],  
                    fail_silently=False,
                    )
                return Response({'status': 'OTP send successfully'}, status=status.HTTP_201_CREATED)
            else:
                return Response({'error': 'Invalid Email'}, status=status.HTTP_401_UNAUTHORIZED)
        
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        

class ForgetPassword(generics.UpdateAPIView):
    def put(self, request, *args, **kwargs):
        email = request.data.get('email')
        new_password = request.data.get('password')
        if not email or not new_password:
            return Response({'error':('Please provide both email and password.')}, status=status.HTTP_400_BAD_REQUEST)
        try:
            validate_email(email)
        except ValidationError:
            return Response({'error': ('Invalid email address.')}, status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': ('User with this email does not exist.')}, status=status.HTTP_404_NOT_FOUND)
        try:
            validate_password(new_password, user=user)
        except ValidationError as e:
            return Response({'error': e.messages}, status=status.HTTP_400_BAD_REQUEST)
        user.set_password(new_password)
        user.save()
        emaill = User.objects.get(email=email)
        EmailOtp.objects.filter(email=emaill.id).delete()
        return Response({'status': ('Password updated successfully.')}, status=status.HTTP_200_OK)


class VerifyOTP(APIView):
    def post(self, request):
        otp_entered = request.data.get('otp')
        email = request.data.get('email')
        if not email or not otp_entered:
            return Response({'error':('Please provide both email and OTP.')}, status=status.HTTP_400_BAD_REQUEST)
        user_email=User.objects.get(email=email)
        if user_email:
            otp_object = EmailOtp.objects.filter(email=user_email)
            if otp_object:
                otp_objectt = EmailOtp.objects.get(email=user_email)
                if otp_objectt.otp == otp_entered:
                    otp_objectt.delete()
                    return Response({'message': 'OTP verified successfully.'}, status=status.HTTP_200_OK)
                else:
                    return Response({'error': 'Invalid OTP.'}, status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({'error': 'OTP not Found.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({'error': 'user email not found.'}, status=status.HTTP_400_BAD_REQUEST)

def delete_user_image(instance):
    if instance.image:
        image_path = instance.image.path
        instance.image.delete()
        if os.path.isfile(image_path):
            os.remove(image_path)

@api_view(['POST'])
def update_user(request):
    permission_classes=[IsOwnerOrAdmin]
    if request.method == 'POST':
        try:
            user = request.user
            instance = User.objects.get(pk=user.id)
            if not request.data:
                serializer = UserUpdateSerializer(instance)
                response_data = serializer.data
                response_data['email'] = instance.email
                return Response(response_data)
            if 'image' in request.data:
                if instance.image:
                    instance.image.delete()
                instance.image = request.data['image']

            serializer = UserUpdateSerializer(instance, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                response_data = serializer.data
                response_data['email'] = instance.email
                return Response(response_data, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    else:
        return Response({'error': 'Method not allowed'}, status=status.HTTP_405_METHOD_NOT_ALLOWED)



def home(request):
    return render(request,'login.html')



@csrf_exempt
def get_google_user_info(request):
    if request.method == 'POST':
        access_token = request.POST.get('access_token')
        if not access_token:
            return JsonResponse({'error': 'Access token is missing'}, status=400)
        userinfo_url = 'https://www.googleapis.com/oauth2/v3/userinfo'
        headers = {'Authorization': 'Bearer {}'.format(access_token)}   
        try:
            response = requests.get(userinfo_url, headers=headers)
            if response.status_code == 200:
                user_info = response.json()
                email = user_info.get('email')
                username = email.split('@')[0]  
                first_name = user_info.get('given_name')
                last_name = user_info.get('family_name')
                social_login = True
                image_url = user_info.get('picture')
                user, created = User.objects.get_or_create(email=email, defaults={'username': username, 'first_name': first_name, 'last_name': last_name, 'is_social_login': social_login})
                if created or user.is_active or image_url:
                    response = requests.get(image_url)
                    if response.status_code == 200:
                        if not user.image:
                            image_content = ContentFile(response.content)
                            image_filename = f"{user.id}pfp.jpg"
                            user.image.save(image_filename, image_content)
                    user = authenticate(email=email)
                    if user is not None:
                        login(request, user)
                        refresh = RefreshToken.for_user(user)
                        access_token = str(refresh.access_token)  
                        response_data = {'token': access_token, 'user_id': user.id, 'status': 'Successfully logged in'}
                        return JsonResponse(response_data, status=200)
                    else:
                        return JsonResponse({'error': 'Authentication failed'}, status=403)
            else:
                print("Error:", response.status_code)
                return JsonResponse({'error': 'Failed to retrieve user information'}, status=400)
        except requests.RequestException as e:
            print("Request Exception:", e)
            return JsonResponse({'error': 'Failed to connect to Google'}, status=500)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)


class SendFriendRequestView(generics.CreateAPIView):
    queryset = FriendRequest.objects.all()
    serializer_class = FriendRequestSerializer
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        to_user_id = request.data.get('to_user')
        if not to_user_id:
            return Response({'error': 'to_user_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        to_user = get_object_or_404(User, id=to_user_id)

        if FriendRequest.objects.filter(from_user=request.user, to_user=to_user).exists():
            return Response({'error': 'Friend request already sent'}, status=status.HTTP_400_BAD_REQUEST)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(from_user=request.user, to_user=to_user, request_sent=True)
        return Response({'message': 'Friend request sent successfully'}, status=status.HTTP_201_CREATED)


class ReceiveFriendRequestView(generics.ListAPIView):
    serializer_class = ReceivedFriendRequestSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        queryset = FriendRequest.objects.filter(to_user=self.request.user, is_accepted=False)
        search = self.request.GET.get('search')
        if search:
            queryset = queryset.filter(from_user__first_name__icontains=search) | \
                       queryset.filter(from_user__last_name__icontains=search)
        return queryset
    
    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        friend_requests_data = []
        for friend_request in queryset:
            from_user = friend_request.from_user
            user_data = {
                'from_user_id': from_user.id,
                'first_name': from_user.first_name,
                'last_name': from_user.last_name,
                'bio': from_user.bio,
                'image_url': from_user.image.url if from_user.image else None,
                'created_at': friend_request.created_at
            }
            friend_requests_data.append(user_data)

        return Response({'friend_requests': friend_requests_data}, status=status.HTTP_200_OK)

class AcceptFriendRequestView(generics.UpdateAPIView):
    serializer_class = AcceptFriendRequestSerializer
    permission_classes = [IsAuthenticated]

    def update(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        from_user_id = serializer.validated_data.get('from_user')
        friend_request=FriendRequest.objects.get(to_user=self.request.user,from_user=from_user_id.id)
        if friend_request.is_accepted == True:
            return Response({'message': 'Friend request already accepted'}, status=status.HTTP_200_OK)
        if friend_request.is_accepted == False:
            friend_request.is_accepted = True
            friend_request.save()
        from_user_id = friend_request.from_user.id
        to_user_id = friend_request.to_user.id
        chat_room_id = f"{from_user_id}.{to_user_id}"
        chat_room = ChatRoom.objects.create(chat_type='one_to_one', chat_room_id=chat_room_id,member_count=2)
        chat_room.members.add(friend_request.from_user, friend_request.to_user)
        return Response({'message': 'Friend request accepted and chat room created successfully'}, status=status.HTTP_200_OK)

    

class ListOfUserView(generics.ListAPIView):
    serializer_class = UserInformationSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        requested_user = self.request.user
        friend_request_from_ids = FriendRequest.objects.filter(to_user=requested_user, is_accepted=True).values_list('from_user_id', flat=True)
        friend_request_to_ids = FriendRequest.objects.filter(from_user=requested_user, is_accepted=True).values_list('to_user_id', flat=True)
        requested_user_sent_request_ids = FriendRequest.objects.filter(
            from_user=requested_user, request_sent=True
        ).values_list('to_user_id', flat=True)
        friend_ids = set(friend_request_from_ids) | set(friend_request_to_ids)
        search = self.request.GET.get('search')
        if search:
            queryset = User.objects.exclude(id__in=friend_ids).filter(Q(first_name__icontains=search) | Q(last_name__icontains=search))
        else:
            queryset = User.objects.exclude(id__in=friend_ids)
        queryset = queryset.exclude(id__in=requested_user_sent_request_ids)
        queryset = queryset.exclude(id=1)
        queryset = queryset.exclude(id=requested_user.id)
        return queryset


class IsOnlineView(generics.UpdateAPIView):
    serializer_class = UserOnlineStatusSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data, status=200)

    def get(self, request, *args, **kwargs):
        return Response({'error': 'Method not allowed'}, status=405)         
