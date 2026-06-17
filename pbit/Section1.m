section Section1;

shared FechaUltimoCierre = #date(2026, 4, 1) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true];

shared #"Resumen Base" = let
    Origen = Excel.Workbook(File.Contents("\\ERFLS01\Files\Nuevos Negocios\Juliana\10 TRBJ\12 Ops Comp\05 Costos\09 Presupuesto - Budget - Fcst\2026\Base de Ventas BO OC.xlsx"), null, true),
    Hoja = Origen{[Item="Resumen Base", Kind="Sheet"]}[Data],
    QuitarRuido = Table.Skip(Hoja, 4),
    Encabezados = Table.PromoteHeaders(QuitarRuido, [PromoteAllScalars=true]),
    ColsTotal = List.Select(Table.ColumnNames(Encabezados), each Text.StartsWith(_, "Total")),
    SinTotales = Table.RemoveColumns(Encabezados, ColsTotal),
    SinTotalCli = Table.SelectRows(SinTotales, each Text.Trim(Text.From([CLIENTE])) <> "Total"),
    SinEliminar = Table.SelectRows(SinTotalCli, each Text.Upper(Text.Trim(Text.From([#"Tipo de Negocio"]))) <> "ELIMINAR"),
    TipoPct = Table.TransformColumnTypes(SinEliminar, {{"% de ", Int64.Type}}),
    Atributos = {"SECTOR/SERVICIO CEBE/CECO","CLIENTE","PRODUCTO/PLAN","CONCEPTO 1","CONCEPTO 2","DIMENSIÓN","UM","Tipo de Negocio","% de "},
    Unpivot = Table.UnpivotOtherColumns(TipoPct, Atributos, "Atributo", "Valor"),
    FechaTipo = Table.TransformColumnTypes(Unpivot, {{"Atributo", type date}}),
    Fecha = Table.RenameColumns(FechaTipo, {{"Atributo", "Fecha"}}),
    FechaMes = Table.TransformColumns(Fecha, {{"Fecha", Date.StartOfMonth, type date}}),
    ValorNum = Table.TransformColumns(FechaMes, {{"Valor", each Number.From(_), type number}}),
    ConTipoDato = Table.AddColumn(ValorNum, "TipoDato", each if [Fecha] <= Date.StartOfMonth(FechaUltimoCierre) then "Real" else "Proyectado", type text),
    RenVertical = Table.RenameColumns(ConTipoDato, {{"SECTOR/SERVICIO CEBE/CECO", "VERTICAL"}}),
    ConMiles = Table.AddColumn(RenVertical, "Valor en MIles", each [Valor] / 10000000, type number),
    ConClave = Table.AddColumn(ConMiles, "Cliente_Concepto2", each Text.From([CLIENTE]) & " | " & Text.From([CONCEPTO 2]), type text)
in
    ConClave;

shared Calendario = let
    Inicio = #date(2024, 1, 1),
    Fin = #date(2026, 12, 31),
    N = Duration.Days(Fin - Inicio) + 1,
    Fechas = List.Dates(Inicio, N, #duration(1, 0, 0, 0)),
    Tabla = Table.FromList(Fechas, Splitter.SplitByNothing(), {"Fecha"}),
    TFecha = Table.TransformColumnTypes(Tabla, {{"Fecha", type date}}),
    Anio = Table.AddColumn(TFecha, "Año", each Date.Year([Fecha]), Int64.Type),
    MesNro = Table.AddColumn(Anio, "Mes Nro", each Date.Month([Fecha]), Int64.Type),
    Mes = Table.AddColumn(MesNro, "Mes", each Date.ToText([Fecha], [Format="MMMM", Culture="es-ES"]), type text),
    AnioMes = Table.AddColumn(Mes, "Año-Mes", each Date.ToText([Fecha], [Format="yyyy-MM", Culture="es-ES"]), type text),
    Trim = Table.AddColumn(AnioMes, "Trimestre", each "Q" & Text.From(Date.QuarterOfYear([Fecha])), type text)
in
    Trim;

shared DIM_Cliente = let
    Fuente = #"Resumen Base",
    Cols = Table.SelectColumns(Fuente, {"CLIENTE", "VERTICAL"}),
    Unicos = Table.Distinct(Cols, {"CLIENTE"})
in
    Unicos;

shared DIM_Factores = let
    Origen = Excel.Workbook(File.Contents("O:\Nuevos Negocios\Juliana\10 TRBJ\12 Ops Comp\05 Costos\09 Presupuesto - Budget - Fcst\2026\Factores Cliente.xlsx"), null, true),
    Hoja = Origen{[Item="Factores", Kind="Sheet"]}[Data],
    Encab = Table.PromoteHeaders(Hoja, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(Encab, {{"Cliente_Concepto2", type text}, {"Factores Clientes", type number}}),
    SinDup = Table.Distinct(Tipos, {"Cliente_Concepto2"})
in
    SinDup;
