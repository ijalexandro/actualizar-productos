BEGIN;
TRUNCATE staging_productos;
COPY staging_productos
  FROM 'supstorage://raw-csv/productos.csv'
  WITH (FORMAT csv, HEADER true);
INSERT INTO productos_catalogo AS tgt (codigo, precio_final_con_iva, precio_final_con_desc_e, total_disponible_venta)
SELECT
  numero_producto || store_number AS codigo,
  trunc(precio_final_con_iva::numeric, 2),
  trunc(precio_final_con_desc_e::numeric, 2),
  round(total_disponible_venta::numeric)
FROM staging_productos
ON CONFLICT (codigo) DO UPDATE
  SET precio_final_con_iva      = EXCLUDED.precio_final_con_iva,
      precio_final_con_desc_e   = EXCLUDED.precio_final_con_desc_e,
      total_disponible_venta    = EXCLUDED.total_disponible_venta;
COMMIT;
