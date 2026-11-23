from .models import CarMake, CarModel


def initiate():
    """Populate the sample car catalog only if it is empty."""
    catalog = {
        'NISSAN': ('Japanese technology', ['Pathfinder', 'Qashqai', 'XTRAIL']),
        'Mercedes': ('German technology', ['A-Class', 'C-Class', 'E-Class']),
        'Audi': ('German technology', ['A4', 'A5', 'A6']),
        'Kia': ('Korean technology', ['Sorrento', 'Carnival', 'Cerato']),
        'Toyota': ('Japanese technology', ['Corolla', 'Camry', 'Kluger']),
    }
    for make_name, (description, models) in catalog.items():
        make, _ = CarMake.objects.get_or_create(
            name=make_name, defaults={'description': description}
        )
        for name in models:
            car_type = 'Sedan' if name in ('Cerato', 'Corolla', 'Camry') else 'SUV'
            CarModel.objects.get_or_create(
                car_make=make, name=name,
                defaults={'type': car_type, 'year': 2023},
            )
