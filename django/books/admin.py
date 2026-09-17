from django.contrib import admin
from models import Author, Review, Book

@admin.register(Author)
class AuthorAdmin(admin.ModelAdmin):
    list_display = ('name', 'birth_date', 'book_count')
    search_fields = ('name', 'bio')
    list_filter = ('birth_date',)
    ordering = ('name',)

    @admin.display(description='Number of books')
    def boook_count(self, obj):
        return obj.books.count()

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'isbn', 'publish_date', 'price', 'stock')
    list_filter = ('author', 'publish_date')
    search_fields = ('title', 'isbn', 'author__name')
    ordering = ('title',)
    list_select_related = ('author',)

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('book', 'user', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('book_title', 'user__username', 'comment')
    ordering = ('-created_at',)
    list_select_related = ('book', 'user')
    