from django.urls import path
from . import views

app_name = 'books'

urlpatterns = [
    path('', views.book_list, name='book_list'),
    path('book/<int:pk>/', views.book_detail, name='book_detail'),
     path('author/<int:pk>/', views.author_detail, name='author_detail'),
]