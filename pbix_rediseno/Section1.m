section Section1;

shared #"FechaUltimoCierre" = #date(2026, 4, 1) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true];

shared #"Resumen Base" = let
    Origen = Excel.Workbook(
        File.Contents("\\ERFLS01\Files\Nuevos Negocios\Juliana\10 TRBJ\12 Ops Comp\05 Costos\09 Presupuesto - Budget - Fcst\2026\Base de Ventas BO OC.xlsx"),
        null, true),

    Hoja     = Origen{[Item="Resumen Base", Kind="Sheet"]}[Data],
    SoloData = Table.Skip(Hoja, 5),

    // Lista completa de 48 nombres — sin List.Generate, sin ambigüedad
    NuevosNombres = {
        "SECTOR/SERVICIO CEBE/CECO", "CLIENTE", "PRODUCTO/PLAN",
        "CONCEPTO 1", "CONCEPTO 2", "DIMENSIÓN", "UM",
        "Tipo de Negocio", "PctDe",
        "2024-01-01","2024-02-01","2024-03-01","2024-04-01",
        "2024-05-01","2024-06-01","2024-07-01","2024-08-01",
        "2024-09-01","2024-10-01","2024-11-01","2024-12-01",
        "2025-01-01","2025-02-01","2025-03-01","2025-04-01",
        "2025-05-01","2025-06-01","2025-07-01","2025-08-01",
        "2025-09-01","2025-10-01","2025-11-01","2025-12-01",
        "2026-01-01","2026-02-01","2026-03-01","2026-04-01",
        "2026-05-01","2026-06-01","2026-07-01","2026-08-01",
        "2026-09-01","2026-10-01","2026-11-01","2026-12-01",
        "QUITAR_45","QUITAR_46","QUITAR_47"
    },

    ConNombres = Table.RenameColumns(SoloData,
        List.Zip({Table.ColumnNames(SoloData), NuevosNombres})),

    ColsQuitar  = List.Select(Table.ColumnNames(ConNombres), each Text.StartsWith(_, "QUITAR_")),
    SinTotales  = Table.RemoveColumns(ConNombres, ColsQuitar),

    SinTotalCli = Table.SelectRows(SinTotales,
        each Text.Trim(Text.From([CLIENTE])) <> "Total"),
    SinEliminar = Table.SelectRows(SinTotalCli,
        each Text.Upper(Text.Trim(Text.From([#"Tipo de Negocio"]))) <> "ELIMINAR"),

    Atributos9 = {
        "SECTOR/SERVICIO CEBE/CECO", "CLIENTE", "PRODUCTO/PLAN",
        "CONCEPTO 1", "CONCEPTO 2", "DIMENSIÓN", "UM",
        "Tipo de Negocio", "PctDe"
    },
    FixTipos = Table.TransformColumns(SinEliminar,
        List.Transform(Atributos9, each {_,
            each if _ = null then null else Text.From(_), type text})),

    Unpivot   = Table.UnpivotOtherColumns(FixTipos, Atributos9, "Fecha", "Valor"),
    FechaTipo = Table.TransformColumnTypes(Unpivot, {{"Fecha", type date}}),
    FechaMes  = Table.TransformColumns(FechaTipo,
        {{"Fecha", Date.StartOfMonth, type date}}),
    ValorNum  = Table.TransformColumns(FechaMes,
        {{"Valor", each Number.From(_), type number}}),

    FechaCierre = Date.StartOfMonth(Date.From(FechaUltimoCierre)),
    ConTipoDato = Table.AddColumn(ValorNum, "TipoDato",
        each if [Fecha] <= FechaCierre then "Real" else "Proyectado",
        type text),

    RenVertical = Table.RenameColumns(ConTipoDato,
        {{"SECTOR/SERVICIO CEBE/CECO", "VERTICAL"}}),
    ConMiles    = Table.AddColumn(RenVertical,
        "Valor en MIles", each [Valor] / 10000000, type number)
in
    ConMiles;

shared #"Factores Cliente" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Forecast-claude-busy-planck-be9cml (1)\Forecast-claude-busy-planck-be9cml\base_modificada\Factores_Cliente.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "Hoja1", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"SECTOR/SERVICIO CEBE/CECO", type text}, {"CLIENTE", type text}, {"CONCEPTO 2", type text}, {"Factores Clientes", type number}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_SECTOR_SERVICIO CEBE" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_SECTOR_SERVICIO CEBE", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_SECTOR_SERVICIO_CEBE", Int64.Type}, {"SECTOR/SERVICIO CEBE/CECO", type text}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_CLIENTE" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_CLIENTE", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_CLIENTE", Int64.Type}, {"CLIENTE", type text}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_CONCEPTO 1" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_CONCEPTO 1", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_CONCEPTO_1", Int64.Type}, {"CONCEPTO 1", type text}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_CONCEPTO 2" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_CONCEPTO 2", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_CONCEPTO_2", Int64.Type}, {"CONCEPTO 2", type text}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_DIMENSIÓN" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_DIMENSIÓN", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_DIMENSIÓN", Int64.Type}, {"DIMENSIÓN", type text}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_UM" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_UM", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_UM", Int64.Type}, {"UM", type text}}, "es")
in
  #"Tipo de columna cambiado";

shared #"DIM_Tipo de Negocio" = let
  Origen = Excel.Workbook(File.Contents("C:\Users\salonso\Downloads\Modelo_Dimensiones_PowerBI.xlsx"), null, true),
  #"Navegación 1" = Origen{[Item = "DIM_Tipo de Negocio", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID_Tipo_de_Negocio", Int64.Type}, {"Tipo de Negocio", type text}}, "es")
in
  #"Tipo de columna cambiado";
