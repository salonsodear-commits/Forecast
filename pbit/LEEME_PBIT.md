# Detalle_Forecast_Real_Proyectado.pbit  (EXPERIMENTAL)

Plantilla de Power BI con el **modelo estrella limpio del spec** ya armado:
FACT (`Resumen Base` con `TipoDato` Real/Proyectado) + `DIM_Cliente` + `DIM_Factores`
+ `Calendario` + parámetro **`FechaUltimoCierre = 01/04/2026`** + medidas + relaciones.

> ⚠️ **Experimental:** lo armé sin poder abrirlo/probarlo en este entorno (no hay
> Power BI Desktop acá). Validé estructura, JSON, codificaciones y referencias
> cruzadas, pero la prueba real es abrirlo. Si Power BI lo rechaza, usá el **kit**
> (`powerquery/` + `dax/` + `INSTRUCCIONES_PowerBI.md`), que es el camino garantizado.

> 🔧 **Corrección (v3):** las versiones previas daban "archivo dañado" (`MashupValidationError`).
> Causa: el formato binario del **DataMashup** estaba mal en la sección *metadata*
> (faltaba la longitud `len(xml)+34` y el **tail obligatorio** `16 00 00 00` + registro
> *EOCD* `50 4b 05 06`). Ya está corregido y **verificado con el parser de `powerbi-vcs`**
> (lee PBIX reales) sin errores. Este `.pbit` trae el **modelo limpio** (FACT + Calendario
> + DIM_Cliente + DIM_Factores + parámetro + medidas) como base para reconstruir el reporte.

## Cómo usarlo

1. Abrí el `.pbit` con **Power BI Desktop** (doble clic).
2. Te va a pedir el valor del parámetro **`FechaUltimoCierre`** → dejá **01/04/2026**
   (o cambialo cuando avance el cierre).
3. Power BI refresca y carga los datos desde tus Excel. **Verificá las rutas** de origen
   (si tus archivos no están en esas rutas, editá el paso `Origen` de cada consulta):
   - FACT: `\\ERFLS01\...\Base de Ventas BO OC.xlsx` (hoja `Resumen Base`)
   - DIM_Factores: `O:\...\Factores Cliente.xlsx` (hoja `Factores`)
4. La página **"Inicio"** viene **en blanco a propósito**: arrastrá campos para armar
   tus visuales. El modelo (tablas, medidas, relaciones, corte 4+8) ya está listo.

## Qué incluye el modelo

| Tabla | Origen | Notas |
|---|---|---|
| `Resumen Base` (hechos) | Excel ventas (M) | desdinamizada, sin Totales/Total/ELIMINAR, con `TipoDato` y `Cliente_Concepto2` |
| `Calendario` | M (2024–2026) | marcada como tabla de fechas |
| `DIM_Cliente` | distinct de la FACT | `CLIENTE`, `VERTICAL` |
| `DIM_Factores` | Excel factores (hoja `Factores`) | `Cliente_Concepto2`, `Factores Clientes` |

**Medidas:** `Ventas`, `Ventas Real`, `Ventas Proyectado`, `Ventas Forecast`,
`Último Cierre`, `Ventas Ajustada` (aplica el factor por `Cliente_Concepto2`).

**Relaciones:** `Calendario[Fecha] 1:* Resumen Base[Fecha]`,
`DIM_Cliente[CLIENTE] 1:* Resumen Base[CLIENTE]`,
`DIM_Factores[Cliente_Concepto2] 1:* Resumen Base[Cliente_Concepto2]`.

> Se incluye `DataModelSchema.json` (el modelo en texto) por si querés inspeccionarlo
> o importarlo con Tabular Editor.
