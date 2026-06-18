# Rediseño visual — IHSA Forecast (resumen y propuesta)

## 1) Lo aplicado en esta versión (`pbix_rediseno/Detalle_Forecast_de_Ventas.pbix`)

**Paneles de filtros izquierdos — hojas "Detalle de Ventas", "Detalle Nuevos Negocios", "Detalle Vista":**
- Slicers reestilados como **tarjetas IHSA**: fondo `#163F73`, borde `#2E63A6` (radio 10), sombra, **labels `#9DC1E8`** (Georgia) y valores en blanco — igual al mockup y a tu hoja de referencia.
- Modo **desplegable (dropdown)** en Año, Mes, Vertical y Tipo de Negocio; **Escenario Ajuste** como slider con acento ámbar `#E8A13C`.
- **Stack alineado** (x=14, ancho 196, separación uniforme) dentro de la **columna azul del fondo IHSA**, dejando visible el **logo "GRUPO IHSA"** inferior (no se tapó: se respeta el logo).
- Tarjeta **"Mes Cierre"** arriba del panel y botón **"Limpiar filtros"** (ámbar, acción *Borrar todas las segmentaciones*).

**Tarjeta de recuento (última hoja):**
- La tarjeta *Clientes × Tipo de Negocio* (Count de CLIENTE) estaba **sin formato**. Ahora tiene **título** ("Clientes por Tipo de Negocio"), **marco** (borde redondeado `#2E63A6`), **fondo** y sombra, alineada al estilo IHSA.

> El `DataModel` quedó intacto byte a byte; solo se editó `Report/Layout`. Mirá los PNG en `preview/` para ver el resultado esperado (no pude abrir Power BI acá, así que el ajuste fino puede necesitar 1 retoque).

## 2) Mejoras propuestas (mejores prácticas)

**Layout / consistencia**
1. **Misma grilla en todas las hojas**: panel 224 px, contenido desde x≈232, márgenes de 16 px, charts alineados a una grilla (hoy varían posición/tamaño entre hojas).
2. **Consolidar hojas borrador**: "Página 1", "Nuevo", "Duplicado de Nuevo", "Duplicado de Duplicado de Nuevo" → unificar y **renombrar** con nombres claros (p. ej. *Resumen*, *Detalle*, *Forecast 4+8*).
3. **Títulos uniformes** en todos los visuales (mismo serif IHSA, color navy, misma altura).

**Visualización**
4. **Recuento como barras horizontales** ordenadas (mejor que tarjeta para comparar categorías). Lo dejé como tarjeta por tu pedido; recomiendo barras.
5. **Donut "por Tipo de Negocio" → barras** si hay >4–5 categorías (el donut dificulta comparar magnitudes).
6. **Formato de números**: separador de miles/millones y % con 0–1 decimal. Revisar **"Valor en MIles"**: divide por 10.000.000 (no por 1.000), así que la etiqueta no coincide con la operación.

**Modelo (rápidas, alto impacto)**
7. **Nombres de medidas malformados**: varias quedaron con el comentario DAX pegado al nombre — renombrar quitando el `// …`:
   - `// KPI de control: … Último Cierre` → **Último Cierre**
   - `// Vista combinada: … Ventas Forecast` → **Ventas Forecast**
8. **Unificar el filtro de fecha**: hoy conviven `Calendario.Año/Mes`, jerarquías de `Resumen Base.Fecha` y `Calendario.Date` según la hoja → elegir **una** (idealmente `Calendario`) y replicarla.
9. **Desactivar Fecha/hora automática** (tablas `LocalDateTable`) y usar solo **Calendario** marcada como tabla de fechas.
10. **Editar interacciones**: definir qué visual filtra a cuál (p. ej. que el slicer CLIENTE no recalcule todo si no se desea).

¿Querés que aplique las mejoras 1–6 directamente sobre el `.pbix`, y/o que extienda el panel a las hojas borrador?
