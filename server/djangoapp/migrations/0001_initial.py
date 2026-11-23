# Initial migration for the Best Cars capstone models.
from django.db import migrations, models
import django.db.models.deletion
import django.core.validators


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name='CarMake',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100, unique=True)),
                ('description', models.TextField()),
            ],
        ),
        migrations.CreateModel(
            name='CarModel',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('type', models.CharField(choices=[('Sedan', 'Sedan'), ('SUV', 'SUV'), ('Wagon', 'Wagon')], default='SUV', max_length=10)),
                ('year', models.IntegerField(default=2023, validators=[
                    django.core.validators.MinValueValidator(2015),
                    django.core.validators.MaxValueValidator(2023),
                ])),
                ('car_make', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='models',
                    to='djangoapp.carmake',
                )),
            ],
        ),
    ]
