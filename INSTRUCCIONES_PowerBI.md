# Cómo aplicar las indicaciones al Power BI

> **Resumen en 1 línea:** agregar el corte **Real/Proyectado** (parámetro
> `FechaUltimoCierre = 01/04/2026`, es decir **4 meses reales + 8 proyectados**),
> corregir la lectura del Excel (el modelo hoy lee mal el archivo) y sumar las
> medidas Real/Proyectado. Tu reporte, dimensiones y medidas actuales **no se rompen**.

---

## 0) Por qué se entrega como "kit para aplicar" y no como `.pbix` ya modificado

Tu `.pbix` fue creado/guardado desde el **servicio de Power BI** (`CreatedFrom: Cloud`,
release `2026.06`). El modelo de datos va dentro de la parte `DataModel`, que es un
backup tabular **comprimido con XPress9** (binario). Ese binario **sólo lo puede
volver a generar el motor de Power BI** (Power BI Desktop / servicio); no se puede
recompilar fuera de esas herramientas. Por eso lo que se entrega es:

1. **Los archivos base modificados** (carpeta `base_modificada/`) — listos.
2. **Este kit** (`powerquery/`, `dax/`) para pegar en tu modelo en ~5 minutos.

> Si querés, puedo intentar además armar una versión **`.pbit` / `.pbip`** (formato
> abierto que Power BI Desktop reconstruye solo). Es experimental porque no puedo
> probarlo en este entorno; decime y lo armo.

---

## 1) Diagnóstico (lo que encontré en tu modelo actual)

| Tema | Estado actual | Acción |
|---|---|---|
| Lectura del Excel | `Table.Skip(2)` → el archivo hoy tiene 2 filas extra arriba (encabezado real en **fila 5**). El modelo está promoviendo la fila equivocada. | **Corregir a `Skip(4)`** (incluido en el M nuevo) |
| Real / Proyectado | **No existe** | Agregar parámetro + columna `TipoDato` |
| Columnas `Total 2024/2025/2026` | Quedan pegadas en cada fila desdinamizada (ningún visual las usa) | Se quitan |
| Filas `CLIENTE = "Total"` y `Tipo de Negocio = "ELIMINAR"` | No se filtran | Se filtran |
| `Calendario` (tabla) | Existe y el reporte la usa, pero **no tiene relación** con `Resumen Base[Fecha]` | Verificar/crear relación |
| Medidas Real/Proyectado | No existen ( `Ventas` sí existe) | Agregar |
| `Cliente_Concepto2`, dimensiones, relaciones, `Ajuste`, medidas de ajuste | OK | No se tocan |

---

## 2) Pasos para aplicar (Power BI Desktop o modelado web)

**A. Parámetro de corte**
- `Inicio → Transformar datos → Administrar parámetros → Nuevo`
  - Nombre: **`FechaUltimoCierre`**  ·  Tipo: **Fecha**  ·  Valor: **01/04/2026**
- (Alternativa "desde Excel": ver `powerquery/01_Parametro_FechaUltimoCierre.pq`, Variante B,
  que lee la celda **B1** de la nueva hoja **Config**.)

**B. Reemplazar el M de `Resumen Base`**
- Seleccioná la consulta `Resumen Base` → `Editor avanzado` → borrá todo →
  pegá el contenido de **`powerquery/02_Resumen_Base.pq`**.
- Verificá la ruta del archivo (se mantuvo la tuya: `\\ERFLS01\...\Base de Ventas BO OC.xlsx`).

**C. Tipos de columna**
- `TipoDato` → **Texto**  ·  `Fecha` → **Fecha**  (el M ya los tipa, sólo confirmá).

**D. `Cerrar y aplicar`.**

**E. Medidas** (`Modelo → 'Resumen Base' → Nueva medida`)
- Pegá las de **`dax/Medidas.dax`** (no recrees `Ventas`, ya existe).

**F. Relación de calendario** (Vista Modelo)
- Verificá que exista **`Calendario[Date]  1 : *  'Resumen Base'[Fecha]`** (Single).
  Si no está, **creala** arrastrando `Calendario[Date]` sobre `Resumen Base[Fecha]`.
- Opcional: `Archivo → Opciones → Carga de datos → desactivar "Fecha y hora automáticas"`
  para limpiar las tablas `LocalDateTable` automáticas y usar sólo `Calendario`.

---

## 3) Verificación rápida

- `Último Cierre` debe dar **01/04/2026**.
- `Ventas Real` + `Ventas Proyectado` = `Ventas` (para 2026: 4 meses en Real, 8 en Proyectado).
- Una tabla `Calendario[Año-Mes]` × `Ventas Real` / `Ventas Proyectado` debe mostrar
  valores en Real hasta abril-2026 y en Proyectado de mayo a diciembre-2026.

---

## 4) Actualización mensual (flujo)

1. Cargás los reales del mes nuevo en `Base de Ventas BO OC.xlsx` (misma ruta/nombre).
2. Cambiás el corte:
   - **Variante A:** parámetro `FechaUltimoCierre` → nuevo valor (p.ej. `01/05/2026`).
   - **Variante B:** celda **B1** de la hoja **Config** → `2026-05-01`.
3. `Actualizar` / `Cerrar y aplicar`. No se toca M, ni relaciones, ni medidas.

---

## 5) Archivos base (carpeta `base_modificada/`)

- **`Base_de_Ventas_BO_OC.xlsx`** — se le agregó la hoja **`Config`** (B1 = `2026-04-01`)
  para documentar/controlar el corte. **Todos tus datos, fórmulas y vínculos externos
  quedaron intactos** (la hoja se inyectó sin re-guardar las hojas existentes).
- **`Factores_Cliente.xlsx`** — sin cambios: ya cumple (clave `Cliente_Concepto2` y
  `Factores Clientes` presentes). Se devuelve para completar el set.

> Recordá que las dimensiones salen de `Modelo_Dimensiones_PowerBI.xlsx` (no incluido):
> ese archivo no necesita cambios y debe seguir en su ruta.
