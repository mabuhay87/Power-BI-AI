let
    FilePath = ExcelFilePath,
    Source = Excel.Workbook(File.Contents(FilePath), null, true),
    Navigation = Source{[Item="TABLE_NAME",Kind="Sheet"]}[Data],
    PromotedHeaders = Table.PromoteHeaders(Navigation, [PromoteAllScalars=true]),
    RemovedBlankRows = Table.SelectRows(PromotedHeaders, each List.NonNullCount(Record.FieldValues(_)) > 0)
in
    RemovedBlankRows
