// ============================================================================
//  FechaUltimoCierre  —  parámetro de corte Real / Proyectado
//  Valor de hoy: 01/04/2026  (REAL hasta ABRIL 2026  ->  4 reales + 8 proyectados)
// ============================================================================
//
//  Elegí UNA de las dos variantes. Las dos crean una consulta llamada
//  EXACTAMENTE "FechaUltimoCierre", que es la que usa la consulta "Resumen Base".
//
//  ────────────────────────────────────────────────────────────────────────
//  VARIANTE A (RECOMENDADA) — Parámetro nativo de Power BI
//  ────────────────────────────────────────────────────────────────────────
//  No se pega código. Se crea por menú:
//     Inicio -> Transformar datos -> Administrar parámetros -> Nuevo
//        Nombre        : FechaUltimoCierre
//        Tipo          : Fecha
//        Valor actual  : 01/04/2026
//  Cada mes: cambiás SOLO este valor (p.ej. 01/05/2026) y "Cerrar y aplicar".
//
//  ────────────────────────────────────────────────────────────────────────
//  VARIANTE B — Controlado desde Excel (usa la hoja "Config" que se agregó al
//  archivo Base_de_Ventas_BO_OC.xlsx, celda B1). Útil si querés manejar el
//  corte sin abrir Power BI: cambiás B1, refrescás y listo.
//  Crear una "Consulta en blanco" llamada FechaUltimoCierre y pegar:
//  ────────────────────────────────────────────────────────────────────────
let
    Origen = Excel.Workbook(
        File.Contents("\\ERFLS01\Files\Nuevos Negocios\Juliana\10 TRBJ\12 Ops Comp\05 Costos\09 Presupuesto - Budget - Fcst\2026\Base de Ventas BO OC.xlsx"),
        null, true),
    Config = Origen{[Item="Config", Kind="Sheet"]}[Data],
    Valor  = Config{0}[Column2]                 // B1 = "2026-04-01"
in
    Date.StartOfMonth(Date.From(Valor))
