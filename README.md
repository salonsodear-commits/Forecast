# Forecast de Ventas — Real / Proyectado

Kit para aplicar las indicaciones del modelo (corte **Real/Proyectado** por parámetro)
sobre el reporte `Detalle_Forecast_de_Ventas`, más los archivos base modificados.

**Dato de corte vigente:** REAL hasta **abril 2026** → `FechaUltimoCierre = 01/04/2026`
→ **4 meses reales (ene–abr) + 8 proyectados (may–dic)**.

## Contenido

```
INSTRUCCIONES_PowerBI.md          Guía paso a paso (empezá por acá)
powerquery/
  01_Parametro_FechaUltimoCierre.pq   Parámetro de corte (2 variantes)
  02_Resumen_Base.pq                  M nuevo de la tabla de hechos (reemplazo)
  03_Factores_Cliente_referencia.pq   M actual (referencia, sin cambios)
dax/
  Medidas.dax                         Ventas Real / Proyectado / Forecast / control
base_modificada/
  Base_de_Ventas_BO_OC.xlsx           + hoja Config (datos intactos)
  Factores_Cliente.xlsx               sin cambios (ya cumple)
```

> El modelo de datos del `.pbix` es un binario XPress9 generado por el servicio de
> Power BI y no puede recompilarse fuera de Power BI; por eso los cambios se entregan
> como kit para pegar (~5 min). Ver sección 0 de `INSTRUCCIONES_PowerBI.md`.
