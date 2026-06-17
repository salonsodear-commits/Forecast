// ============================================================================
//  Resumen Base  —  tabla de hechos (REEMPLAZA el M actual de esta consulta)
//  Editor avanzado de la consulta "Resumen Base" -> borrar todo -> pegar esto.
//
//  Qué cambia respecto de tu modelo actual (y por qué):
//   1) Table.Skip 2 -> 4 : el archivo ahora trae 2 filas extra arriba; con Skip(2)
//      tu modelo está promoviendo la fila equivocada. El encabezado real está en
//      la FILA 5, así que hay que saltar 4. (Corrige el desfase actual.)
//   2) Se quitan las columnas "Total 2024/2025/2026" (no las usa ningún visual y
//      ensuciaban la tabla repitiéndose en cada fila desdinamizada).
//   3) Se quitan filas basura: CLIENTE = "Total" y Tipo de Negocio = "ELIMINAR".
//   4) Se agrega la columna TipoDato = Real / Proyectado según FechaUltimoCierre.
//   5) Se conservan los nombres/columnas que ya usa tu reporte (VERTICAL,
//      Valor, Valor en MIles, % de , etc.) -> no rompe relaciones ni visuales.
//      Cliente_Concepto2 sigue siendo tu columna calculada DAX (no se toca).
// ============================================================================
let
    // ── FUENTE (misma ruta/archivo que ya usabas) ──────────────────────────────
    Origen = Excel.Workbook(
        File.Contents("\\ERFLS01\Files\Nuevos Negocios\Juliana\10 TRBJ\12 Ops Comp\05 Costos\09 Presupuesto - Budget - Fcst\2026\Base de Ventas BO OC.xlsx"),
        null, true),
    Hoja = Origen{[Item="Resumen Base", Kind="Sheet"]}[Data],

    // ── ENCABEZADO EN FILA 5  (antes Skip=2; ahora Skip=4) ─────────────────────
    QuitarRuido = Table.Skip(Hoja, 4),
    Encabezados = Table.PromoteHeaders(QuitarRuido, [PromoteAllScalars=true]),

    // ── QUITAR COLUMNAS "Total ..." por prefijo (no por posición) ──────────────
    ColsTotal  = List.Select(Table.ColumnNames(Encabezados), each Text.StartsWith(_, "Total")),
    SinTotales = Table.RemoveColumns(Encabezados, ColsTotal),

    // ── QUITAR FILAS BASURA (con o sin espacios sobrantes) ─────────────────────
    SinTotalCli = Table.SelectRows(SinTotales,  each Text.Trim(Text.From([CLIENTE])) <> "Total"),
    SinEliminar = Table.SelectRows(SinTotalCli, each Text.Upper(Text.Trim(Text.From([#"Tipo de Negocio"]))) <> "ELIMINAR"),

    // ── % de  como entero (para mantener el tipo que ya tenías) ────────────────
    TipoPct = Table.TransformColumnTypes(SinEliminar, {{"% de ", Int64.Type}}),

    // ── UNPIVOT: fijo los atributos; todo lo demás (columnas-mes, incluidas las
    //    futuras) se anula dinámicamente -> escalable a nuevos meses sin editar M ─
    Atributos = {
        "SECTOR/SERVICIO CEBE/CECO", "CLIENTE", "PRODUCTO/PLAN",
        "CONCEPTO 1", "CONCEPTO 2", "DIMENSIÓN", "UM", "Tipo de Negocio", "% de "
    },
    Unpivot = Table.UnpivotOtherColumns(TipoPct, Atributos, "Atributo", "Valor"),

    // ── TIPADO Fecha / Valor ───────────────────────────────────────────────────
    FechaTipo = Table.TransformColumnTypes(Unpivot, {{"Atributo", type date}}),
    Fecha     = Table.RenameColumns(FechaTipo, {{"Atributo", "Fecha"}}),
    FechaMes  = Table.TransformColumns(Fecha, {{"Fecha", Date.StartOfMonth, type date}}),
    ValorNum  = Table.TransformColumns(FechaMes, {{"Valor", each Number.From(_), type number}}),

    // ── CLASIFICACIÓN REAL / PROYECTADO (depende del parámetro FechaUltimoCierre) ─
    //    Hoy FechaUltimoCierre = 01/04/2026 -> ene-abr 2026 = Real ; may-dic = Proyectado
    ConTipoDato = Table.AddColumn(ValorNum, "TipoDato",
        each if [Fecha] <= Date.StartOfMonth(FechaUltimoCierre) then "Real" else "Proyectado",
        type text),

    // ── COMPATIBILIDAD CON TU MODELO ───────────────────────────────────────────
    RenVertical = Table.RenameColumns(ConTipoDato, {{"SECTOR/SERVICIO CEBE/CECO", "VERTICAL"}}),
    ConMiles    = Table.AddColumn(RenVertical, "Valor en MIles", each [Valor] / 10000000, type number)
in
    ConMiles
