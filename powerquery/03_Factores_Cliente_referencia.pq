// ============================================================================
//  Factores Cliente  —  REFERENCIA (no requiere cambios)
//
//  Tu consulta actual ya funciona y la relación
//      'Resumen Base'[Cliente_Concepto2]  *:1  'Factores Cliente'[Cliente_Concepto2]
//  ya está creada. El archivo Factores_Cliente.xlsx ya trae la clave
//  Cliente_Concepto2 (formato  CLIENTE | CONCEPTO 2 ) tanto en la hoja "Hoja1"
//  (la que usa el modelo) como en la hoja limpia "Factores". No hay que tocar nada.
//
//  Se incluye sólo como referencia del M vigente:
// ============================================================================
let
    Origen = Excel.Workbook(
        File.Contents("O:\Nuevos Negocios\Juliana\10 TRBJ\12 Ops Comp\05 Costos\09 Presupuesto - Budget - Fcst\2026\Factores Cliente.xlsx"),
        null, true),
    Navegacion = Origen{[Item = "Hoja1", Kind = "Sheet"]}[Data],
    Encabezados = Table.PromoteHeaders(Navegacion, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Encabezados, {
        {"SECTOR/SERVICIO CEBE/CECO", type text},
        {"CLIENTE", type text},
        {"CONCEPTO 2", type text},
        {"Factores Clientes", type number}
    }, "es")
in
    Tipos
