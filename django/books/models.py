from django.db import models
from django.contrib.auth.models import User

class Author(models.Model):
    """
    Represents an author of a book. Author can have many books
    """

    name = models.CharField(max_length=100)
    bio = models.TextField(blank=True)
    birth_date = models.DateField(null=True, blank=True)
    image = models.ImageField(upload_to='authors/', blank=True, null=True)

    class Meta:
        verbose_name = "Author"
        verbose_name_plural = "Authors"
        ordering =  ['name']

    def __str__(self):
        return self.name

class Book(models.Model):
    """
    Represents a book. Only one author can be assigned to a book.
    """

    title =  models.CharField(max_length=100)
    author =  models.ForeignKey(Author, on_delete=models.CASCADE, related_name='books')
    isbn = models.CharField(max_length=13, unique=True)
    publish_date = models.DateField(null=True, blank=True)
    descripition = models.TextField(blank=True)
    cover = models.ImageField(upload_to='covers/', blank=True, null=True)
    price =  models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    stock = models.IntegerField(default=0)

    class Meta:
        verbose_name = "Book"
        verbose_name_plural = "Books"
        ordering =  ['title']

    def __str__(self):
        return self.title

class Review(models.Model):
    """
    Represents a review of a book. A user can write only one review for a book.
    """

    book = models.ForeignKey(
        Book,
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE
    )
    rating = models.IntegerField(choices=[(i,i) for i in range(1,6)])
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Review"
        verbose_name_plural = "Reviews"
        unique_together = ['user', 'book']
        ordering =  ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.book.title} ({self.rating}/5)"

    
