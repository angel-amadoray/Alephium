from django.shortcuts import render, get_object_or_404
from django.core.paginator import Paginator
from .models import Book, Author

def book_list(request):
    """
    lists all books with pagination
    """
    books_qs = Book.objects.select_related('author').all()

    # pagination 9 books per page
    paginator = Paginator(books_qs, 9)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'page_obj': page_obj,
        'total_books': books_qs.count()
    }

    return render(request, 'books/book_list.html', context)

def book_detail(request, pk):
    """
    show the details of an individual book
    """

    book = get_object_or_404(
        Book.objects.select_related('author').prefetch_related('reviews__user'),
        pk=pk
    )

    # calculate average rating
    reviews = book.reviews.all()
    avg_rating = None
    if reviews.exists():
         avg_rating = sum(r.rating for r in reviews) / reviews.count()

    context = {
        'book': book,
        'reviews': reviews,
        'avg_rating': avg_rating,
    }

    return render(request, 'books/book_detail.html', context)

def author_detail(request, pk):
    """
    show the details of an individual author
    """
    author = get_object_or_404(Author.objects.prefetch_related('books'), pk=pk)
    context = {
        'author': author,
    }

    return render(request, 'books/author_detail.html', context)