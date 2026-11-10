-- =========================================================
-- BASE DE LA TIENDA
-- Pegalo en el SQL Editor de Supabase y apreta Run.
-- Despues cambia las categorias y los productos por los de tu rubro.
-- =========================================================

-- ===== TABLAS =====
create table categorias (
  id     bigint generated always as identity primary key,
  nombre text not null unique
);

create table productos (
  id           bigint generated always as identity primary key,
  nombre       text not null,
  descripcion  text,
  precio       numeric(10,2) not null check (precio >= 0),
  stock        int not null default 0 check (stock >= 0),
  imagen_url   text,
  categoria_id bigint references categorias(id),
  activo       boolean not null default true
);

-- Los usuarios los maneja Supabase Auth (auth.users).
-- Aca guardamos lo que Auth no guarda: el nombre y el rol.
create table perfiles (
  id     uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  rol    text not null default 'cliente' check (rol in ('cliente', 'admin'))
);

create table pedidos (
  id         bigint generated always as identity primary key,
  usuario_id uuid not null references auth.users(id),
  total      numeric(10,2) not null check (total >= 0),
  estado     text not null default 'pendiente'
             check (estado in ('pendiente', 'confirmado', 'cancelado')),
  creado     timestamptz not null default now()
);

create table pedido_items (
  id              bigint generated always as identity primary key,
  pedido_id       bigint not null references pedidos(id) on delete cascade,
  producto_id     bigint not null references productos(id),
  cantidad        int not null check (cantidad > 0),
  precio_unitario numeric(10,2) not null check (precio_unitario >= 0)  -- la foto del precio
);

-- ===== SEGURIDAD: cerramos las tablas al publico =====
-- Con la clave publica no se puede leer ni escribir nada.
-- Nuestro backend entra igual porque usa la clave secreta.
alter table categorias   enable row level security;
alter table productos    enable row level security;
alter table perfiles     enable row level security;
alter table pedidos      enable row level security;
alter table pedido_items enable row level security;

-- ===== DATOS DE EJEMPLO (cambialos por los de tu rubro) =====
insert into categorias (nombre) values ('Rojos'), ('Naranjas'), ('Amarillos'), ('Verdes'), ('Azules'), ('Violetas'), ('Rosas'), ('Monocromaticos');

insert into productos (nombre, descripcion, precio, stock, categoria_id) values
  ('Rojo tinto', 'Tono rojo profundo e intenso, acabado mate.', 12500, 15, 1),
  ('Rojo desgastado', 'Efecto vintage con matices rojizos envejecidos.',  11000, 10, 1),
  ('Naranja teja oscuro', 'Color terracota cálido y rústico.', 13200, 18, 2),
  ('Naranja melocotón claro', 'Tono pastel suave, luminoso y fresco.', 11500, 22, 2),
  ('Amarillo mostaza oscuro', 'Amarillo intenso con un toque otoñal.', 12800, 14, 3),
  ('Amarillo crema claro', 'Blanco cálido con sutiles matices amarillos.', 10500, 25, 3),
  ('Verde bosque', 'Verde profundo inspirado en la naturaleza.', 13000, 12, 4),
  ('Verde menta suave', 'Tono pastel relajante y muy luminoso.', 11800, 20, 4),
  ('Azul noche', 'Azul marino oscuro, elegante y sobrio.', 13500, 16, 5),
  ('Azul hielo', 'Azul pálido y frío, ideal para interiores.', 11200, 19, 5),
  ('Violeta uva', 'Morado vibrante y lleno de personalidad.',  14000,  8, 6),
  ('Violeta lavanda pastel', 'Tono lila suave, delicado y relajante.', 12000, 17, 6),
  ('Rosa magenta oscuro', 'Rosa fucsia intenso y muy llamativo.', 12500, 11, 7),
  ('Rosa cuarzo', 'Rosa pálido, delicado y sumamente sutil.', 11000, 24, 7),
  ('Negro puro', 'Negro absoluto de máxima opacidad y cobertura.', 14500, 30, 8),
  ('Gris plata claro', 'Gris moderno, neutro y muy luminoso.', 11500, 28, 8),
  ('Blanco hueso', 'Blanco cálido con un toque clásico.', 10000, 35, 8);

-- ===== IMAGENES =====
-- Subi las fotos al bucket publico "productos" de Storage y guarda cada URL:
-- update productos
-- set imagen_url = 'https://xxxx.supabase.co/storage/v1/object/public/productos/auriculares.jpg'
-- where id = 1;
