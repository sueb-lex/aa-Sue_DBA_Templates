-- must run multiple statements when changing multiple fields

 
ALTER TABLE dbo.[<TableName>] ALTER COLUMN [<ColumnName>] <New DataType and Size>;

/* 
ALTER TABLE dbo.[PARDAT_Staging] ALTER COLUMN [LIVUNIT] DECIMAL(4,0);
ALTER TABLE dbo.[PARDAT_Staging] ALTER COLUMN [TIELANDPCT] DECIMAL(9,6);
ALTER TABLE dbo.[PARDAT_Staging] ALTER COLUMN [TIEBLDGPCT] DECIMAL(9,6);

--this will add a description to the field
EXEC sys.sp_addextendedproperty 
  @name=N'MS_Description'
 ,@value=N'changed from decimal(3,0) to (4,0) (09/25/2013 sb)'  --<<<<
 ,@level0type=N'SCHEMA'
 ,@level0name=N'dbo'
 ,@level1type=N'TABLE'
 ,@level1name=N'PARDAT_Staging' --<<<<
 ,@level2type=N'COLUMN'
 ,@level2name=N'LIVUNIT'  --<<<<

 EXEC sys.sp_addextendedproperty 
  @name=N'MS_Description'
 ,@value=N'changed from decimal(7,4) to (9,6) (09/25/2013 sb)'  --<<<<
 ,@level0type=N'SCHEMA'
 ,@level0name=N'dbo'
 ,@level1type=N'TABLE'
 ,@level1name=N'PARDAT_Staging' --<<<<
 ,@level2type=N'COLUMN'
 ,@level2name=N'TIELANDPCT'  --<<<<

 EXEC sys.sp_addextendedproperty 
  @name=N'MS_Description'
 ,@value=N'changed from decimal(7,4) to (9,6) (09/25/2013 sb)'  --<<<<
 ,@level0type=N'SCHEMA'
 ,@level0name=N'dbo'
 ,@level1type=N'TABLE'
 ,@level1name=N'PARDAT_Staging' --<<<<
 ,@level2type=N'COLUMN'
 ,@level2name=N'TIEBLDGPCT'  --<<<<


 ALTER TABLE dbo.[PERMIT] ADD [SEQ] DECIMAL(3,0);
 ALTER TABLE dbo.[PERMIT] ADD [CUR] VARCHAR(1);

 EXEC sys.sp_addextendedproperty 
  @name=N'MS_Description'
 ,@value=N'new column (09/26/2013 sb)'  --<<<<
 ,@level0type=N'SCHEMA'
 ,@level0name=N'dbo'
 ,@level1type=N'TABLE'
 ,@level1name=N'PERMIT' --<<<<
 ,@level2type=N'COLUMN'
 ,@level2name=N'SEQ'  --<<<<

 EXEC sys.sp_addextendedproperty 
  @name=N'MS_Description'
 ,@value=N'new column (09/26/2013 sb)'  --<<<<
 ,@level0type=N'SCHEMA'
 ,@level0name=N'dbo'
 ,@level1type=N'TABLE'
 ,@level1name=N'PERMIT' --<<<<
 ,@level2type=N'COLUMN'
 ,@level2name=N'CUR'  --<<<<


 */