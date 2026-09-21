/* ============================================================================
   Indiana Property Tax Expert -- the IBTR docket and decisions as research data
   v5.58.x

   The Indiana Board of Tax Review's decision search (POPLAR) exposes every
   disposition since 2002 -- 10,249 rows as of 2026-09-13: petition, parcel,
   county, township, assessment year, form type, dates, disposition type and
   hearing officer -- and the written Findings & Conclusions for 8,960 of them.
   The corpus lives in ~/Projects/Indiana_Board_Decisions (register row 19) with
   the text of every decision, a deterministic extraction of citations, hearing
   officers and representatives, and a model extraction of holdings, issues and
   parties (design: Indiana_Tax_Expert/docs/proposals/ibtr-decisions-research.md).

   Six tables carry it here. IBTRAppeal is the docket (authoritative, from
   POPLAR) plus per-decision summary fields; the children are the extracted
   layers, each row marked Rule or Model with a confidence tier so a
   model-derived fact is never mistaken for a docket fact. IBTRDecisionChunk is
   created now and filled by the retrieval step (section-aware text chunks for a
   Search Scope). BoardDecision (117 rows, 2025-26, hand-built) is superseded and
   kept; IBTRAppeal.LegacyBoardDecisionID links the overlap.

   These decisions bind nobody. Everything queried from these tables is a count
   of decisions with a denominator, cited by case number -- never a holding.
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO
ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (N'PropertyRecordCard', N'TaxHistoryReport', N'PTABOAAgenda', N'PTABOAFinalDeterminationApproval', N'PTABOAFinalDeterminationWithdrawal', N'BoardDecision', N'IBTRDecision', N'Form', N'Statute', N'Regulation', N'ReferenceText', N'Memo', N'StatewideParcelDataset', N'CountyParcelList', N'MarketDataExport', N'Other'));
GO
EXEC sp_updateextendedproperty @name=N'MS_Description', @value=N'What kind of document this is. IBTRDecision = an IBTR written determination file from the POPLAR docket or the Board''s month pages (one per decided appeal, text extracted; the 117 BoardDecision rows predate it and keep their type). Other values: PropertyRecordCard, TaxHistoryReport, PTABOAAgenda, PTABOAFinalDeterminationApproval/Withdrawal, BoardDecision, Form, Statute, Regulation, ReferenceText, Memo, StatewideParcelDataset, CountyParcelList, MarketDataExport, Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'SourceDocument', @level2type=N'COLUMN', @level2name=N'DocumentType';
GO

-- ---------------------------------------------------------------- IBTRAppeal
CREATE TABLE indiana_tax.IBTRAppeal (
    ID                     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    POPLARAppealID         INT              NOT NULL,
    PetitionNumber         NVARCHAR(200)    NOT NULL,
    PetitionerName         NVARCHAR(300)    NULL,
    CountyNumber           SMALLINT         NULL,
    CountyName             NVARCHAR(50)     NULL,
    TownshipName           NVARCHAR(100)    NULL,
    StateParcelNumber      NVARCHAR(60)     NULL,
    ParcelID               UNIQUEIDENTIFIER NULL,
    LocationAddress        NVARCHAR(300)    NULL,
    AssessmentYear         SMALLINT         NULL,
    AppealType             NVARCHAR(20)     NULL,
    DateReceived           DATE             NULL,
    DecisionDate           DATE             NULL,
    DispositionType        NVARCHAR(40)     NOT NULL,
    HearingOfficer         NVARCHAR(100)    NULL,
    YearFiled              SMALLINT         NULL,
    StatusName             NVARCHAR(30)     NULL,
    IssuesPhrase           NVARCHAR(500)    NULL,
    IsSmallClaims          BIT              NULL,
    SourceDocumentID       UNIQUEIDENTIFIER NULL,
    TextChars              INT              NULL,
    TextIsOCR              BIT              NULL,
    ExtractionStatus       NVARCHAR(20)     NOT NULL DEFAULT N'None',
    ModelConfidence        NVARCHAR(10)     NULL,
    Summary                NVARCHAR(MAX)    NULL,
    KeyReasoning           NVARCHAR(MAX)    NULL,
    PropertyType           NVARCHAR(300)    NULL,
    UseCategory            NVARCHAR(40)     NULL,
    LegacyBoardDecisionID  UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_IBTRAppeal PRIMARY KEY (ID),
    CONSTRAINT UQ_IBTRAppeal_POPLARAppealID UNIQUE (POPLARAppealID),
    CONSTRAINT FK_IBTRAppeal_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel(ID),
    CONSTRAINT FK_IBTRAppeal_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT FK_IBTRAppeal_BoardDecision FOREIGN KEY (LegacyBoardDecisionID) REFERENCES indiana_tax.BoardDecision(ID),
    CONSTRAINT CK_IBTRAppeal_AppealType CHECK (AppealType IS NULL OR AppealType IN (N'Form 131', N'Form 132', N'Form 133', N'Form 139', N'Other')),
    CONSTRAINT CK_IBTRAppeal_DispositionType CHECK (DispositionType IN (N'Board Determination', N'Board Determination Rehearing', N'Remand', N'Settlement - stipulation', N'Settlement - withdrawal', N'Dismissal - defective', N'Dismissal - failure to appear')),
    CONSTRAINT CK_IBTRAppeal_ExtractionStatus CHECK (ExtractionStatus IN (N'None', N'Rules', N'Model', N'Reviewed')),
    CONSTRAINT CK_IBTRAppeal_ModelConfidence CHECK (ModelConfidence IS NULL OR ModelConfidence IN (N'high', N'medium', N'low')),
    CONSTRAINT CK_IBTRAppeal_UseCategory CHECK (UseCategory IS NULL OR UseCategory IN (N'Residential', N'Commercial', N'Industrial', N'Agricultural', N'Vacant land', N'Exempt-organization property', N'Personal property', N'Other'))
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One disposition of the Indiana Board of Tax Review from its POPLAR docket (every appeal since 2002: determinations, stipulations, withdrawals, dismissals, remands), joined to the written decision when one exists. Docket columns are authoritative (POPLAR); Summary, KeyReasoning, PropertyType, UseCategory and ModelConfidence come from a model reading of the decision text and are leads until reviewed (ExtractionStatus). Decisions are non-precedential: query these as counts with a denominator, cited by petition number.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The Boards own appeal key in POPLAR (appealID). Unique; the loader is idempotent on it.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'POPLARAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Petition number(s) as POPLAR prints them, e.g. 45-003-18-1-5-00744-20 (county-township-year-form-track-sequence-year filed).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'PetitionNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Petitioner as docketed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'PetitionerName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'DLGF county number (1-92) derived from CountyName.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'CountyNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'County as docketed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'CountyName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Township as docketed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'TownshipName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Parcel number as docketed; formats vary by era and county (18-digit state number with punctuation, older local numbers, personal-property markers).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'StateParcelNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'indiana_tax.Parcel matched by the 18-digit state parcel number where the docketed number normalises to one; NULL otherwise.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'ParcelID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Property address as docketed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'LocationAddress';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Assessment year under appeal, per POPLAR.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'AssessmentYear';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Form 131 (assessment), 132 (exemption), 133 (correction of error), 139 (deduction), or Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'AppealType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Date the Board received the petition.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'DateReceived';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the final determination or other disposition.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'DecisionDate';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'POPLAR disposition type: Board Determination, Board Determination Rehearing, Remand, Settlement - stipulation, Settlement - withdrawal, Dismissal - defective, Dismissal - failure to appear.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'DispositionType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Administrative law judge: POPLARs hearingOfficerName where present, else the name recovered from the decision text by rule.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'HearingOfficer';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Year the petition was filed, per POPLAR.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'YearFiled';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'POPLAR status (Closed etc.).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'StatusName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The Boards one-line Issues phrase from its Decisions archive month page, where the decision appears there (2008 onward).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'IssuesPhrase';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 when the decision caption says Small Claims (the simplified track, removed for Form 131 from 2026-09-02).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'IsSmallClaims';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The decision file: SourceDocument of type IBTRDecision (hash, path, URL, extracted text).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'SourceDocumentID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Characters of extracted text for the decision file.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'TextChars';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 when the text came from OCR of an image-only scan (most POPLAR copies from 2025 on); treat quotations with care.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'TextIsOCR';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'None (docket only), Rules (citations/ALJ/representatives extracted), Model (model reading applied), Reviewed (a person checked the model fields).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'ExtractionStatus';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The models own confidence in its reading: high, medium, low (low when OCR-damaged or the outcome is not explicit).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'ModelConfidence';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Two or three sentences from the model reading: what was argued, what evidence carried, what the Board did. A lead, not a holding.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'Summary';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One or two sentences from the model reading on the decisive reasoning.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'KeyReasoning';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Property as the decision describes it (model reading).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'PropertyType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Residential, Commercial, Industrial, Agricultural, Vacant land, Exempt-organization property, Personal property, Other (model reading).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'UseCategory';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The pre-existing BoardDecision row (117 hand-built rows, 2025-26) for the same petition, where one exists.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRAppeal', @level2type=N'COLUMN', @level2name=N'LegacyBoardDecisionID';
GO

-- ---------------------------------------------------------------- IBTRDecisionParty
CREATE TABLE indiana_tax.IBTRDecisionParty (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    IBTRAppealID UNIQUEIDENTIFIER NOT NULL,
    Side NVARCHAR(12) NOT NULL,
    Role NVARCHAR(40) NOT NULL,
    PersonName NVARCHAR(200) NULL,
    FirmName NVARCHAR(300) NULL,
    NormalizedKey NVARCHAR(200) NULL,
    RawText NVARCHAR(500) NULL,
    Source NVARCHAR(10) NOT NULL,
    Confidence NVARCHAR(10) NULL,
    CONSTRAINT PK_IBTRDecisionParty PRIMARY KEY (ID),
    CONSTRAINT FK_IBTRDecisionParty_IBTRAppeal FOREIGN KEY (IBTRAppealID) REFERENCES indiana_tax.IBTRAppeal(ID),
    CONSTRAINT CK_IBTRDecisionParty_Side CHECK (Side IN (N'Petitioner', N'Respondent')),
    CONSTRAINT CK_IBTRDecisionParty_Role CHECK (Role IN (N'Party', N'Attorney', N'Certified tax representative', N'Pro se', N'Assessor staff', N'Appraiser witness', N'Other')),
    CONSTRAINT CK_IBTRDecisionParty_Source CHECK (Source IN (N'Rule', N'Model')),
    CONSTRAINT CK_IBTRDecisionParty_Confidence CHECK (Confidence IS NULL OR Confidence IN (N'high', N'medium', N'low'))
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'A person or firm on one side of an IBTR decision: the parties themselves and everyone who appeared for them (attorney, certified tax representative, pro se petitioner, assessor-office staff, appraiser witness). Source says whether a rule (header block, attendance line, appearance sentence) or the model reading produced the row.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'IBTRAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Petitioner or Respondent.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'Side';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Party, Attorney, Certified tax representative, Pro se, Assessor staff, Appraiser witness, Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'Role';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Name as printed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'PersonName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Law firm, consultancy or office as printed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'FirmName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Lower-cased, punctuation-stripped person name for grouping appearances across decisions (search by attorney or representative).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'NormalizedKey';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The header line or sentence the row was taken from (rule rows).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'RawText';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Rule or Model.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'Source';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Model rows: high, medium, low.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionParty', @level2type=N'COLUMN', @level2name=N'Confidence';
GO

-- ---------------------------------------------------------------- IBTRDecisionCitation
CREATE TABLE indiana_tax.IBTRDecisionCitation (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    IBTRAppealID UNIQUEIDENTIFIER NOT NULL,
    AuthorityType NVARCHAR(20) NOT NULL,
    CiteKey NVARCHAR(200) NOT NULL,
    CaseName NVARCHAR(300) NULL,
    Court NVARCHAR(30) NULL,
    Year SMALLINT NULL,
    Subsection NVARCHAR(100) NULL,
    MentionCount INT NOT NULL,
    CONSTRAINT PK_IBTRDecisionCitation PRIMARY KEY (ID),
    CONSTRAINT FK_IBTRDecisionCitation_IBTRAppeal FOREIGN KEY (IBTRAppealID) REFERENCES indiana_tax.IBTRAppeal(ID),
    CONSTRAINT CK_IBTRDecisionCitation_AuthorityType CHECK (AuthorityType IN (N'Statute', N'Rule', N'Manual', N'Guidelines', N'TaxCourt', N'CourtOfAppeals', N'SupremeCourt', N'Case', N'IBTR', N'USPAP')),
    CONSTRAINT CK_IBTRDecisionCitation_MentionCount CHECK (MentionCount >= 1)
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One authority cited in one IBTR decision, with how many times: statutes (IC ...), rules (50 IAC ...), the Assessment Manual and Guidelines, USPAP, Tax Court / Court of Appeals / Supreme Court cases by reporter cite, and the Boards own prior determinations. Extracted by rule (regex over the full text); short-form cites are resolved to the full cite in the same decision. This is the tally table: group by CiteKey with the decision count as numerator and IBTRAppeal rows with text as denominator.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The citing decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'IBTRAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Statute, Rule, Manual, Guidelines, TaxCourt, CourtOfAppeals, SupremeCourt, Case (court not recognised), IBTR (the Board citing itself), USPAP.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'AuthorityType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Normalised key: IC 6-1.1-15-17.2; 50 IAC 2.4-1-2; 821 N.E.2d 466; a petition number for IBTR self-cites; Manual / Guidelines / USPAP.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'CiteKey';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Most frequent spelling of the case name in this decision (cases only).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'CaseName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Ind. Tax Ct., Ind. Ct. App., Ind. (cases only).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'Court';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Year of the cited decision (cases only).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'Year';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Subsections cited, semicolon-separated, e.g. (d);(k) (statutes only).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'Subsection';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Times the authority is cited in the decision, full and short forms together.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionCitation', @level2type=N'COLUMN', @level2name=N'MentionCount';
GO

-- ---------------------------------------------------------------- IBTRDecisionIssue
CREATE TABLE indiana_tax.IBTRDecisionIssue (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    IBTRAppealID UNIQUEIDENTIFIER NOT NULL,
    Issue NVARCHAR(60) NOT NULL,
    Source NVARCHAR(10) NOT NULL,
    Confidence NVARCHAR(10) NULL,
    CONSTRAINT PK_IBTRDecisionIssue PRIMARY KEY (ID),
    CONSTRAINT FK_IBTRDecisionIssue_IBTRAppeal FOREIGN KEY (IBTRAppealID) REFERENCES indiana_tax.IBTRAppeal(ID),
    CONSTRAINT CK_IBTRDecisionIssue_Issue CHECK (Issue IN (N'burden of proof', N'uniformity & equality', N'appraisal', N'purchase price', N'sales comparison', N'income approach', N'cost approach', N'obsolescence', N'market value-in-use', N'agricultural land', N'exemption', N'deduction', N'timeliness / jurisdiction', N'methodology / trending', N'sales chasing', N'constitutionality', N'land value / classification', N'condition / physical characteristics', N'other')),
    CONSTRAINT CK_IBTRDecisionIssue_Source CHECK (Source IN (N'Rule', N'Model', N'MonthPage')),
    CONSTRAINT CK_IBTRDecisionIssue_Confidence CHECK (Confidence IS NULL OR Confidence IN (N'high', N'medium', N'low'))
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'An issue a decision turns on, from a controlled vocabulary (burden of proof, uniformity & equality, appraisal, purchase price, the three approaches, obsolescence, market value-in-use, agricultural land, exemption, deduction, timeliness / jurisdiction, methodology / trending, sales chasing, constitutionality, land value / classification, condition, other). Source: Model (the model reading), MonthPage (mapped from the Boards own Issues phrase), Rule.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionIssue';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionIssue', @level2type=N'COLUMN', @level2name=N'IBTRAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One vocabulary value.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionIssue', @level2type=N'COLUMN', @level2name=N'Issue';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Model, MonthPage or Rule.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionIssue', @level2type=N'COLUMN', @level2name=N'Source';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Model rows: high, medium, low.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionIssue', @level2type=N'COLUMN', @level2name=N'Confidence';
GO

-- ---------------------------------------------------------------- IBTRDecisionHolding
CREATE TABLE indiana_tax.IBTRDecisionHolding (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    IBTRAppealID UNIQUEIDENTIFIER NOT NULL,
    PetitionNumbers NVARCHAR(500) NULL,
    AssessmentYears NVARCHAR(100) NULL,
    Outcome NVARCHAR(30) NOT NULL,
    ValueBefore DECIMAL(14,2) NULL,
    ValueAfter DECIMAL(14,2) NULL,
    BurdenOn NVARCHAR(12) NULL,
    BurdenReason NVARCHAR(MAX) NULL,
    PetitionerAppraisal BIT NULL,
    RespondentAppraisal BIT NULL,
    Source NVARCHAR(10) NOT NULL,
    Confidence NVARCHAR(10) NULL,
    CONSTRAINT PK_IBTRDecisionHolding PRIMARY KEY (ID),
    CONSTRAINT FK_IBTRDecisionHolding_IBTRAppeal FOREIGN KEY (IBTRAppealID) REFERENCES indiana_tax.IBTRAppeal(ID),
    CONSTRAINT CK_IBTRDecisionHolding_Outcome CHECK (Outcome IN (N'Sustained', N'Reduced', N'Increased', N'Exemption granted', N'Exemption denied', N'Partial', N'Dismissed', N'Remanded', N'Settled', N'Other')),
    CONSTRAINT CK_IBTRDecisionHolding_BurdenOn CHECK (BurdenOn IS NULL OR BurdenOn IN (N'Petitioner', N'Respondent', N'Shifted', N'Unclear')),
    CONSTRAINT CK_IBTRDecisionHolding_Source CHECK (Source IN (N'Model', N'Reviewed')),
    CONSTRAINT CK_IBTRDecisionHolding_Confidence CHECK (Confidence IS NULL OR Confidence IN (N'high', N'medium', N'low')),
    CONSTRAINT CK_IBTRDecisionHolding_Values CHECK ((ValueBefore IS NULL OR ValueBefore >= 0) AND (ValueAfter IS NULL OR ValueAfter >= 0))
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One result within a decision: the petitions and years it covers, the outcome, the assessed value before and after, where the burden of proof sat and why, and whether each side offered an appraisal. A decision with one lot reduced and another sustained has two rows. From the model reading (Source = Model) until a person marks it Reviewed. Non-precedential: report as counts with case numbers.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'IBTRAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Petition numbers this result covers, comma-separated as printed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'PetitionNumbers';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Assessment years this result covers, comma-separated.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'AssessmentYears';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Sustained, Reduced, Increased, Exemption granted, Exemption denied, Partial, Dismissed, Remanded, Settled, Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'Outcome';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Total assessed value under appeal, dollars.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'ValueBefore';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Total assessed value the Board ordered, dollars.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'ValueAfter';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Petitioner; Respondent or Shifted (the assessor carried it, e.g. under IC 6-1.1-15-17.2 / -20); Unclear (not reached, e.g. settled).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'BurdenOn';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One sentence on why the burden sat where it did.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'BurdenReason';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 if the petitioner put an appraisal into evidence or an appraiser testified; a mere reference to an appraisal is 0.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'PetitionerAppraisal';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Same test for the respondent.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'RespondentAppraisal';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Model or Reviewed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'Source';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'high, medium, low.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionHolding', @level2type=N'COLUMN', @level2name=N'Confidence';
GO

-- ---------------------------------------------------------------- IBTRDecisionChunk
CREATE TABLE indiana_tax.IBTRDecisionChunk (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    IBTRAppealID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,
    Section NVARCHAR(40) NULL,
    Ordinal INT NOT NULL,
    ChunkText NVARCHAR(MAX) NOT NULL,
    TokenCount INT NULL,
    IsOCR BIT NULL,
    CONSTRAINT PK_IBTRDecisionChunk PRIMARY KEY (ID),
    CONSTRAINT FK_IBTRDecisionChunk_IBTRAppeal FOREIGN KEY (IBTRAppealID) REFERENCES indiana_tax.IBTRAppeal(ID),
    CONSTRAINT FK_IBTRDecisionChunk_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument(ID),
    CONSTRAINT CK_IBTRDecisionChunk_Ordinal CHECK (Ordinal >= 0)
);
GO
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'A passage of a decisions text for retrieval: split by section where the decision has headings (Procedural History, Record, Contentions, Burden, Analysis, Conclusion) and by length elsewhere, in reading order. The Search Scope for the Tax Expert agent points here; the IBTRAppeal and its children are the facets that pre-filter a search. Filled by the retrieval step; empty until then.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The decision.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'IBTRAppealID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The decision file the text came from.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'SourceDocumentID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Heading the chunk falls under, or Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'Section';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Position within the decision, from 0.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'Ordinal';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The passage, verbatim.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'ChunkText';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Approximate token count for the chunk.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'TokenCount';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 when the text came from OCR; quotations from such chunks may carry recognition errors.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'IBTRDecisionChunk', @level2type=N'COLUMN', @level2name=N'IsOCR';
GO
