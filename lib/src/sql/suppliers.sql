CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    gps_coordinates GEOMETRY(Point, 4326),
    address TEXT,
    contact_number VARCHAR(20),
    website_url VARCHAR(255),
    supplier_code VARCHAR(50),
    delivery_hours JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_supplier_name UNIQUE (name, country, region)
    CONSTRAINT unique_supplier_code UNIQUE (supplier_code),
    CONSTRAINT unique_website_url UNIQUE (website_url),
    CONSTRAINT valid_gps_coordinates CHECK (ST_IsValid(gps_coordinates))
);


INSERT INTO suppliers ( 
    name,
    country,
    region,
    province,
    location,
    gps_coordinates,
    address,
    delivery_hours,
    contact_number,
    website_url
)
VALUES
    (
        'Walmart Heredia Este',
        'Costa Rica',
        'GAM',
        'Heredia',
        'San Pablo',
        ST_SetSRID(ST_MakePoint(9.974545781014035, -84.11211039767801), 4326),
        'Parada Comercial Heredia 2000, 3, Heredia, Heredia, Rincón de Sabanilla',
        '{
            "domingo": {"open": "07:30", "close": "22:00"},
            "lunes": {"open": "07:30", "close": "22:00"},
            "martes": {"open": "07:30", "close": "22:00"},
            "miércoles": {"open": "07:30", "close": "22:00"},
            "jueves": {"open": "07:30", "close": "22:00"},
            "viernes": {"open": "07:30", "close": "22:00"},
            "sábado": {"open": "07:30", "close": "22:00"}
        }'::jsonb,
        '+506 1234 5678',
        'https://walmart.co.cr'
    ),
    (
        'MaxiPalí Ulloa',
        'Costa Rica',
        'GAM',
        'Heredia',
        'Ulloa',
        ST_SetSRID(ST_MakePoint(9.970692597981323, -84.13413948407833), 4326),
        'Parada Comercial Heredia 2000, 3, Heredia, Heredia, Rincón de Sabanilla',
        '{
            "domingo": {"open": "09:00", "close": "18:00"},
            "lunes": {"open": "08:00", "close": "22:00"},
            "martes": {"open": "08:00", "close": "22:00"},
            "miércoles": {"open": "08:00", "close": "22:00"},
            "jueves": {"open": "08:00", "close": "22:00"},
            "viernes": {"open": "08:00", "close": "22:00"},
            "sábado": {"open": "08:00", "close": "20:00"}
        }'::jsonb,
        '+506 2345 6789',
        'https://maxipali.co.cr'
    ),
    (
        'PriceSmart',
        'Costa Rica',
        'Escazú',
        'Escazú, Costa Rica',
        ST_SetSRID(ST_MakePoint(-84.166755, 9.929222), 4326),
        'Ruta 27, Escazú',
        '{
            "domingo": {"open": "09:00", "close": "18:00"},
            "lunes": {"open": "08:00", "close": "22:00"},
            "martes": {"open": "08:00", "close": "22:00"},
            "miércoles": {"open": "08:00", "close": "22:00"},
            "jueves": {"open": "08:00", "close": "22:00"},
            "viernes": {"open": "08:00", "close": "22:00"},
            "sábado": {"open": "08:00", "close": "20:00"}
        }'::jsonb,
        '+506 3456 7890',
        'https://pricesmart.com'
    ),
    (
        'Mayca',
        'Costa Rica',
        'San José',
        'San José, Costa Rica',
        ST_SetSRID(ST_MakePoint(-84.084221, 9.933871), 4326),
        'Zona Industrial, San José',
        '{
            "domingo": {"open": "09:00", "close": "18:00"},
            "lunes": {"open": "08:00", "close": "22:00"},
            "martes": {"open": "08:00", "close": "22:00"},
            "miércoles": {"open": "08:00", "close": "22:00"},
            "jueves": {"open": "08:00", "close": "22:00"},
            "viernes": {"open": "08:00", "close": "22:00"},
            "sábado": {"open": "08:00", "close": "20:00"}
        }'::jsonb,
        '+506 4567 8901',
        'https://mayca.com'
    ),
    (
        'AutoMercado',
        'Costa Rica',
        'Heredia',
        'Heredia, Costa Rica',
        ST_SetSRID(ST_MakePoint(-84.171004, 9.999016), 4326),
        'Plaza Real, Heredia',
        '{
            "domingo": {"open": "09:00", "close": "18:00"},
            "lunes": {"open": "08:00", "close": "22:00"},
            "martes": {"open": "08:00", "close": "22:00"},
            "miércoles": {"open": "08:00", "close": "22:00"},
            "jueves": {"open": "08:00", "close": "22:00"},
            "viernes": {"open": "08:00", "close": "22:00"},
            "sábado": {"open": "08:00", "close": "20:00"}
        }'::jsonb,
        '+506 5678 9012',
        'https://automercado.com'
    );
