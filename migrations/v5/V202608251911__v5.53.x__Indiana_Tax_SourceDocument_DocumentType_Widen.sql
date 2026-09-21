/* ============================================================================
   Indiana Property Tax Expert — widen SourceDocument.DocumentType.
   v5.53.x

   Caught immediately after V202608251908 added
   'PTABOAFinalDeterminationApproval' (32 chars) / 'PTABOAFinalDeterminationWithdrawal'
   (34 chars) to the CHECK constraint -- the column itself was still
   NVARCHAR(30), which would have rejected every insert of either new value.
   Widened to NVARCHAR(50) for headroom beyond just these two.
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument ALTER COLUMN DocumentType NVARCHAR(50) NOT NULL;
GO
