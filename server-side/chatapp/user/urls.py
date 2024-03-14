from django.urls import path,include
from user import views

urlpatterns=[
    path('create/',views.UserCreateViewSet.as_view(),name='user-creation'),
    path('login/',views.login_view,name='login'),
    path('cpassword/',views.ChangePasswordViewSet.as_view(),name='change_password'),
    path('send-otp/', views.SendOtpToUser.as_view(), name='send_otp'),
    path('forget-password/', views.ForgetPassword.as_view(), name='forget-password'),
    path('verify-otp/', views.VerifyOTP.as_view(), name='verify-otp'),
    path('update/', views.update_user, name='update_user'),
    path('',views.home, name='login'),
    path('google/',views.get_google_user_info, name='google'),
    path('friend_request/send/', views.SendFriendRequestView.as_view(), name='send_friend_request'),
    path('friend-request/receive/', views.ReceiveFriendRequestView.as_view(), name='receive_friend_request'),
    path('friend-request/accept/<int:pk>/', views.AcceptFriendRequestView.as_view(), name='accept_friend_request'),
    path('list_of_user/', views.ListOfUserView.as_view(), name='list_of_user'),
    path('is_online/', views.IsOnlineView.as_view(), name='is_online'),
]
