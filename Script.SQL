-- =============================================
-- Author:      Chad Petrovay
-- Create date: 2022-03-23
-- Description: Create a security group with no rights prior to the upgrade; after running "Add Missing Security > Full Rights" this script will return all fields and hierarchies in the group with any rights
-- =============================================
-- Parameters:
--   @SGID - The primary key for a Security Group with no rights
--   @LanguageID - The primary key for the UI language
-- =============================================

DECLARE @SGID INT = 5;
DECLARE @LanguageID INT = 1;

WITH NewSecurity AS (
	SELECT 'Hierarchy' AS Type
		, CONCAT(
			STUFF((
				SELECT ' / ' + LN.TableLabel
				FROM STRING_SPLIT(H.HierarchyRoot,'a') HR
				LEFT JOIN DDLocalTableNames LN ON HR.[value] = LN.TableID AND LN.LanguageID = @LanguageID
				WHERE HR.[value] <> ''
				FOR XML PATH('')
				), 1, 3, '')
			,CASE WHEN HierarchyRoot <> '' THEN ' / ' END
			,LN.TableLabel ) AS HierPath
		,'' AS FieldName
		,CONVERT(NCHAR,SGHX.Viewable) AS [View]
		,CONVERT(NCHAR,SGHX.Editable) AS [Edit]
		,CONVERT(NCHAR,SGHX.Addable) AS [Add]
		,CONVERT(NCHAR,SGHX.Deletable) AS [Delete]
	FROM SecGrpHierXref SGHX 
	INNER JOIN DDHierarchy H ON SGHX.HierarchyID = H.HierarchyID
	LEFT JOIN DDLocalTableNames LN ON H.TableID = LN.TableID AND LN.LanguageID = @LanguageID
	WHERE SGHX.SecurityGroupID = @SGID
	AND (SGHX.Addable = 1 OR SGHX.Deletable = 1 OR SGHX.Editable = 1 OR SGHX.Viewable = 1)

	UNION ALL

	SELECT 'Field' AS Type
		, CONCAT(
			STUFF((
				SELECT ' / ' + LN.TableLabel
				FROM STRING_SPLIT(H.HierarchyRoot,'a') HR
				LEFT JOIN DDLocalTableNames LN ON HR.[value] = LN.TableID AND LN.LanguageID = @LanguageID
				WHERE HR.[value] <> ''
				FOR XML PATH('')
				), 1, 3, '')
			,CASE WHEN HierarchyRoot <> '' THEN ' / ' END
			,LN.TableLabel ) AS HierPath
		,CN.ColumnLabel AS FieldName
		,CONVERT(NCHAR,SGX.Viewable) AS [View]
		,CONVERT(NCHAR,SGX.Editable) AS [Edit]
		,'-' AS [Add]
		,'-' AS [Delete]
	FROM DDSecGrpXref SGX 
	INNER JOIN DDHierarchy H ON SGX.HierarchyID = H.HierarchyID
	LEFT JOIN DDLocalTableNames LN ON H.TableID = LN.TableID AND LN.LanguageID = @LanguageID
	INNER JOIN DDLocalColumnNames CN ON SGX.ColumnID = CN.ColumnID AND CN.LanguageID = @LanguageID
	WHERE SGX.SecurityGroupID = @SGID
	AND (SGX.Editable = 1 OR SGX.Viewable = 1)
)
SELECT [Type]
	,[HierPath] AS [Hierarchy Path]
	,[FieldName]
	,[View]
	,[Edit]
	,[Add]
	,[Delete]
FROM NewSecurity
ORDER BY HierPath, FieldName
