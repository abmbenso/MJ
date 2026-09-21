/* ============================================================================
   Indiana Property Tax Expert -- the APRA request model
   v5.58.x

   Two data sets exist only by public-records request to each county assessor
   (OPP-55): the active roll with property sub-class for an assessment year,
   and the list of parcels appealed that year; a third -- the record cards of
   the 27 counties whose web applications block automation -- is public but
   unreachable. This migration holds who to ask (County, CountyContact), what
   was asked (APRARequest), the timeline of each request (APRARequestEvent)
   and every responsive file (APRAResponseFile), each file a SourceDocument.

   Design: Indiana_Tax_Expert/docs/proposals/apra-request-model.md
   Plan:   Indiana_Tax_Expert/docs/plans/2026-09-13-apra-request-model.md
   Live DocumentType values at write time (2026-09-13, after the IBTR migration V202609130917):
   Other, MarketDataExport, CountyParcelList, StatewideParcelDataset, Memo, ReferenceText, Regulation, Statute, Form, IBTRDecision, BoardDecision, PTABOAFinalDeterminationWithdrawal, PTABOAFinalDeterminationApproval, PTABOAAgenda, TaxHistoryReport, PropertyRecordCard
   ============================================================================ */

CREATE TABLE indiana_tax.County (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyNumber SMALLINT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Slug NVARCHAR(30) NOT NULL,
    FIPS CHAR(5) NULL,
    AssessorOfficeName NVARCHAR(150) NULL,
    AssessorMailingAddress NVARCHAR(200) NULL,
    AssessorCity NVARCHAR(60) NULL,
    AssessorZip NVARCHAR(10) NULL,
    AssessorPhone NVARCHAR(30) NULL,
    AssessorWebsiteURL NVARCHAR(500) NULL,
    APRASubmissionMethod NVARCHAR(10) NOT NULL DEFAULT N'Unknown'
        CONSTRAINT CK_County_APRASubmissionMethod CHECK (APRASubmissionMethod IN (N'Email', N'WebForm', N'Portal', N'Mail', N'Fax', N'Unknown')),
    APRAPortalURL NVARCHAR(500) NULL,
    APRAFormURL NVARCHAR(500) NULL,
    APRAPolicyURL NVARCHAR(500) NULL,
    APRAFeeNotes NVARCHAR(1000) NULL,
    ContactStatus NVARCHAR(15) NOT NULL DEFAULT N'Unresearched'
        CONSTRAINT CK_County_ContactStatus CHECK (ContactStatus IN (N'Unresearched', N'Found', N'Confirmed', N'Blocked')),
    ContactResearchedAt DATETIMEOFFSET NULL,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT PK_County PRIMARY KEY (ID),
    CONSTRAINT UQ_County_Number UNIQUE (CountyNumber),
    CONSTRAINT UQ_County_Slug UNIQUE (Slug),
    CONSTRAINT CK_County_Number CHECK (CountyNumber BETWEEN 1 AND 92)
);
GO

CREATE TABLE indiana_tax.CountyContact (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyID UNIQUEIDENTIFIER NOT NULL,
    Role NVARCHAR(20) NOT NULL
        CONSTRAINT CK_CountyContact_Role CHECK (Role IN (N'Assessor', N'Chief Deputy', N'APRA Custodian', N'Records Clerk', N'County Attorney', N'General Office')),
    Name NVARCHAR(150) NULL,
    Title NVARCHAR(150) NULL,
    Email NVARCHAR(200) NULL,
    Phone NVARCHAR(30) NULL,
    IsAPRARecipient BIT NOT NULL DEFAULT 0,
    EvidenceURL NVARCHAR(1000) NOT NULL,
    EvidenceSourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    Confidence NVARCHAR(6) NOT NULL
        CONSTRAINT CK_CountyContact_Confidence CHECK (Confidence IN (N'High', N'Medium', N'Low')),
    VerifiedAt DATETIMEOFFSET NULL,
    VerifiedBy NVARCHAR(100) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT PK_CountyContact PRIMARY KEY (ID),
    CONSTRAINT FK_CountyContact_County FOREIGN KEY (CountyID) REFERENCES indiana_tax.County (ID),
    CONSTRAINT FK_CountyContact_SourceDocument FOREIGN KEY (EvidenceSourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT UQ_CountyContact UNIQUE (CountyID, Role, Email)
);
GO

CREATE TABLE indiana_tax.APRARequest (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyID UNIQUEIDENTIFIER NOT NULL,
    CountyContactID UNIQUEIDENTIFIER NULL,
    RequestNumber NVARCHAR(30) NOT NULL,
    RequestKind NVARCHAR(20) NOT NULL
        CONSTRAINT CK_APRARequest_RequestKind CHECK (RequestKind IN (N'ActiveRoll', N'AppealedParcels', N'RecordCards', N'Other')),
    AssessmentYear SMALLINT NULL,
    Status NVARCHAR(15) NOT NULL DEFAULT N'Draft'
        CONSTRAINT CK_APRARequest_Status CHECK (Status IN (N'Draft', N'Approved', N'Sent', N'Acknowledged', N'FeeQuoted', N'Partial', N'Fulfilled', N'Denied', N'Withdrawn', N'Escalated', N'Closed')),
    TemplateID UNIQUEIDENTIFIER NULL,
    Subject NVARCHAR(300) NULL,
    RenderedBody NVARCHAR(MAX) NULL,
    SubmissionMethod NVARCHAR(10) NULL
        CONSTRAINT CK_APRARequest_SubmissionMethod CHECK (SubmissionMethod IN (N'Email', N'WebForm', N'Portal', N'Mail', N'Fax', N'Unknown')),
    ToAddress NVARCHAR(300) NULL,
    DraftedAt DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    ApprovedAt DATETIMEOFFSET NULL,
    SentAt DATETIMEOFFSET NULL,
    StatutoryResponseDueAt DATETIMEOFFSET NULL,
    AcknowledgedAt DATETIMEOFFSET NULL,
    FulfilledAt DATETIMEOFFSET NULL,
    DeniedAt DATETIMEOFFSET NULL,
    DenialReason NVARCHAR(MAX) NULL,
    FeeQuoted DECIMAL(10,2) NULL,
    FeePaid DECIMAL(10,2) NULL,
    FeePaidAt DATETIMEOFFSET NULL,
    PACComplaintFiledAt DATETIMEOFFSET NULL,
    PACComplaintNumber NVARCHAR(30) NULL,
    PACOpinionAt DATETIMEOFFSET NULL,
    PACOpinionURL NVARCHAR(500) NULL,
    ProviderMessageID NVARCHAR(200) NULL,
    ProviderThreadID NVARCHAR(200) NULL,
    CommunicationLogID UNIQUEIDENTIFIER NULL,
    RequestSourceDocumentID UNIQUEIDENTIFIER NULL,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT PK_APRARequest PRIMARY KEY (ID),
    CONSTRAINT UQ_APRARequest_Number UNIQUE (RequestNumber),
    CONSTRAINT FK_APRARequest_County FOREIGN KEY (CountyID) REFERENCES indiana_tax.County (ID),
    CONSTRAINT FK_APRARequest_CountyContact FOREIGN KEY (CountyContactID) REFERENCES indiana_tax.CountyContact (ID),
    CONSTRAINT FK_APRARequest_Template FOREIGN KEY (TemplateID) REFERENCES __mj.Template (ID),
    CONSTRAINT FK_APRARequest_CommunicationLog FOREIGN KEY (CommunicationLogID) REFERENCES __mj.CommunicationLog (ID),
    CONSTRAINT FK_APRARequest_SourceDocument FOREIGN KEY (RequestSourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID)
);
GO

CREATE TABLE indiana_tax.APRARequestEvent (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    APRARequestID UNIQUEIDENTIFIER NOT NULL,
    Sequence SMALLINT NOT NULL,
    EventAt DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    EventType NVARCHAR(15) NOT NULL
        CONSTRAINT CK_APRARequestEvent_EventType CHECK (EventType IN (N'Drafted', N'Approved', N'Sent', N'Reminder', N'Acknowledged', N'Clarification', N'FeeQuoted', N'FeePaid', N'Partial', N'Fulfilled', N'Denied', N'Withdrawn', N'PACComplaint', N'PACOpinion', N'Note')),
    Direction NVARCHAR(10) NOT NULL
        CONSTRAINT CK_APRARequestEvent_Direction CHECK (Direction IN (N'Outbound', N'Inbound', N'Internal')),
    Summary NVARCHAR(MAX) NOT NULL,
    ProviderMessageID NVARCHAR(200) NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_APRARequestEvent PRIMARY KEY (ID),
    CONSTRAINT FK_APRARequestEvent_Request FOREIGN KEY (APRARequestID) REFERENCES indiana_tax.APRARequest (ID),
    CONSTRAINT FK_APRARequestEvent_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT UQ_APRARequestEvent UNIQUE (APRARequestID, Sequence)
);
GO

CREATE TABLE indiana_tax.APRAResponseFile (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    APRARequestID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    FileName NVARCHAR(300) NOT NULL,
    MimeType NVARCHAR(100) NULL,
    Bytes BIGINT NULL,
    ReceivedAt DATETIMEOFFSET NOT NULL,
    ProviderAttachmentID NVARCHAR(300) NULL,
    ParseStatus NVARCHAR(10) NOT NULL DEFAULT N'Unparsed'
        CONSTRAINT CK_APRAResponseFile_ParseStatus CHECK (ParseStatus IN (N'Unparsed', N'Parsed', N'Rejected', N'NotData')),
    LoaderName NVARCHAR(100) NULL,
    RowsLoaded INT NULL,
    LoadedAt DATETIMEOFFSET NULL,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT PK_APRAResponseFile PRIMARY KEY (ID),
    CONSTRAINT FK_APRAResponseFile_Request FOREIGN KEY (APRARequestID) REFERENCES indiana_tax.APRARequest (ID),
    CONSTRAINT FK_APRAResponseFile_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT UQ_APRAResponseFile UNIQUE (APRARequestID, SourceDocumentID)
);
GO

ALTER TABLE indiana_tax.CountyResource ADD
    CountyID UNIQUEIDENTIFIER NULL
        CONSTRAINT FK_CountyResource_County FOREIGN KEY REFERENCES indiana_tax.County (ID);
GO

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO
ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
    N'Other', N'MarketDataExport', N'CountyParcelList', N'StatewideParcelDataset', N'Memo', N'ReferenceText', N'Regulation', N'Statute', N'Form', N'IBTRDecision', N'BoardDecision', N'PTABOAFinalDeterminationWithdrawal', N'PTABOAFinalDeterminationApproval', N'PTABOAAgenda', N'TaxHistoryReport', N'PropertyRecordCard',
    N'APRARequest', N'APRAResponse'));
GO

/* ------------------------------------------------------------ descriptions */
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One row per Indiana county (92): the DLGF county number, the assessor office, and how that office takes an Access to Public Records Act request. Owner of "who to ask"; docs/county_records/county_catalog.csv stays the owner of what the county publishes. Seeded by Indiana_Tax_Expert/scripts/load-counties.js; APRA fields filled by load-county-contacts.js from the reviewed harvest.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'DLGF county number, 1 (Adams) to 92 (Whitley). Matches Parcel.CountyNumber.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'CountyNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'County name as county_catalog.csv spells it (St. Joseph, LaGrange, DeKalb).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'Name';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Lowercase letters only (stjoseph, lagrange, dekalb): the join key to county_catalog.csv and to Assessment.Source values of the form apra_<slug>_<year>.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'Slug';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Five-digit county FIPS (18001..18183, odd). Derived: 18 + (2 x CountyNumber - 1).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'FIPS';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The office name as the county prints it (e.g. "Hamilton County Assessor").', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AssessorOfficeName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Street or PO box line of the assessor office mailing address, for a mailed request.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AssessorMailingAddress';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'City of the assessor office mailing address.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AssessorCity';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'ZIP of the assessor office mailing address.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AssessorZip';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Main phone of the assessor office.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AssessorPhone';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The assessor office page on the county site (not a vendor application), as found in the harvest.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AssessorWebsiteURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'How the county says a records request is submitted: Email, WebForm (a form on the county site), Portal (NextRequest/GovQA-style), Mail, Fax, or Unknown until researched.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'APRASubmissionMethod';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'URL of the records-request portal where APRASubmissionMethod = Portal.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'APRAPortalURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'URL of a request form (PDF or web) the county asks requesters to use.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'APRAFormURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'URL of the county page stating its public-records policy or procedure, if one exists.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'APRAPolicyURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'What the county says it charges (per page, per record, media), verbatim, with the page it came from.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'APRAFeeNotes';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Unresearched (seeded only) -> Found (harvest produced a contact with evidence) -> Confirmed (a person verified it, e.g. by a reply) ; Blocked = the county site could not be read without crossing a bot wall.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'ContactStatus';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the harvest last ran for this county.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'ContactResearchedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Free text: what the county site said, quirks, who answers the phone.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'Notes';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'A person or mailbox at a county to whom a public-records request can go. Every row cites the page it was read from (EvidenceURL + the saved page as a SourceDocument). At most one row per county carries IsAPRARecipient = 1 (an integrity check, not a constraint).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Assessor, Chief Deputy, APRA Custodian (a person the county names for records requests), Records Clerk, County Attorney, or General Office (the office mailbox).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Role';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Person''s name as printed; NULL for a mailbox with no named person.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Name';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Title as printed (Assessor, Chief Deputy Assessor, Public Records Officer).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Title';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Email address as printed. NULL where the county publishes only a form or a phone.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Email';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Phone as printed.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Phone';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 on the one contact a request to this county is addressed to. The county''s own instruction wins; else the assessor; else the general office mailbox.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'IsAPRARecipient';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The page this contact was read from. Required.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'EvidenceURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'High: a page names a records custodian or an APRA procedure. Medium: the assessor''s published email. Low: a general office mailbox or a phone only.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Confidence';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When a person confirmed the contact (a reply received, a phone call).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'VerifiedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Who confirmed it.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'VerifiedBy';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'0 once a contact is known to have left or a mailbox bounced; rows are never deleted.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'IsActive';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Free text.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyContact', @level2type=N'COLUMN', @level2name=N'Notes';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One Access to Public Records Act request to one county: what was asked (RequestKind, AssessmentYear), to whom, when, and where it stands. Status is derived from the newest APRARequestEvent and is never edited by hand. The rules the clock relies on are in Indiana_Tax_Expert/docs/county_records/APRA_PROCEDURE.md.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'APRA-<assessment year>-<county number, 3 digits>-<kind letter A/B/C/O>-<sequence, 2 digits>; e.g. APRA-2027-029-A-01 is Hamilton''s first ActiveRoll request for AY2027.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'RequestNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'ActiveRoll = every active parcel with property sub-class and AV for the year; AppealedParcels = the county''s 50 IAC 26 APPEAL file for the year; RecordCards = property record cards for a parcel list; Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'RequestKind';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The assessment year the request is about; NULL for Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'AssessmentYear';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Draft -> Approved (a person approved the rendered letter) -> Sent -> Acknowledged / FeeQuoted / Partial -> Fulfilled | Denied (including deemed denial when the clock runs out) -> Escalated (PAC complaint filed) -> Closed. Withdrawn at any point.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'Status';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The MJ Template the letter was rendered from (Plan 2). NULL for a request drafted by hand.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'TemplateID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Email subject as sent; carries the RequestNumber so replies thread.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'Subject';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The letter as approved and sent, HTML.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'RenderedBody';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'How this request went out (a snapshot of County.APRASubmissionMethod at send time).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'SubmissionMethod';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The address it went to (email, portal URL or postal line), snapshot at send time.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'ToAddress';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the row was created.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'DraftedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When a person approved the rendered letter for sending.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'ApprovedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the provider accepted the message.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'SentAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'SentAt plus the statutory response period for a mailed or emailed request; after it, a silent request is deemed denied. The period and its subsection: docs/county_records/APRA_PROCEDURE.md section 1.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'StatutoryResponseDueAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the county first replied.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'AcknowledgedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the last responsive file arrived and the request was judged complete.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'FulfilledAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When denied, expressly or by the clock.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'DeniedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The county''s stated reason, verbatim; "deemed denied, no response by StatutoryResponseDueAt" for the silent case.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'DenialReason';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Fee the county quoted, dollars.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'FeeQuoted';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Fee paid, dollars. Rolled up against the business plan''s APRA budget line.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'FeePaid';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the fee was paid.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'FeePaidAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When a formal complaint was filed with the Public Access Counselor (IC 5-14-5).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'PACComplaintFiledAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The PAC''s complaint number (e.g. 27-FC-012).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'PACComplaintNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the PAC issued its advisory opinion.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'PACOpinionAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'URL of the opinion on in.gov/pac.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'PACOpinionURL';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The mail provider''s id for the sent message (Gmail message id).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'ProviderMessageID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The provider''s thread id; replies are matched on it (Plan 2).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'ProviderThreadID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The MJ Communication Log row written when the message was sent through the communication engine (Plan 2).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'CommunicationLogID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The letter as sent, archived as a SourceDocument of type APRARequest.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'RequestSourceDocumentID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Free text.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'Notes';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The append-only timeline of one request: every send, reminder, reply, fee, denial and note, with the email or file it came from. The request''s Status is derived from the newest row.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1, 2, 3 ... within the request; the order events happened.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'Sequence';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the event happened (the email''s date for inbound; the send time for outbound).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'EventAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'What happened. Fulfilled and Partial carry files in APRAResponseFile; PACComplaint and PACOpinion carry the escalation.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'EventType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Outbound = we sent it; Inbound = the county sent it; Internal = a note or a status decision by a person.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'Direction';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'One or two sentences: what the message said or what was decided.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'Summary';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The provider''s id of the email this event records, if any.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'ProviderMessageID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The email body or attachment archived as a SourceDocument, if any.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequestEvent', @level2type=N'COLUMN', @level2name=N'SourceDocumentID';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Every file a county sent in response to a request, each a SourceDocument of type APRAResponse (hash, path, retrieval time), with what the normalisation loaders (Plan 3) did with it.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'File name as received.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'FileName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'MIME type as the provider reported it.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'MimeType';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Size in bytes.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'Bytes';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When it arrived (the email''s date).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'ReceivedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The provider''s attachment id, so a re-download is exact.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'ProviderAttachmentID';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Unparsed (arrived) -> Parsed (a loader read it into the domain tables) | Rejected (a loader refused it; Notes says why) | NotData (a letter, an invoice, a form -- not a data file).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'ParseStatus';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The script that parsed it (e.g. load-apra-roll.js).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'LoaderName';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Rows the loader wrote from this file.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'RowsLoaded';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the loader ran.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'LoadedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Free text: why rejected, what was odd.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRAResponseFile', @level2type=N'COLUMN', @level2name=N'Notes';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The County this resource belongs to; backfilled by name from CountyName by Indiana_Tax_Expert/scripts/load-counties.js. NULL only while unmatched.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'CountyResource', @level2type=N'COLUMN', @level2name=N'CountyID';

EXEC sp_updateextendedproperty @name=N'MS_Description', @value=N'What kind of document this is. APRARequest = a public-records request letter as sent; APRAResponse = a file a county returned in response. Other values: PropertyRecordCard, TaxHistoryReport, PTABOAAgenda, PTABOAFinalDeterminationApproval/Withdrawal, BoardDecision, IBTRDecision (if present), Form, Statute, Regulation, ReferenceText, Memo, StatewideParcelDataset, CountyParcelList, MarketDataExport, Other.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'SourceDocument', @level2type=N'COLUMN', @level2name=N'DocumentType';
GO


















































/* ============================================================================================
   EVERYTHING BELOW THIS LINE WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL (mj codegen)
   after the hand-written DDL above was applied on 2026-09-13.

   It contains: EntityField / Entity / EntityRelationship / EntityPermission /
   ApplicationEntity metadata inserts and updates for the five new entities (Counties,
   County Contacts, APRA Requests, APRA Request Events, APRA Response Files) and the
   changed County Resources entity; the regenerated base views (vwCounties,
   vwCountyContacts, vwAPRARequests, vwAPRARequestEvents, vwAPRAResponseFiles,
   vwCountyResources); the spCreate / spUpdate / spDelete procedures; permission grants;
   the __mj_CreatedAt / __mj_UpdatedAt columns and foreign-key indexes; and extended
   properties.

   Excluded from the appended output: one "update virtual entity field UnverifiedCompCount
   for entity Store Analysis" statement -- a pre-existing big_box_retail sequence defect
   CodeGen emits on every run, unrelated to this migration.

   DO NOT EDIT BY HAND. If the hand-written DDL above changes, re-run mj codegen and
   replace this entire generated section.
   ============================================================================================ */

/* SQL generated to create new entity APRA Response Files */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '86f3826d-4650-4fa8-8243-92c254ddde88',
         'APRA Response Files',
         NULL,
         'Every file a county sent in response to a request, each a SourceDocument of type APRAResponse (hash, path, retrieval time), with what the normalisation loaders (Plan 3) did with it.',
         NULL,
         'APRAResponseFile',
         'vwAPRAResponseFiles',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity APRA Response Files to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '86f3826d-4650-4fa8-8243-92c254ddde88', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Response Files for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('86f3826d-4650-4fa8-8243-92c254ddde88', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Response Files for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('86f3826d-4650-4fa8-8243-92c254ddde88', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Response Files for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('86f3826d-4650-4fa8-8243-92c254ddde88', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Counties */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '31ba7a7d-b40b-42ba-a35c-7cac63166e1a',
         'Counties',
         NULL,
         'One row per Indiana county (92): the DLGF county number, the assessor office, and how that office takes an Access to Public Records Act request. Owner of "who to ask"; docs/county_records/county_catalog.csv stays the owner of what the county publishes. Seeded by Indiana_Tax_Expert/scripts/load-counties.js; APRA fields filled by load-county-contacts.js from the reviewed harvest.',
         NULL,
         'County',
         'vwCounties',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity Counties to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '31ba7a7d-b40b-42ba-a35c-7cac63166e1a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Counties for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('31ba7a7d-b40b-42ba-a35c-7cac63166e1a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Counties for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('31ba7a7d-b40b-42ba-a35c-7cac63166e1a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Counties for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('31ba7a7d-b40b-42ba-a35c-7cac63166e1a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity County Contacts */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '2eb91a8d-02c0-48f7-a7d4-de096fe7f6f3',
         'County Contacts',
         NULL,
         'A person or mailbox at a county to whom a public-records request can go. Every row cites the page it was read from (EvidenceURL + the saved page as a SourceDocument). At most one row per county carries IsAPRARecipient = 1 (an integrity check, not a constraint).',
         NULL,
         'CountyContact',
         'vwCountyContacts',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity County Contacts to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '2eb91a8d-02c0-48f7-a7d4-de096fe7f6f3', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity County Contacts for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2eb91a8d-02c0-48f7-a7d4-de096fe7f6f3', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity County Contacts for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2eb91a8d-02c0-48f7-a7d4-de096fe7f6f3', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity County Contacts for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('2eb91a8d-02c0-48f7-a7d4-de096fe7f6f3', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity APRA Requests */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '74c28031-4bae-4d51-b67b-669793a0df7a',
         'APRA Requests',
         NULL,
         'One Access to Public Records Act request to one county: what was asked (RequestKind, AssessmentYear), to whom, when, and where it stands. Status is derived from the newest APRARequestEvent and is never edited by hand. The rules the clock relies on are in Indiana_Tax_Expert/docs/county_records/APRA_PROCEDURE.md.',
         NULL,
         'APRARequest',
         'vwAPRARequests',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity APRA Requests to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '74c28031-4bae-4d51-b67b-669793a0df7a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Requests for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('74c28031-4bae-4d51-b67b-669793a0df7a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Requests for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('74c28031-4bae-4d51-b67b-669793a0df7a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Requests for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('74c28031-4bae-4d51-b67b-669793a0df7a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity APRA Request Events */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'd94b9441-fc01-4661-a4e0-3eb792a829bf',
         'APRA Request Events',
         NULL,
         'The append-only timeline of one request: every send, reminder, reply, fee, denial and note, with the email or file it came from. The request''s Status is derived from the newest row.',
         NULL,
         'APRARequestEvent',
         'vwAPRARequestEvents',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity APRA Request Events to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', 'd94b9441-fc01-4661-a4e0-3eb792a829bf', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Request Events for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d94b9441-fc01-4661-a4e0-3eb792a829bf', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Request Events for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d94b9441-fc01-4661-a4e0-3eb792a829bf', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity APRA Request Events for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('d94b9441-fc01-4661-a4e0-3eb792a829bf', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequestEvent */
ALTER TABLE [indiana_tax].[APRARequestEvent] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequestEvent */
UPDATE [indiana_tax].[APRARequestEvent] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequestEvent */
ALTER TABLE [indiana_tax].[APRARequestEvent] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequestEvent */
ALTER TABLE [indiana_tax].[APRARequestEvent] ADD CONSTRAINT [DF_indiana_tax_APRARequestEvent___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequestEvent */
ALTER TABLE [indiana_tax].[APRARequestEvent] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequestEvent */
UPDATE [indiana_tax].[APRARequestEvent] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequestEvent */
ALTER TABLE [indiana_tax].[APRARequestEvent] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequestEvent */
ALTER TABLE [indiana_tax].[APRARequestEvent] ADD CONSTRAINT [DF_indiana_tax_APRARequestEvent___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequest */
ALTER TABLE [indiana_tax].[APRARequest] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequest */
UPDATE [indiana_tax].[APRARequest] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequest */
ALTER TABLE [indiana_tax].[APRARequest] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRARequest */
ALTER TABLE [indiana_tax].[APRARequest] ADD CONSTRAINT [DF_indiana_tax_APRARequest___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequest */
ALTER TABLE [indiana_tax].[APRARequest] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequest */
UPDATE [indiana_tax].[APRARequest] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequest */
ALTER TABLE [indiana_tax].[APRARequest] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRARequest */
ALTER TABLE [indiana_tax].[APRARequest] ADD CONSTRAINT [DF_indiana_tax_APRARequest___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.County */
ALTER TABLE [indiana_tax].[County] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.County */
UPDATE [indiana_tax].[County] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.County */
ALTER TABLE [indiana_tax].[County] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.County */
ALTER TABLE [indiana_tax].[County] ADD CONSTRAINT [DF_indiana_tax_County___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.County */
ALTER TABLE [indiana_tax].[County] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.County */
UPDATE [indiana_tax].[County] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.County */
ALTER TABLE [indiana_tax].[County] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.County */
ALTER TABLE [indiana_tax].[County] ADD CONSTRAINT [DF_indiana_tax_County___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRAResponseFile */
ALTER TABLE [indiana_tax].[APRAResponseFile] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRAResponseFile */
UPDATE [indiana_tax].[APRAResponseFile] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRAResponseFile */
ALTER TABLE [indiana_tax].[APRAResponseFile] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.APRAResponseFile */
ALTER TABLE [indiana_tax].[APRAResponseFile] ADD CONSTRAINT [DF_indiana_tax_APRAResponseFile___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRAResponseFile */
ALTER TABLE [indiana_tax].[APRAResponseFile] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRAResponseFile */
UPDATE [indiana_tax].[APRAResponseFile] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRAResponseFile */
ALTER TABLE [indiana_tax].[APRAResponseFile] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.APRAResponseFile */
ALTER TABLE [indiana_tax].[APRAResponseFile] ADD CONSTRAINT [DF_indiana_tax_APRAResponseFile___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CountyContact */
ALTER TABLE [indiana_tax].[CountyContact] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CountyContact */
UPDATE [indiana_tax].[CountyContact] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CountyContact */
ALTER TABLE [indiana_tax].[CountyContact] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.CountyContact */
ALTER TABLE [indiana_tax].[CountyContact] ADD CONSTRAINT [DF_indiana_tax_CountyContact___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CountyContact */
ALTER TABLE [indiana_tax].[CountyContact] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CountyContact */
UPDATE [indiana_tax].[CountyContact] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CountyContact */
ALTER TABLE [indiana_tax].[CountyContact] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.CountyContact */
ALTER TABLE [indiana_tax].[CountyContact] ADD CONSTRAINT [DF_indiana_tax_CountyContact___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 99 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2630e6df-1f4e-4f48-bbd3-1ffa46cb0e79' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2630e6df-1f4e-4f48-bbd3-1ffa46cb0e79',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e76f121a-d700-4fde-91c3-dc5c28a32ddf' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'APRARequestID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e76f121a-d700-4fde-91c3-dc5c28a32ddf',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100002,
            'APRARequestID',
            'APRA Request ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '74C28031-4BAE-4D51-B67B-669793A0DF7A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7a1e3068-0d9a-442e-9316-de9e1316bb45' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7a1e3068-0d9a-442e-9316-de9e1316bb45',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100003,
            'Sequence',
            'Sequence',
            '1, 2, 3 ... within the request; the order events happened.',
            'smallint',
            2,
            5,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '28467b0f-31fa-481d-97ae-2e4dbdfc9d97' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'EventAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '28467b0f-31fa-481d-97ae-2e4dbdfc9d97',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100004,
            'EventAt',
            'Event At',
            'When the event happened (the email''s date for inbound; the send time for outbound).',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'sysdatetimeoffset()',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9cb6cc1b-39ed-482d-bc22-be9bbfda5941' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'EventType')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9cb6cc1b-39ed-482d-bc22-be9bbfda5941',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100005,
            'EventType',
            'Event Type',
            'What happened. Fulfilled and Partial carry files in APRAResponseFile; PACComplaint and PACOpinion carry the escalation.',
            'nvarchar',
            30,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c3148b61-3ddd-4653-8825-12a8b135f395' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'Direction')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c3148b61-3ddd-4653-8825-12a8b135f395',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100006,
            'Direction',
            'Direction',
            'Outbound = we sent it; Inbound = the county sent it; Internal = a note or a status decision by a person.',
            'nvarchar',
            20,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '39663e77-3883-4782-aacb-ec85f4ea9072' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'Summary')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '39663e77-3883-4782-aacb-ec85f4ea9072',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100007,
            'Summary',
            'Summary',
            'One or two sentences: what the message said or what was decided.',
            'nvarchar',
            -1,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '403edd1a-8991-46e1-b7f7-19673129a9ed' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'ProviderMessageID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '403edd1a-8991-46e1-b7f7-19673129a9ed',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100008,
            'ProviderMessageID',
            'Provider Message ID',
            'The provider''s id of the email this event records, if any.',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a3854b13-577e-4694-be0d-5053b836dfd4' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = 'SourceDocumentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a3854b13-577e-4694-be0d-5053b836dfd4',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100009,
            'SourceDocumentID',
            'Source Document ID',
            'The email body or attachment archived as a SourceDocument, if any.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd8b677d1-db58-4773-b344-f6e80893a9ea' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd8b677d1-db58-4773-b344-f6e80893a9ea',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100010,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '32c79f15-729f-47db-a4f1-0f49ba16fb6c' OR (EntityID = 'D94B9441-FC01-4661-A4E0-3EB792A829BF' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '32c79f15-729f-47db-a4f1-0f49ba16fb6c',
            'D94B9441-FC01-4661-A4E0-3EB792A829BF', -- Entity: APRA Request Events
            100011,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd184553a-a9b1-4827-883e-645bef035997' OR (EntityID = 'CC733EA2-3B74-46E2-96D3-43F75056606B' AND Name = 'CountyID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd184553a-a9b1-4827-883e-645bef035997',
            'CC733EA2-3B74-46E2-96D3-43F75056606B', -- Entity: County Resources
            100023,
            'CountyID',
            'County ID',
            'The County this resource belongs to; backfilled by name from CountyName by Indiana_Tax_Expert/scripts/load-counties.js. NULL only while unmatched.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '570269fa-4aa9-4ece-bde3-faf2eb003c06' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '570269fa-4aa9-4ece-bde3-faf2eb003c06',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a507c62a-80a6-4e33-b285-c2ed906bd1fe' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'CountyID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a507c62a-80a6-4e33-b285-c2ed906bd1fe',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100002,
            'CountyID',
            'County ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '53cb312c-8a06-4e46-affc-a9285e53e8f3' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'CountyContactID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '53cb312c-8a06-4e46-affc-a9285e53e8f3',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100003,
            'CountyContactID',
            'County Contact ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bfcf6f12-56e9-4d64-88e6-f69754591b63' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'RequestNumber')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bfcf6f12-56e9-4d64-88e6-f69754591b63',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100004,
            'RequestNumber',
            'Request Number',
            'APRA-<assessment year>-<county number, 3 digits>-<kind letter A/B/C/O>-<sequence, 2 digits>; e.g. APRA-2027-029-A-01 is Hamilton''s first ActiveRoll request for AY2027.',
            'nvarchar',
            60,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '72a3cd83-8786-491c-a62f-f7f4f30ddc5e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'RequestKind')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '72a3cd83-8786-491c-a62f-f7f4f30ddc5e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100005,
            'RequestKind',
            'Request Kind',
            'ActiveRoll = every active parcel with property sub-class and AV for the year; AppealedParcels = the county''s 50 IAC 26 APPEAL file for the year; RecordCards = property record cards for a parcel list; Other.',
            'nvarchar',
            40,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '70351eda-ce23-4caf-8624-7d3ae989ae4a' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'AssessmentYear')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '70351eda-ce23-4caf-8624-7d3ae989ae4a',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100006,
            'AssessmentYear',
            'Assessment Year',
            'The assessment year the request is about; NULL for Other.',
            'smallint',
            2,
            5,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '53b1608b-bf86-4903-add7-e45585c5ac57' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'Status')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '53b1608b-bf86-4903-add7-e45585c5ac57',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100007,
            'Status',
            'Status',
            'Draft -> Approved (a person approved the rendered letter) -> Sent -> Acknowledged / FeeQuoted / Partial -> Fulfilled | Denied (including deemed denial when the clock runs out) -> Escalated (PAC complaint filed) -> Closed. Withdrawn at any point.',
            'nvarchar',
            30,
            0,
            0,
            0,
            'Draft',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a3317006-c099-4914-8144-c6561a3c5dd7' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'TemplateID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a3317006-c099-4914-8144-c6561a3c5dd7',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100008,
            'TemplateID',
            'Template ID',
            'The MJ Template the letter was rendered from (Plan 2). NULL for a request drafted by hand.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '48248F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '11934b3d-a738-4fd5-a575-4c92dd740b34' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'Subject')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '11934b3d-a738-4fd5-a575-4c92dd740b34',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100009,
            'Subject',
            'Subject',
            'Email subject as sent; carries the RequestNumber so replies thread.',
            'nvarchar',
            600,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '013dc7e4-99dd-4a1d-aca1-4fa93206ce6e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'RenderedBody')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '013dc7e4-99dd-4a1d-aca1-4fa93206ce6e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100010,
            'RenderedBody',
            'Rendered Body',
            'The letter as approved and sent, HTML.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7fca719a-3776-4b93-b6a2-385fddf9649b' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'SubmissionMethod')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7fca719a-3776-4b93-b6a2-385fddf9649b',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100011,
            'SubmissionMethod',
            'Submission Method',
            'How this request went out (a snapshot of County.APRASubmissionMethod at send time).',
            'nvarchar',
            20,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '31802cc9-ca5f-498e-ab8c-d8949d8a91b7' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ToAddress')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '31802cc9-ca5f-498e-ab8c-d8949d8a91b7',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100012,
            'ToAddress',
            'To Address',
            'The address it went to (email, portal URL or postal line), snapshot at send time.',
            'nvarchar',
            600,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e17066c0-9bb8-4b03-b574-ca28918f0464' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'DraftedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e17066c0-9bb8-4b03-b574-ca28918f0464',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100013,
            'DraftedAt',
            'Drafted At',
            'When the row was created.',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'sysdatetimeoffset()',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '41b43ce5-dc08-4dc5-8ca1-e61408122e5e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ApprovedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '41b43ce5-dc08-4dc5-8ca1-e61408122e5e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100014,
            'ApprovedAt',
            'Approved At',
            'When a person approved the rendered letter for sending.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'df8afd43-2f4c-43c4-a32d-22df19a0fe1a' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'SentAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'df8afd43-2f4c-43c4-a32d-22df19a0fe1a',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100015,
            'SentAt',
            'Sent At',
            'When the provider accepted the message.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8c0ddf4f-c437-4215-888b-0348fcb80a05' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'StatutoryResponseDueAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8c0ddf4f-c437-4215-888b-0348fcb80a05',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100016,
            'StatutoryResponseDueAt',
            'Statutory Response Due At',
            'SentAt plus the statutory response period for a mailed or emailed request; after it, a silent request is deemed denied. The period and its subsection: docs/county_records/APRA_PROCEDURE.md section 1.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6d5d411e-5a09-4c8c-ba15-e4c35255a830' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'AcknowledgedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6d5d411e-5a09-4c8c-ba15-e4c35255a830',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100017,
            'AcknowledgedAt',
            'Acknowledged At',
            'When the county first replied.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '05214ce1-d155-430d-bfce-0daa69ef05fa' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'FulfilledAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '05214ce1-d155-430d-bfce-0daa69ef05fa',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100018,
            'FulfilledAt',
            'Fulfilled At',
            'When the last responsive file arrived and the request was judged complete.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f2509ac0-433a-49d0-a749-f0b331a808fc' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'DeniedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f2509ac0-433a-49d0-a749-f0b331a808fc',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100019,
            'DeniedAt',
            'Denied At',
            'When denied, expressly or by the clock.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '98715d33-5804-491d-a2ed-baf1553a9c27' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'DenialReason')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '98715d33-5804-491d-a2ed-baf1553a9c27',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100020,
            'DenialReason',
            'Denial Reason',
            'The county''s stated reason, verbatim; "deemed denied, no response by StatutoryResponseDueAt" for the silent case.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '10ff47f9-6b9a-4cc1-b178-406b270bdb90' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'FeeQuoted')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '10ff47f9-6b9a-4cc1-b178-406b270bdb90',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100021,
            'FeeQuoted',
            'Fee Quoted',
            'Fee the county quoted, dollars.',
            'decimal',
            9,
            10,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e6268744-f556-4de0-b928-773e595feff7' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'FeePaid')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e6268744-f556-4de0-b928-773e595feff7',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100022,
            'FeePaid',
            'Fee Paid',
            'Fee paid, dollars. Rolled up against the business plan''s APRA budget line.',
            'decimal',
            9,
            10,
            2,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dfd2e1cc-fe72-428e-b64f-3f3920834a6e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'FeePaidAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dfd2e1cc-fe72-428e-b64f-3f3920834a6e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100023,
            'FeePaidAt',
            'Fee Paid At',
            'When the fee was paid.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e90635af-9f3e-4f36-9f93-df1223c58cdd' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'PACComplaintFiledAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e90635af-9f3e-4f36-9f93-df1223c58cdd',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100024,
            'PACComplaintFiledAt',
            'PAC Complaint Filed At',
            'When a formal complaint was filed with the Public Access Counselor (IC 5-14-5).',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a4fe7c3a-1468-4116-8a53-a14751d892f2' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'PACComplaintNumber')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a4fe7c3a-1468-4116-8a53-a14751d892f2',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100025,
            'PACComplaintNumber',
            'PAC Complaint Number',
            'The PAC''s complaint number (e.g. 27-FC-012).',
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '61714a4f-e2a0-4103-ab41-60bf05a0f2b4' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'PACOpinionAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '61714a4f-e2a0-4103-ab41-60bf05a0f2b4',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100026,
            'PACOpinionAt',
            'PAC Opinion At',
            'When the PAC issued its advisory opinion.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f4f678cc-1fd6-4307-aef0-4f028436cc9f' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'PACOpinionURL')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f4f678cc-1fd6-4307-aef0-4f028436cc9f',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100027,
            'PACOpinionURL',
            'PAC Opinion URL',
            'URL of the opinion on in.gov/pac.',
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6c0fc45b-6185-45b4-8cba-bf9970755fe3' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ProviderMessageID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6c0fc45b-6185-45b4-8cba-bf9970755fe3',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100028,
            'ProviderMessageID',
            'Provider Message ID',
            'The mail provider''s id for the sent message (Gmail message id).',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7348d551-5f90-4570-903e-f3aac7d9eb9b' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ProviderThreadID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7348d551-5f90-4570-903e-f3aac7d9eb9b',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100029,
            'ProviderThreadID',
            'Provider Thread ID',
            'The provider''s thread id; replies are matched on it (Plan 2).',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9f88f765-a627-4335-be62-3ed58129038e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'CommunicationLogID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9f88f765-a627-4335-be62-3ed58129038e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100030,
            'CommunicationLogID',
            'Communication Log ID',
            'The MJ Communication Log row written when the message was sent through the communication engine (Plan 2).',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '46248F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ade66ab1-d3a9-430c-a614-aab9c69d6a5a' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'RequestSourceDocumentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ade66ab1-d3a9-430c-a614-aab9c69d6a5a',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100031,
            'RequestSourceDocumentID',
            'Request Source Document ID',
            'The letter as sent, archived as a SourceDocument of type APRARequest.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'aec79b78-1b28-4d05-9023-f91c270c3d5c' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'Notes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'aec79b78-1b28-4d05-9023-f91c270c3d5c',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100032,
            'Notes',
            'Notes',
            'Free text.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6f99c1a0-a4b6-474e-8f6d-0cf43070a8f8' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6f99c1a0-a4b6-474e-8f6d-0cf43070a8f8',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100033,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ea6d6824-ab74-4389-99aa-acd5f922cc1f' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ea6d6824-ab74-4389-99aa-acd5f922cc1f',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100034,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '673844ba-2961-42cd-abb2-ef5672f15b1a' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '673844ba-2961-42cd-abb2-ef5672f15b1a',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '93147b7b-502a-457c-9044-7925240f0e9e' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'CountyNumber')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '93147b7b-502a-457c-9044-7925240f0e9e',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100002,
            'CountyNumber',
            'County Number',
            'DLGF county number, 1 (Adams) to 92 (Whitley). Matches Parcel.CountyNumber.',
            'smallint',
            2,
            5,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2a56c917-49f3-49c8-a41e-96db7cda33f1' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2a56c917-49f3-49c8-a41e-96db7cda33f1',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100003,
            'Name',
            'Name',
            'County name as county_catalog.csv spells it (St. Joseph, LaGrange, DeKalb).',
            'nvarchar',
            100,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '899b6446-d37e-4641-b49b-9e9cf1693c8a' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'Slug')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '899b6446-d37e-4641-b49b-9e9cf1693c8a',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100004,
            'Slug',
            'Slug',
            'Lowercase letters only (stjoseph, lagrange, dekalb): the join key to county_catalog.csv and to Assessment.Source values of the form apra_<slug>_<year>.',
            'nvarchar',
            60,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '19274087-6f79-4144-9522-16402a12de3a' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'FIPS')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '19274087-6f79-4144-9522-16402a12de3a',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100005,
            'FIPS',
            'Fips',
            'Five-digit county FIPS (18001..18183, odd). Derived: 18 + (2 x CountyNumber - 1).',
            'char',
            5,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '20c8098a-19d8-4629-8bc9-28b3d171f5fe' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AssessorOfficeName')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '20c8098a-19d8-4629-8bc9-28b3d171f5fe',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100006,
            'AssessorOfficeName',
            'Assessor Office Name',
            'The office name as the county prints it (e.g. "Hamilton County Assessor").',
            'nvarchar',
            300,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e02ee045-a3c1-48e9-999d-925ef9ff5457' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AssessorMailingAddress')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e02ee045-a3c1-48e9-999d-925ef9ff5457',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100007,
            'AssessorMailingAddress',
            'Assessor Mailing Address',
            'Street or PO box line of the assessor office mailing address, for a mailed request.',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f7718e18-9b6b-496b-963f-f9c6e833d4ae' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AssessorCity')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f7718e18-9b6b-496b-963f-f9c6e833d4ae',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100008,
            'AssessorCity',
            'Assessor City',
            'City of the assessor office mailing address.',
            'nvarchar',
            120,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e661562f-a13e-4553-98f5-3e839636a561' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AssessorZip')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e661562f-a13e-4553-98f5-3e839636a561',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100009,
            'AssessorZip',
            'Assessor Zip',
            'ZIP of the assessor office mailing address.',
            'nvarchar',
            20,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '499a900c-1da4-4e54-9090-6ca4a751af4d' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AssessorPhone')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '499a900c-1da4-4e54-9090-6ca4a751af4d',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100010,
            'AssessorPhone',
            'Assessor Phone',
            'Main phone of the assessor office.',
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f78c0ba1-18a8-4630-ad76-b637c232a48c' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AssessorWebsiteURL')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f78c0ba1-18a8-4630-ad76-b637c232a48c',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100011,
            'AssessorWebsiteURL',
            'Assessor Website URL',
            'The assessor office page on the county site (not a vendor application), as found in the harvest.',
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2c88dfa2-fd94-4834-b50f-9f08f55d2739' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'APRASubmissionMethod')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2c88dfa2-fd94-4834-b50f-9f08f55d2739',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100012,
            'APRASubmissionMethod',
            'APRA Submission Method',
            'How the county says a records request is submitted: Email, WebForm (a form on the county site), Portal (NextRequest/GovQA-style), Mail, Fax, or Unknown until researched.',
            'nvarchar',
            20,
            0,
            0,
            0,
            'Unknown',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b589c01d-0d10-41ed-8586-23c8a5474ed3' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'APRAPortalURL')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b589c01d-0d10-41ed-8586-23c8a5474ed3',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100013,
            'APRAPortalURL',
            'APRA Portal URL',
            'URL of the records-request portal where APRASubmissionMethod = Portal.',
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b59dc796-a518-4f4a-affc-2038cff7acd6' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'APRAFormURL')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b59dc796-a518-4f4a-affc-2038cff7acd6',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100014,
            'APRAFormURL',
            'APRA Form URL',
            'URL of a request form (PDF or web) the county asks requesters to use.',
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'db869ba8-ddde-454b-b56b-0690f171457a' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'APRAPolicyURL')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'db869ba8-ddde-454b-b56b-0690f171457a',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100015,
            'APRAPolicyURL',
            'APRA Policy URL',
            'URL of the county page stating its public-records policy or procedure, if one exists.',
            'nvarchar',
            1000,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6d62c52d-e3bc-4b07-8eba-be73c1ae44a3' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'APRAFeeNotes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6d62c52d-e3bc-4b07-8eba-be73c1ae44a3',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100016,
            'APRAFeeNotes',
            'APRA Fee Notes',
            'What the county says it charges (per page, per record, media), verbatim, with the page it came from.',
            'nvarchar',
            2000,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'debbbcfb-5652-40f1-b562-20adb6b309eb' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'ContactStatus')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'debbbcfb-5652-40f1-b562-20adb6b309eb',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100017,
            'ContactStatus',
            'Contact Status',
            'Unresearched (seeded only) -> Found (harvest produced a contact with evidence) -> Confirmed (a person verified it, e.g. by a reply) ; Blocked = the county site could not be read without crossing a bot wall.',
            'nvarchar',
            30,
            0,
            0,
            0,
            'Unresearched',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7127ffab-72be-4e77-911a-a6a799fa142e' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'ContactResearchedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7127ffab-72be-4e77-911a-a6a799fa142e',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100018,
            'ContactResearchedAt',
            'Contact Researched At',
            'When the harvest last ran for this county.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3091fc39-61e3-4802-9d1c-c28dad368007' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'Notes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3091fc39-61e3-4802-9d1c-c28dad368007',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100019,
            'Notes',
            'Notes',
            'Free text: what the county site said, quirks, who answers the phone.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c7153883-59ac-420a-9fa7-c6a3c5d78817' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c7153883-59ac-420a-9fa7-c6a3c5d78817',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100020,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '236bd00a-ae4a-4038-88bb-3eaf364c889f' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '236bd00a-ae4a-4038-88bb-3eaf364c889f',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100021,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7975ec86-e68b-4af5-bc29-e8c6a1be9695' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7975ec86-e68b-4af5-bc29-e8c6a1be9695',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9403354a-ab0e-4ebd-aa70-e4dd1fb70ad9' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'APRARequestID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9403354a-ab0e-4ebd-aa70-e4dd1fb70ad9',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100002,
            'APRARequestID',
            'APRA Request ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '74C28031-4BAE-4D51-B67B-669793A0DF7A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1774e096-a40c-49a1-9146-7f50e4481e7e' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'SourceDocumentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1774e096-a40c-49a1-9146-7f50e4481e7e',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100003,
            'SourceDocumentID',
            'Source Document ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '895ddb7e-b2dd-4dce-883e-e8f59ccf25c4' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'FileName')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '895ddb7e-b2dd-4dce-883e-e8f59ccf25c4',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100004,
            'FileName',
            'File Name',
            'File name as received.',
            'nvarchar',
            600,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'de946009-6561-49ca-b9b4-091438a326d8' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'MimeType')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'de946009-6561-49ca-b9b4-091438a326d8',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100005,
            'MimeType',
            'Mime Type',
            'MIME type as the provider reported it.',
            'nvarchar',
            200,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b08119bf-df67-40b3-b8b9-371cc1277ffc' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'Bytes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b08119bf-df67-40b3-b8b9-371cc1277ffc',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100006,
            'Bytes',
            'Bytes',
            'Size in bytes.',
            'bigint',
            8,
            19,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ab2aa4d2-8d5b-4617-b259-8bff525536dc' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'ReceivedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ab2aa4d2-8d5b-4617-b259-8bff525536dc',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100007,
            'ReceivedAt',
            'Received At',
            'When it arrived (the email''s date).',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c1f9dbfd-a333-4d9a-96f8-6c3a59c0a961' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'ProviderAttachmentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c1f9dbfd-a333-4d9a-96f8-6c3a59c0a961',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100008,
            'ProviderAttachmentID',
            'Provider Attachment ID',
            'The provider''s attachment id, so a re-download is exact.',
            'nvarchar',
            600,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '163e11e7-eaf5-416a-ac91-f79ecdf22d03' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'ParseStatus')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '163e11e7-eaf5-416a-ac91-f79ecdf22d03',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100009,
            'ParseStatus',
            'Parse Status',
            'Unparsed (arrived) -> Parsed (a loader read it into the domain tables) | Rejected (a loader refused it; Notes says why) | NotData (a letter, an invoice, a form -- not a data file).',
            'nvarchar',
            20,
            0,
            0,
            0,
            'Unparsed',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8d0f7e83-276a-49a8-8c44-fb2c37a1b9d3' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'LoaderName')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8d0f7e83-276a-49a8-8c44-fb2c37a1b9d3',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100010,
            'LoaderName',
            'Loader Name',
            'The script that parsed it (e.g. load-apra-roll.js).',
            'nvarchar',
            200,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '95e014aa-3e44-4e02-9ab2-36ef672adf39' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'RowsLoaded')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '95e014aa-3e44-4e02-9ab2-36ef672adf39',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100011,
            'RowsLoaded',
            'Rows Loaded',
            'Rows the loader wrote from this file.',
            'int',
            4,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '98663974-c6e8-46a2-9b3f-196c4dc66ce8' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'LoadedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '98663974-c6e8-46a2-9b3f-196c4dc66ce8',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100012,
            'LoadedAt',
            'Loaded At',
            'When the loader ran.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5232b4ce-36cb-4113-a342-b774686ab75d' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = 'Notes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5232b4ce-36cb-4113-a342-b774686ab75d',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100013,
            'Notes',
            'Notes',
            'Free text: why rejected, what was odd.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0dcb2b88-4304-4b46-9515-6403b9464f69' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0dcb2b88-4304-4b46-9515-6403b9464f69',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100014,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd042ae64-b332-4484-9697-dd606c00178f' OR (EntityID = '86F3826D-4650-4FA8-8243-92C254DDDE88' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd042ae64-b332-4484-9697-dd606c00178f',
            '86F3826D-4650-4FA8-8243-92C254DDDE88', -- Entity: APRA Response Files
            100015,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '59a79880-8850-43ff-ac69-1c399da3a33b' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'ID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '59a79880-8850-43ff-ac69-1c399da3a33b',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8f6edf04-fb67-4085-a4c9-74441dbb1ca3' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'CountyID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8f6edf04-fb67-4085-a4c9-74441dbb1ca3',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100002,
            'CountyID',
            'County ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7156b824-b117-4984-b61f-ef52647f7e0d' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Role')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7156b824-b117-4984-b61f-ef52647f7e0d',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100003,
            'Role',
            'Role',
            'Assessor, Chief Deputy, APRA Custodian (a person the county names for records requests), Records Clerk, County Attorney, or General Office (the office mailbox).',
            'nvarchar',
            40,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bf2d64f0-1d97-4a0a-8c10-670fbce4bdab' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Name')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bf2d64f0-1d97-4a0a-8c10-670fbce4bdab',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100004,
            'Name',
            'Name',
            'Person''s name as printed; NULL for a mailbox with no named person.',
            'nvarchar',
            300,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            1,
            1,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1f0d9d88-88ef-4660-a1db-add80ba58d50' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Title')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1f0d9d88-88ef-4660-a1db-add80ba58d50',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100005,
            'Title',
            'Title',
            'Title as printed (Assessor, Chief Deputy Assessor, Public Records Officer).',
            'nvarchar',
            300,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7cfb6410-8d7e-4355-8ce6-8c94d6cfe68f' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Email')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7cfb6410-8d7e-4355-8ce6-8c94d6cfe68f',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100006,
            'Email',
            'Email',
            'Email address as printed. NULL where the county publishes only a form or a phone.',
            'nvarchar',
            400,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9d3507fd-5c6e-46fc-8eba-2295890ff51a' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Phone')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9d3507fd-5c6e-46fc-8eba-2295890ff51a',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100007,
            'Phone',
            'Phone',
            'Phone as printed.',
            'nvarchar',
            60,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6be7c4a4-af1d-412c-b821-cbdb7da2332f' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'IsAPRARecipient')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6be7c4a4-af1d-412c-b821-cbdb7da2332f',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100008,
            'IsAPRARecipient',
            'Is APRA Recipient',
            '1 on the one contact a request to this county is addressed to. The county''s own instruction wins; else the assessor; else the general office mailbox.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a214c1dc-2e85-4223-b682-98df90eb751c' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'EvidenceURL')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a214c1dc-2e85-4223-b682-98df90eb751c',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100009,
            'EvidenceURL',
            'Evidence URL',
            'The page this contact was read from. Required.',
            'nvarchar',
            2000,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '73f37a9c-d90d-491e-a405-2a5475e33ead' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'EvidenceSourceDocumentID')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73f37a9c-d90d-491e-a405-2a5475e33ead',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100010,
            'EvidenceSourceDocumentID',
            'Evidence Source Document ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2ca4268a-df13-4a01-8c9c-22f6af794932' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Confidence')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2ca4268a-df13-4a01-8c9c-22f6af794932',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100011,
            'Confidence',
            'Confidence',
            'High: a page names a records custodian or an APRA procedure. Medium: the assessor''s published email. Low: a general office mailbox or a phone only.',
            'nvarchar',
            12,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2fee97b7-0cf5-4323-b7ce-43735de1d612' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'VerifiedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2fee97b7-0cf5-4323-b7ce-43735de1d612',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100012,
            'VerifiedAt',
            'Verified At',
            'When a person confirmed the contact (a reply received, a phone call).',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fa1b50b3-0c45-4db8-aa79-b9659682e1d1' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'VerifiedBy')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fa1b50b3-0c45-4db8-aa79-b9659682e1d1',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100013,
            'VerifiedBy',
            'Verified By',
            'Who confirmed it.',
            'nvarchar',
            200,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '75baac3f-a13d-430c-b00b-184cbfd4413a' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '75baac3f-a13d-430c-b00b-184cbfd4413a',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100014,
            'IsActive',
            'Is Active',
            '0 once a contact is known to have left or a mailbox bounced; rows are never deleted.',
            'bit',
            1,
            1,
            0,
            0,
            '(1)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd3f53577-d3bc-474c-9548-44a10c3da907' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'Notes')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd3f53577-d3bc-474c-9548-44a10c3da907',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100015,
            'Notes',
            'Notes',
            'Free text.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '22907cd2-cd94-4c81-aa28-d8d1df040355' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '22907cd2-cd94-4c81-aa28-d8d1df040355',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100016,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3fcec7e4-e2e7-49f4-b6e9-eb05b1140bca' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3fcec7e4-e2e7-49f4-b6e9-eb05b1140bca',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100017,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to insert entity field value with ID 99366563-acdd-4d8d-b9cb-b60994401f5f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('99366563-acdd-4d8d-b9cb-b60994401f5f', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 1, 'Acknowledged', 'Acknowledged', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c8a6d38d-d7c3-4b14-b743-b8d4924e9385 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c8a6d38d-d7c3-4b14-b743-b8d4924e9385', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 2, 'Approved', 'Approved', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 57124ac5-ce42-49dc-a0a9-e3c0df79382a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('57124ac5-ce42-49dc-a0a9-e3c0df79382a', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 3, 'Clarification', 'Clarification', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 72f2c89a-db19-45bc-ac7d-7446964caa84 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('72f2c89a-db19-45bc-ac7d-7446964caa84', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 4, 'Denied', 'Denied', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 82684d38-3054-43f6-a5f4-1059fa8a9503 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('82684d38-3054-43f6-a5f4-1059fa8a9503', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 5, 'Drafted', 'Drafted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f029c98d-2dd1-4420-9b2e-6f9148bf1680 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f029c98d-2dd1-4420-9b2e-6f9148bf1680', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 6, 'FeePaid', 'FeePaid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9c0c69b3-b08b-40c6-a08c-5cd20a36927b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9c0c69b3-b08b-40c6-a08c-5cd20a36927b', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 7, 'FeeQuoted', 'FeeQuoted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6d7b1432-b261-482a-9de2-5efcfec91408 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6d7b1432-b261-482a-9de2-5efcfec91408', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 8, 'Fulfilled', 'Fulfilled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8547a130-64bb-48d5-bd21-0f29f4f43223 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8547a130-64bb-48d5-bd21-0f29f4f43223', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 9, 'Note', 'Note', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a2842b02-b921-4015-98ba-a6bdb9333284 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a2842b02-b921-4015-98ba-a6bdb9333284', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 10, 'PACComplaint', 'PACComplaint', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1d762ba1-bfa5-49c8-93b4-b069b4846521 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1d762ba1-bfa5-49c8-93b4-b069b4846521', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 11, 'PACOpinion', 'PACOpinion', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 09a2589f-825b-49a5-8781-e0ee01250788 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('09a2589f-825b-49a5-8781-e0ee01250788', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 12, 'Partial', 'Partial', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID cf60cd8a-9db5-4b6b-b682-dac9da09f8d5 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cf60cd8a-9db5-4b6b-b682-dac9da09f8d5', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 13, 'Reminder', 'Reminder', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID efc0e13e-36d5-4635-b523-d623b5207f0b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('efc0e13e-36d5-4635-b523-d623b5207f0b', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 14, 'Sent', 'Sent', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID eab64f52-cbd8-49c5-949c-0dc84f5983f1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('eab64f52-cbd8-49c5-949c-0dc84f5983f1', '9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941', 15, 'Withdrawn', 'Withdrawn', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='9CB6CC1B-39ED-482D-BC22-BE9BBFDA5941';

/* SQL text to insert entity field value with ID c8ed105c-26a2-4c1b-bddb-b72e7add9d35 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c8ed105c-26a2-4c1b-bddb-b72e7add9d35', 'C3148B61-3DDD-4653-8825-12A8B135F395', 1, 'Inbound', 'Inbound', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 530c80cb-8f86-40d6-bc5a-6f883ed211f6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('530c80cb-8f86-40d6-bc5a-6f883ed211f6', 'C3148B61-3DDD-4653-8825-12A8B135F395', 2, 'Internal', 'Internal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 891000c1-805d-424c-bf2a-d78c15b935b7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('891000c1-805d-424c-bf2a-d78c15b935b7', 'C3148B61-3DDD-4653-8825-12A8B135F395', 3, 'Outbound', 'Outbound', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID C3148B61-3DDD-4653-8825-12A8B135F395 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='C3148B61-3DDD-4653-8825-12A8B135F395';

/* SQL text to insert entity field value with ID 417733c8-ed0a-4043-93af-bae040f68a28 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('417733c8-ed0a-4043-93af-bae040f68a28', '163E11E7-EAF5-416A-AC91-F79ECDF22D03', 1, 'NotData', 'NotData', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3db344c8-bf81-4811-8668-5492ae41ff91 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3db344c8-bf81-4811-8668-5492ae41ff91', '163E11E7-EAF5-416A-AC91-F79ECDF22D03', 2, 'Parsed', 'Parsed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 92b454ac-3f8e-456f-8500-c9e7148dea10 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('92b454ac-3f8e-456f-8500-c9e7148dea10', '163E11E7-EAF5-416A-AC91-F79ECDF22D03', 3, 'Rejected', 'Rejected', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7a0dc173-f9e7-4ae9-8a6a-fce8df3642a4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7a0dc173-f9e7-4ae9-8a6a-fce8df3642a4', '163E11E7-EAF5-416A-AC91-F79ECDF22D03', 4, 'Unparsed', 'Unparsed', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 163E11E7-EAF5-416A-AC91-F79ECDF22D03 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='163E11E7-EAF5-416A-AC91-F79ECDF22D03';

/* SQL text to insert entity field value with ID 9081da38-7943-4781-b972-642b13ef020d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9081da38-7943-4781-b972-642b13ef020d', '87A89E7B-9AF6-4231-B9BC-CED6EFAB3A89', 1, 'APRARequest', 'APRARequest', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID af978067-50e7-440f-9de8-473ff913ca85 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('af978067-50e7-440f-9de8-473ff913ca85', '87A89E7B-9AF6-4231-B9BC-CED6EFAB3A89', 2, 'APRAResponse', 'APRAResponse', GETUTCDATE(), GETUTCDATE());

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=3 WHERE ID='A3E4F50F-FC73-43EC-8265-BC04F80B7798';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=4 WHERE ID='89C21CD3-4D52-4329-999C-000F560FAA8C';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=5 WHERE ID='0F8B8602-0843-4F10-8CEF-0AA0A046524D';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=6 WHERE ID='FE4C646A-7D7E-44BF-AD82-94200E61F9F2';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=7 WHERE ID='FC0812A9-CE82-49EC-817B-CD47EF66E33B';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=8 WHERE ID='50199183-966D-48EC-9C44-AF20BE0ECE7F';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=9 WHERE ID='300F56F6-E740-41FB-B6D9-DAC6EB6961AC';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=10 WHERE ID='FB69C6AE-C7D3-4222-9525-C82784868686';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=11 WHERE ID='71E6EA9D-7CF6-4032-8C80-A148EF6597A5';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=12 WHERE ID='1BCEDE69-90C7-4160-B48F-B419BA156448';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=13 WHERE ID='59F7518E-4B47-4445-BEE0-44EC6024CEA5';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=14 WHERE ID='665D9FB7-5DDD-4DB1-816C-5A9043FA286F';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=15 WHERE ID='B035527C-561F-4884-8C1F-943ECBD7D1EE';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=16 WHERE ID='1CD799F8-E71B-48D8-8BAC-8ADFEA01A441';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=17 WHERE ID='906F415E-A30F-4349-81BE-C9D85C14A5FD';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=18 WHERE ID='E858C2C5-EB97-41AE-933C-FCA80E47D19F';

/* SQL text to insert entity field value with ID 212aac54-249b-4ebc-96cb-3732bfc09009 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('212aac54-249b-4ebc-96cb-3732bfc09009', '2C88DFA2-FD94-4834-B50F-9F08F55D2739', 1, 'Email', 'Email', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 449856ae-2940-49dc-9509-f4f7ba25a3c6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('449856ae-2940-49dc-9509-f4f7ba25a3c6', '2C88DFA2-FD94-4834-B50F-9F08F55D2739', 2, 'Fax', 'Fax', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 2eba852e-01d5-43d8-b811-508d6719210c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2eba852e-01d5-43d8-b811-508d6719210c', '2C88DFA2-FD94-4834-B50F-9F08F55D2739', 3, 'Mail', 'Mail', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7a489db2-98e7-4a6b-b1fb-560af3685454 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7a489db2-98e7-4a6b-b1fb-560af3685454', '2C88DFA2-FD94-4834-B50F-9F08F55D2739', 4, 'Portal', 'Portal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d5056d7a-d087-4941-990d-dcd37bddc8e2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d5056d7a-d087-4941-990d-dcd37bddc8e2', '2C88DFA2-FD94-4834-B50F-9F08F55D2739', 5, 'Unknown', 'Unknown', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 697cf238-5de7-4ed1-97ff-60382ff3a43f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('697cf238-5de7-4ed1-97ff-60382ff3a43f', '2C88DFA2-FD94-4834-B50F-9F08F55D2739', 6, 'WebForm', 'WebForm', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 2C88DFA2-FD94-4834-B50F-9F08F55D2739 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='2C88DFA2-FD94-4834-B50F-9F08F55D2739';

/* SQL text to insert entity field value with ID b73af5fe-3385-40e0-8cf8-379a78bf1431 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b73af5fe-3385-40e0-8cf8-379a78bf1431', 'DEBBBCFB-5652-40F1-B562-20ADB6B309EB', 1, 'Blocked', 'Blocked', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6828c5b5-7203-4641-bd1d-3eddae2b49f2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6828c5b5-7203-4641-bd1d-3eddae2b49f2', 'DEBBBCFB-5652-40F1-B562-20ADB6B309EB', 2, 'Confirmed', 'Confirmed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 65765b60-5c02-40ad-8072-d67fd386dcb7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('65765b60-5c02-40ad-8072-d67fd386dcb7', 'DEBBBCFB-5652-40F1-B562-20ADB6B309EB', 3, 'Found', 'Found', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0f954d77-e72d-4728-aab9-bf835362a3f9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0f954d77-e72d-4728-aab9-bf835362a3f9', 'DEBBBCFB-5652-40F1-B562-20ADB6B309EB', 4, 'Unresearched', 'Unresearched', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID DEBBBCFB-5652-40F1-B562-20ADB6B309EB */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='DEBBBCFB-5652-40F1-B562-20ADB6B309EB';

/* SQL text to insert entity field value with ID 0eebc9d1-4323-4901-a694-a39de7fa86f4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0eebc9d1-4323-4901-a694-a39de7fa86f4', '7156B824-B117-4984-B61F-EF52647F7E0D', 1, 'APRA Custodian', 'APRA Custodian', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 09974674-bcec-45e3-b6a7-00cc0610f9c2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('09974674-bcec-45e3-b6a7-00cc0610f9c2', '7156B824-B117-4984-B61F-EF52647F7E0D', 2, 'Assessor', 'Assessor', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 913a8897-223b-4b6c-b172-23c92ef81dd0 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('913a8897-223b-4b6c-b172-23c92ef81dd0', '7156B824-B117-4984-B61F-EF52647F7E0D', 3, 'Chief Deputy', 'Chief Deputy', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4689b140-aba6-4243-98e2-0cab78a79c72 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4689b140-aba6-4243-98e2-0cab78a79c72', '7156B824-B117-4984-B61F-EF52647F7E0D', 4, 'County Attorney', 'County Attorney', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a2e7fe3b-4102-41b7-8929-1aa10dc5085c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a2e7fe3b-4102-41b7-8929-1aa10dc5085c', '7156B824-B117-4984-B61F-EF52647F7E0D', 5, 'General Office', 'General Office', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c53cdb96-5153-48e5-82cb-67ff4701ab67 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c53cdb96-5153-48e5-82cb-67ff4701ab67', '7156B824-B117-4984-B61F-EF52647F7E0D', 6, 'Records Clerk', 'Records Clerk', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 7156B824-B117-4984-B61F-EF52647F7E0D */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='7156B824-B117-4984-B61F-EF52647F7E0D';

/* SQL text to insert entity field value with ID ebb9a8aa-59c5-4744-83c7-c100f86c490d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ebb9a8aa-59c5-4744-83c7-c100f86c490d', '2CA4268A-DF13-4A01-8C9C-22F6AF794932', 1, 'High', 'High', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 93dd975e-ed4d-4f94-9975-45767bd8bc39 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('93dd975e-ed4d-4f94-9975-45767bd8bc39', '2CA4268A-DF13-4A01-8C9C-22F6AF794932', 2, 'Low', 'Low', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID cdbda984-04eb-42ad-97a4-5a702c71e3ea */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cdbda984-04eb-42ad-97a4-5a702c71e3ea', '2CA4268A-DF13-4A01-8C9C-22F6AF794932', 3, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 2CA4268A-DF13-4A01-8C9C-22F6AF794932 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='2CA4268A-DF13-4A01-8C9C-22F6AF794932';

/* SQL text to insert entity field value with ID 0c3b6a22-5444-48ff-a29d-5d1e0c586326 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0c3b6a22-5444-48ff-a29d-5d1e0c586326', '72A3CD83-8786-491C-A62F-F7F4F30DDC5E', 1, 'ActiveRoll', 'ActiveRoll', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 14f9c9d3-43a0-47de-a0e9-5fd27c2396c3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('14f9c9d3-43a0-47de-a0e9-5fd27c2396c3', '72A3CD83-8786-491C-A62F-F7F4F30DDC5E', 2, 'AppealedParcels', 'AppealedParcels', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c8dfac45-36f6-43cd-9a50-babacc876cf0 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c8dfac45-36f6-43cd-9a50-babacc876cf0', '72A3CD83-8786-491C-A62F-F7F4F30DDC5E', 3, 'Other', 'Other', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f811592d-4d50-4f9b-99d6-5a166f3f3895 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f811592d-4d50-4f9b-99d6-5a166f3f3895', '72A3CD83-8786-491C-A62F-F7F4F30DDC5E', 4, 'RecordCards', 'RecordCards', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 72A3CD83-8786-491C-A62F-F7F4F30DDC5E */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='72A3CD83-8786-491C-A62F-F7F4F30DDC5E';

/* SQL text to insert entity field value with ID 0017bd45-b90c-4b6f-9764-db0f24b278ad */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0017bd45-b90c-4b6f-9764-db0f24b278ad', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 1, 'Acknowledged', 'Acknowledged', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c7a6a475-1c4b-4c10-baa6-30c7e968d2b2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c7a6a475-1c4b-4c10-baa6-30c7e968d2b2', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 2, 'Approved', 'Approved', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7cc40225-16e4-4634-af50-8283df0a7f4c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7cc40225-16e4-4634-af50-8283df0a7f4c', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 3, 'Closed', 'Closed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b4a0d905-3033-434a-93c2-276efcd9301d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b4a0d905-3033-434a-93c2-276efcd9301d', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 4, 'Denied', 'Denied', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b826eccd-4c27-4fc5-8569-c79020444aad */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b826eccd-4c27-4fc5-8569-c79020444aad', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 5, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6460b8ec-9c1a-4184-aa16-35d1b9a2d6ab */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6460b8ec-9c1a-4184-aa16-35d1b9a2d6ab', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 6, 'Escalated', 'Escalated', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3985b8ae-1ed2-4a0c-a249-26d02920aed7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3985b8ae-1ed2-4a0c-a249-26d02920aed7', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 7, 'FeeQuoted', 'FeeQuoted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d1fca699-0146-4948-ab6a-da95f9e1108f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d1fca699-0146-4948-ab6a-da95f9e1108f', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 8, 'Fulfilled', 'Fulfilled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d9b5463e-1591-4e5d-9c6e-ced76a23f9d1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d9b5463e-1591-4e5d-9c6e-ced76a23f9d1', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 9, 'Partial', 'Partial', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c4a61e31-396b-4842-8c06-5bbea66f5dd8 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c4a61e31-396b-4842-8c06-5bbea66f5dd8', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 10, 'Sent', 'Sent', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1a265c47-d65a-4d85-85e2-ccc291d5c29c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1a265c47-d65a-4d85-85e2-ccc291d5c29c', '53B1608B-BF86-4903-ADD7-E45585C5AC57', 11, 'Withdrawn', 'Withdrawn', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 53B1608B-BF86-4903-ADD7-E45585C5AC57 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='53B1608B-BF86-4903-ADD7-E45585C5AC57';

/* SQL text to insert entity field value with ID ef94b1bf-9b89-425f-bdce-f41d342c167d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ef94b1bf-9b89-425f-bdce-f41d342c167d', '7FCA719A-3776-4B93-B6A2-385FDDF9649B', 1, 'Email', 'Email', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ebaf8308-6cd5-4d2d-af1f-25aab6f63909 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ebaf8308-6cd5-4d2d-af1f-25aab6f63909', '7FCA719A-3776-4B93-B6A2-385FDDF9649B', 2, 'Fax', 'Fax', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6c45e453-bd03-4f81-b099-a5917b06a2a2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6c45e453-bd03-4f81-b099-a5917b06a2a2', '7FCA719A-3776-4B93-B6A2-385FDDF9649B', 3, 'Mail', 'Mail', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 89c95876-1ebf-44ce-b6ea-89fdad57a5e1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('89c95876-1ebf-44ce-b6ea-89fdad57a5e1', '7FCA719A-3776-4B93-B6A2-385FDDF9649B', 4, 'Portal', 'Portal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b0e8725c-ca59-4038-86c4-8da626edce12 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b0e8725c-ca59-4038-86c4-8da626edce12', '7FCA719A-3776-4B93-B6A2-385FDDF9649B', 5, 'Unknown', 'Unknown', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 43091aaf-9d42-4088-97b1-b46b48941f69 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('43091aaf-9d42-4088-97b1-b46b48941f69', '7FCA719A-3776-4B93-B6A2-385FDDF9649B', 6, 'WebForm', 'WebForm', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 7FCA719A-3776-4B93-B6A2-385FDDF9649B */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='7FCA719A-3776-4B93-B6A2-385FDDF9649B';


/* Create Entity Relationship: Source Documents -> APRA Request Events (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'e4c22c23-77af-43f0-8117-5587101963b0'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e4c22c23-77af-43f0-8117-5587101963b0', '30AF9254-9D7A-442A-A064-0B4448E21AB1', 'D94B9441-FC01-4661-A4E0-3EB792A829BF', 'SourceDocumentID', 'One To Many', 1, 1, 32, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Source Documents -> APRA Requests (One To Many via RequestSourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '9b9fdae2-897d-4234-8276-8519b6d7e90b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9b9fdae2-897d-4234-8276-8519b6d7e90b', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'RequestSourceDocumentID', 'One To Many', 1, 1, 33, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Source Documents -> County Contacts (One To Many via EvidenceSourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'f8cbc781-d4ef-4567-abcd-98e3702e110d'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f8cbc781-d4ef-4567-abcd-98e3702e110d', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', 'EvidenceSourceDocumentID', 'One To Many', 1, 1, 34, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Source Documents -> APRA Response Files (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '8b7bc33d-5545-4134-88ae-8b73ae41caf4'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8b7bc33d-5545-4134-88ae-8b73ae41caf4', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '86F3826D-4650-4FA8-8243-92C254DDDE88', 'SourceDocumentID', 'One To Many', 1, 1, 35, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Communication Logs -> APRA Requests (One To Many via CommunicationLogID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'b82bfdfa-07cb-47d4-9b81-6508df959176'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b82bfdfa-07cb-47d4-9b81-6508df959176', '46248F34-2837-EF11-86D4-6045BDEE16E6', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'CommunicationLogID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Templates -> APRA Requests (One To Many via TemplateID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '923cfa3d-d62c-4f06-82e4-7da2570e1c0a'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('923cfa3d-d62c-4f06-82e4-7da2570e1c0a', '48248F34-2837-EF11-86D4-6045BDEE16E6', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'TemplateID', 'One To Many', 1, 1, 10, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: APRA Requests -> APRA Response Files (One To Many via APRARequestID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '399281be-ed89-410a-a50a-3acdb68c9724'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('399281be-ed89-410a-a50a-3acdb68c9724', '74C28031-4BAE-4D51-B67B-669793A0DF7A', '86F3826D-4650-4FA8-8243-92C254DDDE88', 'APRARequestID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: APRA Requests -> APRA Request Events (One To Many via APRARequestID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '5cf41dfd-6b59-4e46-bda3-e45a5c7e8b34'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5cf41dfd-6b59-4e46-bda3-e45a5c7e8b34', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'D94B9441-FC01-4661-A4E0-3EB792A829BF', 'APRARequestID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Counties -> APRA Requests (One To Many via CountyID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'd12f153c-febe-4283-948b-c6f649deae36'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('d12f153c-febe-4283-948b-c6f649deae36', '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'CountyID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Counties -> County Resources (One To Many via CountyID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '7900bd5a-7c2b-4e59-a1c1-3554e825bc34'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7900bd5a-7c2b-4e59-a1c1-3554e825bc34', '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', 'CC733EA2-3B74-46E2-96D3-43F75056606B', 'CountyID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Counties -> County Contacts (One To Many via CountyID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '8e75b09c-8960-40f4-8551-5a9a62e92d3b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8e75b09c-8960-40f4-8551-5a9a62e92d3b', '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', 'CountyID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: County Contacts -> APRA Requests (One To Many via CountyContactID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '761686d7-5e9a-442e-b2a1-75704adcc413'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('761686d7-5e9a-442e-b2a1-75704adcc413', '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'CountyContactID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;

/* Index for Foreign Keys for APRARequestEvent */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Request Events
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key APRARequestID in table APRARequestEvent
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequestEvent_APRARequestID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequestEvent]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequestEvent_APRARequestID ON [indiana_tax].[APRARequestEvent] ([APRARequestID]);

-- Index for foreign key SourceDocumentID in table APRARequestEvent
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequestEvent_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequestEvent]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequestEvent_SourceDocumentID ON [indiana_tax].[APRARequestEvent] ([SourceDocumentID]);

/* Index for Foreign Keys for APRARequest */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CountyID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_CountyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_CountyID ON [indiana_tax].[APRARequest] ([CountyID]);

-- Index for foreign key CountyContactID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_CountyContactID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_CountyContactID ON [indiana_tax].[APRARequest] ([CountyContactID]);

-- Index for foreign key TemplateID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_TemplateID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_TemplateID ON [indiana_tax].[APRARequest] ([TemplateID]);

-- Index for foreign key CommunicationLogID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_CommunicationLogID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_CommunicationLogID ON [indiana_tax].[APRARequest] ([CommunicationLogID]);

-- Index for foreign key RequestSourceDocumentID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_RequestSourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_RequestSourceDocumentID ON [indiana_tax].[APRARequest] ([RequestSourceDocumentID]);

/* SQL text to update entity field related entity name field map for entity field ID A507C62A-80A6-4E33-B285-C2ED906BD1FE */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A507C62A-80A6-4E33-B285-C2ED906BD1FE', @RelatedEntityNameFieldMap='County';

/* Index for Foreign Keys for APRAResponseFile */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Response Files
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key APRARequestID in table APRAResponseFile
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRAResponseFile_APRARequestID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRAResponseFile]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRAResponseFile_APRARequestID ON [indiana_tax].[APRAResponseFile] ([APRARequestID]);

-- Index for foreign key SourceDocumentID in table APRAResponseFile
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRAResponseFile_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRAResponseFile]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRAResponseFile_SourceDocumentID ON [indiana_tax].[APRAResponseFile] ([SourceDocumentID]);

/* Base View SQL for APRA Request Events */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Request Events
-- Item: vwAPRARequestEvents
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      APRA Request Events
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  APRARequestEvent
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAPRARequestEvents]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAPRARequestEvents];
GO

CREATE VIEW [indiana_tax].[vwAPRARequestEvents]
AS
SELECT
    a.*
FROM
    [indiana_tax].[APRARequestEvent] AS a
GO
GRANT SELECT ON [indiana_tax].[vwAPRARequestEvents] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for APRA Request Events */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Request Events
-- Item: Permissions for vwAPRARequestEvents
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAPRARequestEvents] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for APRA Request Events */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Request Events
-- Item: spCreateAPRARequestEvent
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR APRARequestEvent
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAPRARequestEvent]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAPRARequestEvent];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAPRARequestEvent]
    @ID uniqueidentifier = NULL,
    @APRARequestID uniqueidentifier,
    @Sequence smallint,
    @EventAt datetimeoffset = NULL,
    @EventType nvarchar(15),
    @Direction nvarchar(10),
    @Summary nvarchar(MAX),
    @ProviderMessageID_Clear bit = 0,
    @ProviderMessageID nvarchar(200) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[APRARequestEvent]
            (
                [ID],
                [APRARequestID],
                [Sequence],
                [EventAt],
                [EventType],
                [Direction],
                [Summary],
                [ProviderMessageID],
                [SourceDocumentID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @APRARequestID,
                @Sequence,
                ISNULL(@EventAt, sysdatetimeoffset()),
                @EventType,
                @Direction,
                @Summary,
                CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[APRARequestEvent]
            (
                [APRARequestID],
                [Sequence],
                [EventAt],
                [EventType],
                [Direction],
                [Summary],
                [ProviderMessageID],
                [SourceDocumentID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @APRARequestID,
                @Sequence,
                ISNULL(@EventAt, sysdatetimeoffset()),
                @EventType,
                @Direction,
                @Summary,
                CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAPRARequestEvents] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAPRARequestEvent] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for APRA Request Events */

GRANT EXECUTE ON [indiana_tax].[spCreateAPRARequestEvent] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for APRA Request Events */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Request Events
-- Item: spUpdateAPRARequestEvent
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR APRARequestEvent
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAPRARequestEvent]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAPRARequestEvent];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAPRARequestEvent]
    @ID uniqueidentifier,
    @APRARequestID uniqueidentifier = NULL,
    @Sequence smallint = NULL,
    @EventAt datetimeoffset = NULL,
    @EventType nvarchar(15) = NULL,
    @Direction nvarchar(10) = NULL,
    @Summary nvarchar(MAX) = NULL,
    @ProviderMessageID_Clear bit = 0,
    @ProviderMessageID nvarchar(200) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRARequestEvent]
    SET
        [APRARequestID] = ISNULL(@APRARequestID, [APRARequestID]),
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [EventAt] = ISNULL(@EventAt, [EventAt]),
        [EventType] = ISNULL(@EventType, [EventType]),
        [Direction] = ISNULL(@Direction, [Direction]),
        [Summary] = ISNULL(@Summary, [Summary]),
        [ProviderMessageID] = CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, [ProviderMessageID]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAPRARequestEvents] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAPRARequestEvents]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRARequestEvent] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the APRARequestEvent table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAPRARequestEvent]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAPRARequestEvent];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAPRARequestEvent
ON [indiana_tax].[APRARequestEvent]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRARequestEvent]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[APRARequestEvent] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for APRA Request Events */

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRARequestEvent] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for APRA Response Files */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Response Files
-- Item: vwAPRAResponseFiles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      APRA Response Files
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  APRAResponseFile
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAPRAResponseFiles]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAPRAResponseFiles];
GO

CREATE VIEW [indiana_tax].[vwAPRAResponseFiles]
AS
SELECT
    a.*
FROM
    [indiana_tax].[APRAResponseFile] AS a
GO
GRANT SELECT ON [indiana_tax].[vwAPRAResponseFiles] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for APRA Response Files */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Response Files
-- Item: Permissions for vwAPRAResponseFiles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAPRAResponseFiles] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for APRA Response Files */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Response Files
-- Item: spCreateAPRAResponseFile
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR APRAResponseFile
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAPRAResponseFile]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAPRAResponseFile];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAPRAResponseFile]
    @ID uniqueidentifier = NULL,
    @APRARequestID uniqueidentifier,
    @SourceDocumentID uniqueidentifier,
    @FileName nvarchar(300),
    @MimeType_Clear bit = 0,
    @MimeType nvarchar(100) = NULL,
    @Bytes_Clear bit = 0,
    @Bytes bigint = NULL,
    @ReceivedAt datetimeoffset,
    @ProviderAttachmentID_Clear bit = 0,
    @ProviderAttachmentID nvarchar(300) = NULL,
    @ParseStatus nvarchar(10) = NULL,
    @LoaderName_Clear bit = 0,
    @LoaderName nvarchar(100) = NULL,
    @RowsLoaded_Clear bit = 0,
    @RowsLoaded int = NULL,
    @LoadedAt_Clear bit = 0,
    @LoadedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[APRAResponseFile]
            (
                [ID],
                [APRARequestID],
                [SourceDocumentID],
                [FileName],
                [MimeType],
                [Bytes],
                [ReceivedAt],
                [ProviderAttachmentID],
                [ParseStatus],
                [LoaderName],
                [RowsLoaded],
                [LoadedAt],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @APRARequestID,
                @SourceDocumentID,
                @FileName,
                CASE WHEN @MimeType_Clear = 1 THEN NULL ELSE ISNULL(@MimeType, NULL) END,
                CASE WHEN @Bytes_Clear = 1 THEN NULL ELSE ISNULL(@Bytes, NULL) END,
                @ReceivedAt,
                CASE WHEN @ProviderAttachmentID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderAttachmentID, NULL) END,
                ISNULL(@ParseStatus, 'Unparsed'),
                CASE WHEN @LoaderName_Clear = 1 THEN NULL ELSE ISNULL(@LoaderName, NULL) END,
                CASE WHEN @RowsLoaded_Clear = 1 THEN NULL ELSE ISNULL(@RowsLoaded, NULL) END,
                CASE WHEN @LoadedAt_Clear = 1 THEN NULL ELSE ISNULL(@LoadedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[APRAResponseFile]
            (
                [APRARequestID],
                [SourceDocumentID],
                [FileName],
                [MimeType],
                [Bytes],
                [ReceivedAt],
                [ProviderAttachmentID],
                [ParseStatus],
                [LoaderName],
                [RowsLoaded],
                [LoadedAt],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @APRARequestID,
                @SourceDocumentID,
                @FileName,
                CASE WHEN @MimeType_Clear = 1 THEN NULL ELSE ISNULL(@MimeType, NULL) END,
                CASE WHEN @Bytes_Clear = 1 THEN NULL ELSE ISNULL(@Bytes, NULL) END,
                @ReceivedAt,
                CASE WHEN @ProviderAttachmentID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderAttachmentID, NULL) END,
                ISNULL(@ParseStatus, 'Unparsed'),
                CASE WHEN @LoaderName_Clear = 1 THEN NULL ELSE ISNULL(@LoaderName, NULL) END,
                CASE WHEN @RowsLoaded_Clear = 1 THEN NULL ELSE ISNULL(@RowsLoaded, NULL) END,
                CASE WHEN @LoadedAt_Clear = 1 THEN NULL ELSE ISNULL(@LoadedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAPRAResponseFiles] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAPRAResponseFile] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for APRA Response Files */

GRANT EXECUTE ON [indiana_tax].[spCreateAPRAResponseFile] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for APRA Response Files */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Response Files
-- Item: spUpdateAPRAResponseFile
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR APRAResponseFile
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAPRAResponseFile]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAPRAResponseFile];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAPRAResponseFile]
    @ID uniqueidentifier,
    @APRARequestID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier = NULL,
    @FileName nvarchar(300) = NULL,
    @MimeType_Clear bit = 0,
    @MimeType nvarchar(100) = NULL,
    @Bytes_Clear bit = 0,
    @Bytes bigint = NULL,
    @ReceivedAt datetimeoffset = NULL,
    @ProviderAttachmentID_Clear bit = 0,
    @ProviderAttachmentID nvarchar(300) = NULL,
    @ParseStatus nvarchar(10) = NULL,
    @LoaderName_Clear bit = 0,
    @LoaderName nvarchar(100) = NULL,
    @RowsLoaded_Clear bit = 0,
    @RowsLoaded int = NULL,
    @LoadedAt_Clear bit = 0,
    @LoadedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRAResponseFile]
    SET
        [APRARequestID] = ISNULL(@APRARequestID, [APRARequestID]),
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [FileName] = ISNULL(@FileName, [FileName]),
        [MimeType] = CASE WHEN @MimeType_Clear = 1 THEN NULL ELSE ISNULL(@MimeType, [MimeType]) END,
        [Bytes] = CASE WHEN @Bytes_Clear = 1 THEN NULL ELSE ISNULL(@Bytes, [Bytes]) END,
        [ReceivedAt] = ISNULL(@ReceivedAt, [ReceivedAt]),
        [ProviderAttachmentID] = CASE WHEN @ProviderAttachmentID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderAttachmentID, [ProviderAttachmentID]) END,
        [ParseStatus] = ISNULL(@ParseStatus, [ParseStatus]),
        [LoaderName] = CASE WHEN @LoaderName_Clear = 1 THEN NULL ELSE ISNULL(@LoaderName, [LoaderName]) END,
        [RowsLoaded] = CASE WHEN @RowsLoaded_Clear = 1 THEN NULL ELSE ISNULL(@RowsLoaded, [RowsLoaded]) END,
        [LoadedAt] = CASE WHEN @LoadedAt_Clear = 1 THEN NULL ELSE ISNULL(@LoadedAt, [LoadedAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAPRAResponseFiles] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAPRAResponseFiles]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRAResponseFile] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the APRAResponseFile table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAPRAResponseFile]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAPRAResponseFile];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAPRAResponseFile
ON [indiana_tax].[APRAResponseFile]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRAResponseFile]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[APRAResponseFile] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for APRA Response Files */

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRAResponseFile] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for APRA Request Events */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Request Events
-- Item: spDeleteAPRARequestEvent
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR APRARequestEvent
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAPRARequestEvent]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAPRARequestEvent];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAPRARequestEvent]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[APRARequestEvent]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAPRARequestEvent] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for APRA Request Events */

GRANT EXECUTE ON [indiana_tax].[spDeleteAPRARequestEvent] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for APRA Response Files */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Response Files
-- Item: spDeleteAPRAResponseFile
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR APRAResponseFile
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAPRAResponseFile]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAPRAResponseFile];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAPRAResponseFile]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[APRAResponseFile]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAPRAResponseFile] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for APRA Response Files */

GRANT EXECUTE ON [indiana_tax].[spDeleteAPRAResponseFile] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 53CB312C-8A06-4E46-AFFC-A9285E53E8F3 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='53CB312C-8A06-4E46-AFFC-A9285E53E8F3', @RelatedEntityNameFieldMap='CountyContact';

/* SQL text to update entity field related entity name field map for entity field ID A3317006-C099-4914-8144-C6561A3C5DD7 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A3317006-C099-4914-8144-C6561A3C5DD7', @RelatedEntityNameFieldMap='Template';

/* SQL text to update entity field related entity name field map for entity field ID 9F88F765-A627-4335-BE62-3ED58129038E */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9F88F765-A627-4335-BE62-3ED58129038E', @RelatedEntityNameFieldMap='CommunicationLog';

/* Base View SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: vwAPRARequests
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      APRA Requests
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  APRARequest
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAPRARequests]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAPRARequests];
GO

CREATE VIEW [indiana_tax].[vwAPRARequests]
AS
SELECT
    a.*,
    indianataxCounty_CountyID.[Name] AS [County],
    indianataxCountyContact_CountyContactID.[Name] AS [CountyContact],
    MJTemplate_TemplateID.[Name] AS [Template],
    MJCommunicationLog_CommunicationLogID.[MessageDate] AS [CommunicationLog]
FROM
    [indiana_tax].[APRARequest] AS a
INNER JOIN
    [indiana_tax].[County] AS indianataxCounty_CountyID
  ON
    [a].[CountyID] = indianataxCounty_CountyID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[CountyContact] AS indianataxCountyContact_CountyContactID
  ON
    [a].[CountyContactID] = indianataxCountyContact_CountyContactID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Template] AS MJTemplate_TemplateID
  ON
    [a].[TemplateID] = MJTemplate_TemplateID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[CommunicationLog] AS MJCommunicationLog_CommunicationLogID
  ON
    [a].[CommunicationLogID] = MJCommunicationLog_CommunicationLogID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAPRARequests] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: Permissions for vwAPRARequests
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAPRARequests] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: spCreateAPRARequest
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR APRARequest
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAPRARequest]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAPRARequest];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAPRARequest]
    @ID uniqueidentifier = NULL,
    @CountyID uniqueidentifier,
    @CountyContactID_Clear bit = 0,
    @CountyContactID uniqueidentifier = NULL,
    @RequestNumber nvarchar(30),
    @RequestKind nvarchar(20),
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @Status nvarchar(15) = NULL,
    @TemplateID_Clear bit = 0,
    @TemplateID uniqueidentifier = NULL,
    @Subject_Clear bit = 0,
    @Subject nvarchar(300) = NULL,
    @RenderedBody_Clear bit = 0,
    @RenderedBody nvarchar(MAX) = NULL,
    @SubmissionMethod_Clear bit = 0,
    @SubmissionMethod nvarchar(10) = NULL,
    @ToAddress_Clear bit = 0,
    @ToAddress nvarchar(300) = NULL,
    @DraftedAt datetimeoffset = NULL,
    @ApprovedAt_Clear bit = 0,
    @ApprovedAt datetimeoffset = NULL,
    @SentAt_Clear bit = 0,
    @SentAt datetimeoffset = NULL,
    @StatutoryResponseDueAt_Clear bit = 0,
    @StatutoryResponseDueAt datetimeoffset = NULL,
    @AcknowledgedAt_Clear bit = 0,
    @AcknowledgedAt datetimeoffset = NULL,
    @FulfilledAt_Clear bit = 0,
    @FulfilledAt datetimeoffset = NULL,
    @DeniedAt_Clear bit = 0,
    @DeniedAt datetimeoffset = NULL,
    @DenialReason_Clear bit = 0,
    @DenialReason nvarchar(MAX) = NULL,
    @FeeQuoted_Clear bit = 0,
    @FeeQuoted decimal(10, 2) = NULL,
    @FeePaid_Clear bit = 0,
    @FeePaid decimal(10, 2) = NULL,
    @FeePaidAt_Clear bit = 0,
    @FeePaidAt datetimeoffset = NULL,
    @PACComplaintFiledAt_Clear bit = 0,
    @PACComplaintFiledAt datetimeoffset = NULL,
    @PACComplaintNumber_Clear bit = 0,
    @PACComplaintNumber nvarchar(30) = NULL,
    @PACOpinionAt_Clear bit = 0,
    @PACOpinionAt datetimeoffset = NULL,
    @PACOpinionURL_Clear bit = 0,
    @PACOpinionURL nvarchar(500) = NULL,
    @ProviderMessageID_Clear bit = 0,
    @ProviderMessageID nvarchar(200) = NULL,
    @ProviderThreadID_Clear bit = 0,
    @ProviderThreadID nvarchar(200) = NULL,
    @CommunicationLogID_Clear bit = 0,
    @CommunicationLogID uniqueidentifier = NULL,
    @RequestSourceDocumentID_Clear bit = 0,
    @RequestSourceDocumentID uniqueidentifier = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[APRARequest]
            (
                [ID],
                [CountyID],
                [CountyContactID],
                [RequestNumber],
                [RequestKind],
                [AssessmentYear],
                [Status],
                [TemplateID],
                [Subject],
                [RenderedBody],
                [SubmissionMethod],
                [ToAddress],
                [DraftedAt],
                [ApprovedAt],
                [SentAt],
                [StatutoryResponseDueAt],
                [AcknowledgedAt],
                [FulfilledAt],
                [DeniedAt],
                [DenialReason],
                [FeeQuoted],
                [FeePaid],
                [FeePaidAt],
                [PACComplaintFiledAt],
                [PACComplaintNumber],
                [PACOpinionAt],
                [PACOpinionURL],
                [ProviderMessageID],
                [ProviderThreadID],
                [CommunicationLogID],
                [RequestSourceDocumentID],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyID,
                CASE WHEN @CountyContactID_Clear = 1 THEN NULL ELSE ISNULL(@CountyContactID, NULL) END,
                @RequestNumber,
                @RequestKind,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @TemplateID_Clear = 1 THEN NULL ELSE ISNULL(@TemplateID, NULL) END,
                CASE WHEN @Subject_Clear = 1 THEN NULL ELSE ISNULL(@Subject, NULL) END,
                CASE WHEN @RenderedBody_Clear = 1 THEN NULL ELSE ISNULL(@RenderedBody, NULL) END,
                CASE WHEN @SubmissionMethod_Clear = 1 THEN NULL ELSE ISNULL(@SubmissionMethod, NULL) END,
                CASE WHEN @ToAddress_Clear = 1 THEN NULL ELSE ISNULL(@ToAddress, NULL) END,
                ISNULL(@DraftedAt, sysdatetimeoffset()),
                CASE WHEN @ApprovedAt_Clear = 1 THEN NULL ELSE ISNULL(@ApprovedAt, NULL) END,
                CASE WHEN @SentAt_Clear = 1 THEN NULL ELSE ISNULL(@SentAt, NULL) END,
                CASE WHEN @StatutoryResponseDueAt_Clear = 1 THEN NULL ELSE ISNULL(@StatutoryResponseDueAt, NULL) END,
                CASE WHEN @AcknowledgedAt_Clear = 1 THEN NULL ELSE ISNULL(@AcknowledgedAt, NULL) END,
                CASE WHEN @FulfilledAt_Clear = 1 THEN NULL ELSE ISNULL(@FulfilledAt, NULL) END,
                CASE WHEN @DeniedAt_Clear = 1 THEN NULL ELSE ISNULL(@DeniedAt, NULL) END,
                CASE WHEN @DenialReason_Clear = 1 THEN NULL ELSE ISNULL(@DenialReason, NULL) END,
                CASE WHEN @FeeQuoted_Clear = 1 THEN NULL ELSE ISNULL(@FeeQuoted, NULL) END,
                CASE WHEN @FeePaid_Clear = 1 THEN NULL ELSE ISNULL(@FeePaid, NULL) END,
                CASE WHEN @FeePaidAt_Clear = 1 THEN NULL ELSE ISNULL(@FeePaidAt, NULL) END,
                CASE WHEN @PACComplaintFiledAt_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintFiledAt, NULL) END,
                CASE WHEN @PACComplaintNumber_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintNumber, NULL) END,
                CASE WHEN @PACOpinionAt_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionAt, NULL) END,
                CASE WHEN @PACOpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionURL, NULL) END,
                CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, NULL) END,
                CASE WHEN @ProviderThreadID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderThreadID, NULL) END,
                CASE WHEN @CommunicationLogID_Clear = 1 THEN NULL ELSE ISNULL(@CommunicationLogID, NULL) END,
                CASE WHEN @RequestSourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@RequestSourceDocumentID, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[APRARequest]
            (
                [CountyID],
                [CountyContactID],
                [RequestNumber],
                [RequestKind],
                [AssessmentYear],
                [Status],
                [TemplateID],
                [Subject],
                [RenderedBody],
                [SubmissionMethod],
                [ToAddress],
                [DraftedAt],
                [ApprovedAt],
                [SentAt],
                [StatutoryResponseDueAt],
                [AcknowledgedAt],
                [FulfilledAt],
                [DeniedAt],
                [DenialReason],
                [FeeQuoted],
                [FeePaid],
                [FeePaidAt],
                [PACComplaintFiledAt],
                [PACComplaintNumber],
                [PACOpinionAt],
                [PACOpinionURL],
                [ProviderMessageID],
                [ProviderThreadID],
                [CommunicationLogID],
                [RequestSourceDocumentID],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyID,
                CASE WHEN @CountyContactID_Clear = 1 THEN NULL ELSE ISNULL(@CountyContactID, NULL) END,
                @RequestNumber,
                @RequestKind,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @TemplateID_Clear = 1 THEN NULL ELSE ISNULL(@TemplateID, NULL) END,
                CASE WHEN @Subject_Clear = 1 THEN NULL ELSE ISNULL(@Subject, NULL) END,
                CASE WHEN @RenderedBody_Clear = 1 THEN NULL ELSE ISNULL(@RenderedBody, NULL) END,
                CASE WHEN @SubmissionMethod_Clear = 1 THEN NULL ELSE ISNULL(@SubmissionMethod, NULL) END,
                CASE WHEN @ToAddress_Clear = 1 THEN NULL ELSE ISNULL(@ToAddress, NULL) END,
                ISNULL(@DraftedAt, sysdatetimeoffset()),
                CASE WHEN @ApprovedAt_Clear = 1 THEN NULL ELSE ISNULL(@ApprovedAt, NULL) END,
                CASE WHEN @SentAt_Clear = 1 THEN NULL ELSE ISNULL(@SentAt, NULL) END,
                CASE WHEN @StatutoryResponseDueAt_Clear = 1 THEN NULL ELSE ISNULL(@StatutoryResponseDueAt, NULL) END,
                CASE WHEN @AcknowledgedAt_Clear = 1 THEN NULL ELSE ISNULL(@AcknowledgedAt, NULL) END,
                CASE WHEN @FulfilledAt_Clear = 1 THEN NULL ELSE ISNULL(@FulfilledAt, NULL) END,
                CASE WHEN @DeniedAt_Clear = 1 THEN NULL ELSE ISNULL(@DeniedAt, NULL) END,
                CASE WHEN @DenialReason_Clear = 1 THEN NULL ELSE ISNULL(@DenialReason, NULL) END,
                CASE WHEN @FeeQuoted_Clear = 1 THEN NULL ELSE ISNULL(@FeeQuoted, NULL) END,
                CASE WHEN @FeePaid_Clear = 1 THEN NULL ELSE ISNULL(@FeePaid, NULL) END,
                CASE WHEN @FeePaidAt_Clear = 1 THEN NULL ELSE ISNULL(@FeePaidAt, NULL) END,
                CASE WHEN @PACComplaintFiledAt_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintFiledAt, NULL) END,
                CASE WHEN @PACComplaintNumber_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintNumber, NULL) END,
                CASE WHEN @PACOpinionAt_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionAt, NULL) END,
                CASE WHEN @PACOpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionURL, NULL) END,
                CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, NULL) END,
                CASE WHEN @ProviderThreadID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderThreadID, NULL) END,
                CASE WHEN @CommunicationLogID_Clear = 1 THEN NULL ELSE ISNULL(@CommunicationLogID, NULL) END,
                CASE WHEN @RequestSourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@RequestSourceDocumentID, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAPRARequests] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for APRA Requests */

GRANT EXECUTE ON [indiana_tax].[spCreateAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: spUpdateAPRARequest
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR APRARequest
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAPRARequest]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAPRARequest];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAPRARequest]
    @ID uniqueidentifier,
    @CountyID uniqueidentifier = NULL,
    @CountyContactID_Clear bit = 0,
    @CountyContactID uniqueidentifier = NULL,
    @RequestNumber nvarchar(30) = NULL,
    @RequestKind nvarchar(20) = NULL,
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @Status nvarchar(15) = NULL,
    @TemplateID_Clear bit = 0,
    @TemplateID uniqueidentifier = NULL,
    @Subject_Clear bit = 0,
    @Subject nvarchar(300) = NULL,
    @RenderedBody_Clear bit = 0,
    @RenderedBody nvarchar(MAX) = NULL,
    @SubmissionMethod_Clear bit = 0,
    @SubmissionMethod nvarchar(10) = NULL,
    @ToAddress_Clear bit = 0,
    @ToAddress nvarchar(300) = NULL,
    @DraftedAt datetimeoffset = NULL,
    @ApprovedAt_Clear bit = 0,
    @ApprovedAt datetimeoffset = NULL,
    @SentAt_Clear bit = 0,
    @SentAt datetimeoffset = NULL,
    @StatutoryResponseDueAt_Clear bit = 0,
    @StatutoryResponseDueAt datetimeoffset = NULL,
    @AcknowledgedAt_Clear bit = 0,
    @AcknowledgedAt datetimeoffset = NULL,
    @FulfilledAt_Clear bit = 0,
    @FulfilledAt datetimeoffset = NULL,
    @DeniedAt_Clear bit = 0,
    @DeniedAt datetimeoffset = NULL,
    @DenialReason_Clear bit = 0,
    @DenialReason nvarchar(MAX) = NULL,
    @FeeQuoted_Clear bit = 0,
    @FeeQuoted decimal(10, 2) = NULL,
    @FeePaid_Clear bit = 0,
    @FeePaid decimal(10, 2) = NULL,
    @FeePaidAt_Clear bit = 0,
    @FeePaidAt datetimeoffset = NULL,
    @PACComplaintFiledAt_Clear bit = 0,
    @PACComplaintFiledAt datetimeoffset = NULL,
    @PACComplaintNumber_Clear bit = 0,
    @PACComplaintNumber nvarchar(30) = NULL,
    @PACOpinionAt_Clear bit = 0,
    @PACOpinionAt datetimeoffset = NULL,
    @PACOpinionURL_Clear bit = 0,
    @PACOpinionURL nvarchar(500) = NULL,
    @ProviderMessageID_Clear bit = 0,
    @ProviderMessageID nvarchar(200) = NULL,
    @ProviderThreadID_Clear bit = 0,
    @ProviderThreadID nvarchar(200) = NULL,
    @CommunicationLogID_Clear bit = 0,
    @CommunicationLogID uniqueidentifier = NULL,
    @RequestSourceDocumentID_Clear bit = 0,
    @RequestSourceDocumentID uniqueidentifier = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRARequest]
    SET
        [CountyID] = ISNULL(@CountyID, [CountyID]),
        [CountyContactID] = CASE WHEN @CountyContactID_Clear = 1 THEN NULL ELSE ISNULL(@CountyContactID, [CountyContactID]) END,
        [RequestNumber] = ISNULL(@RequestNumber, [RequestNumber]),
        [RequestKind] = ISNULL(@RequestKind, [RequestKind]),
        [AssessmentYear] = CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, [AssessmentYear]) END,
        [Status] = ISNULL(@Status, [Status]),
        [TemplateID] = CASE WHEN @TemplateID_Clear = 1 THEN NULL ELSE ISNULL(@TemplateID, [TemplateID]) END,
        [Subject] = CASE WHEN @Subject_Clear = 1 THEN NULL ELSE ISNULL(@Subject, [Subject]) END,
        [RenderedBody] = CASE WHEN @RenderedBody_Clear = 1 THEN NULL ELSE ISNULL(@RenderedBody, [RenderedBody]) END,
        [SubmissionMethod] = CASE WHEN @SubmissionMethod_Clear = 1 THEN NULL ELSE ISNULL(@SubmissionMethod, [SubmissionMethod]) END,
        [ToAddress] = CASE WHEN @ToAddress_Clear = 1 THEN NULL ELSE ISNULL(@ToAddress, [ToAddress]) END,
        [DraftedAt] = ISNULL(@DraftedAt, [DraftedAt]),
        [ApprovedAt] = CASE WHEN @ApprovedAt_Clear = 1 THEN NULL ELSE ISNULL(@ApprovedAt, [ApprovedAt]) END,
        [SentAt] = CASE WHEN @SentAt_Clear = 1 THEN NULL ELSE ISNULL(@SentAt, [SentAt]) END,
        [StatutoryResponseDueAt] = CASE WHEN @StatutoryResponseDueAt_Clear = 1 THEN NULL ELSE ISNULL(@StatutoryResponseDueAt, [StatutoryResponseDueAt]) END,
        [AcknowledgedAt] = CASE WHEN @AcknowledgedAt_Clear = 1 THEN NULL ELSE ISNULL(@AcknowledgedAt, [AcknowledgedAt]) END,
        [FulfilledAt] = CASE WHEN @FulfilledAt_Clear = 1 THEN NULL ELSE ISNULL(@FulfilledAt, [FulfilledAt]) END,
        [DeniedAt] = CASE WHEN @DeniedAt_Clear = 1 THEN NULL ELSE ISNULL(@DeniedAt, [DeniedAt]) END,
        [DenialReason] = CASE WHEN @DenialReason_Clear = 1 THEN NULL ELSE ISNULL(@DenialReason, [DenialReason]) END,
        [FeeQuoted] = CASE WHEN @FeeQuoted_Clear = 1 THEN NULL ELSE ISNULL(@FeeQuoted, [FeeQuoted]) END,
        [FeePaid] = CASE WHEN @FeePaid_Clear = 1 THEN NULL ELSE ISNULL(@FeePaid, [FeePaid]) END,
        [FeePaidAt] = CASE WHEN @FeePaidAt_Clear = 1 THEN NULL ELSE ISNULL(@FeePaidAt, [FeePaidAt]) END,
        [PACComplaintFiledAt] = CASE WHEN @PACComplaintFiledAt_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintFiledAt, [PACComplaintFiledAt]) END,
        [PACComplaintNumber] = CASE WHEN @PACComplaintNumber_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintNumber, [PACComplaintNumber]) END,
        [PACOpinionAt] = CASE WHEN @PACOpinionAt_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionAt, [PACOpinionAt]) END,
        [PACOpinionURL] = CASE WHEN @PACOpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionURL, [PACOpinionURL]) END,
        [ProviderMessageID] = CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, [ProviderMessageID]) END,
        [ProviderThreadID] = CASE WHEN @ProviderThreadID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderThreadID, [ProviderThreadID]) END,
        [CommunicationLogID] = CASE WHEN @CommunicationLogID_Clear = 1 THEN NULL ELSE ISNULL(@CommunicationLogID, [CommunicationLogID]) END,
        [RequestSourceDocumentID] = CASE WHEN @RequestSourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@RequestSourceDocumentID, [RequestSourceDocumentID]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAPRARequests] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAPRARequests]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRARequest] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the APRARequest table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAPRARequest]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAPRARequest];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAPRARequest
ON [indiana_tax].[APRARequest]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRARequest]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[APRARequest] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for APRA Requests */

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: spDeleteAPRARequest
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR APRARequest
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAPRARequest]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAPRARequest];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAPRARequest]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[APRARequest]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for APRA Requests */

GRANT EXECUTE ON [indiana_tax].[spDeleteAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for County */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: vwCounties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Counties
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  County
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCounties]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCounties];
GO

CREATE VIEW [indiana_tax].[vwCounties]
AS
SELECT
    c.*
FROM
    [indiana_tax].[County] AS c
GO
GRANT SELECT ON [indiana_tax].[vwCounties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: Permissions for vwCounties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCounties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spCreateCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCounty];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCounty]
    @ID uniqueidentifier = NULL,
    @CountyNumber smallint,
    @Name nvarchar(50),
    @Slug nvarchar(30),
    @FIPS_Clear bit = 0,
    @FIPS char(5) = NULL,
    @AssessorOfficeName_Clear bit = 0,
    @AssessorOfficeName nvarchar(150) = NULL,
    @AssessorMailingAddress_Clear bit = 0,
    @AssessorMailingAddress nvarchar(200) = NULL,
    @AssessorCity_Clear bit = 0,
    @AssessorCity nvarchar(60) = NULL,
    @AssessorZip_Clear bit = 0,
    @AssessorZip nvarchar(10) = NULL,
    @AssessorPhone_Clear bit = 0,
    @AssessorPhone nvarchar(30) = NULL,
    @AssessorWebsiteURL_Clear bit = 0,
    @AssessorWebsiteURL nvarchar(500) = NULL,
    @APRASubmissionMethod nvarchar(10) = NULL,
    @APRAPortalURL_Clear bit = 0,
    @APRAPortalURL nvarchar(500) = NULL,
    @APRAFormURL_Clear bit = 0,
    @APRAFormURL nvarchar(500) = NULL,
    @APRAPolicyURL_Clear bit = 0,
    @APRAPolicyURL nvarchar(500) = NULL,
    @APRAFeeNotes_Clear bit = 0,
    @APRAFeeNotes nvarchar(1000) = NULL,
    @ContactStatus nvarchar(15) = NULL,
    @ContactResearchedAt_Clear bit = 0,
    @ContactResearchedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[County]
            (
                [ID],
                [CountyNumber],
                [Name],
                [Slug],
                [FIPS],
                [AssessorOfficeName],
                [AssessorMailingAddress],
                [AssessorCity],
                [AssessorZip],
                [AssessorPhone],
                [AssessorWebsiteURL],
                [APRASubmissionMethod],
                [APRAPortalURL],
                [APRAFormURL],
                [APRAPolicyURL],
                [APRAFeeNotes],
                [ContactStatus],
                [ContactResearchedAt],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyNumber,
                @Name,
                @Slug,
                CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, NULL) END,
                CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, NULL) END,
                CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, NULL) END,
                CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, NULL) END,
                CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, NULL) END,
                CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, NULL) END,
                CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, NULL) END,
                ISNULL(@APRASubmissionMethod, 'Unknown'),
                CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, NULL) END,
                CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, NULL) END,
                CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, NULL) END,
                CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, NULL) END,
                ISNULL(@ContactStatus, 'Unresearched'),
                CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[County]
            (
                [CountyNumber],
                [Name],
                [Slug],
                [FIPS],
                [AssessorOfficeName],
                [AssessorMailingAddress],
                [AssessorCity],
                [AssessorZip],
                [AssessorPhone],
                [AssessorWebsiteURL],
                [APRASubmissionMethod],
                [APRAPortalURL],
                [APRAFormURL],
                [APRAPolicyURL],
                [APRAFeeNotes],
                [ContactStatus],
                [ContactResearchedAt],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyNumber,
                @Name,
                @Slug,
                CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, NULL) END,
                CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, NULL) END,
                CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, NULL) END,
                CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, NULL) END,
                CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, NULL) END,
                CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, NULL) END,
                CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, NULL) END,
                ISNULL(@APRASubmissionMethod, 'Unknown'),
                CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, NULL) END,
                CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, NULL) END,
                CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, NULL) END,
                CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, NULL) END,
                ISNULL(@ContactStatus, 'Unresearched'),
                CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCounties] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCounty] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spCreateCounty] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spUpdateCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCounty];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCounty]
    @ID uniqueidentifier,
    @CountyNumber smallint = NULL,
    @Name nvarchar(50) = NULL,
    @Slug nvarchar(30) = NULL,
    @FIPS_Clear bit = 0,
    @FIPS char(5) = NULL,
    @AssessorOfficeName_Clear bit = 0,
    @AssessorOfficeName nvarchar(150) = NULL,
    @AssessorMailingAddress_Clear bit = 0,
    @AssessorMailingAddress nvarchar(200) = NULL,
    @AssessorCity_Clear bit = 0,
    @AssessorCity nvarchar(60) = NULL,
    @AssessorZip_Clear bit = 0,
    @AssessorZip nvarchar(10) = NULL,
    @AssessorPhone_Clear bit = 0,
    @AssessorPhone nvarchar(30) = NULL,
    @AssessorWebsiteURL_Clear bit = 0,
    @AssessorWebsiteURL nvarchar(500) = NULL,
    @APRASubmissionMethod nvarchar(10) = NULL,
    @APRAPortalURL_Clear bit = 0,
    @APRAPortalURL nvarchar(500) = NULL,
    @APRAFormURL_Clear bit = 0,
    @APRAFormURL nvarchar(500) = NULL,
    @APRAPolicyURL_Clear bit = 0,
    @APRAPolicyURL nvarchar(500) = NULL,
    @APRAFeeNotes_Clear bit = 0,
    @APRAFeeNotes nvarchar(1000) = NULL,
    @ContactStatus nvarchar(15) = NULL,
    @ContactResearchedAt_Clear bit = 0,
    @ContactResearchedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[County]
    SET
        [CountyNumber] = ISNULL(@CountyNumber, [CountyNumber]),
        [Name] = ISNULL(@Name, [Name]),
        [Slug] = ISNULL(@Slug, [Slug]),
        [FIPS] = CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, [FIPS]) END,
        [AssessorOfficeName] = CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, [AssessorOfficeName]) END,
        [AssessorMailingAddress] = CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, [AssessorMailingAddress]) END,
        [AssessorCity] = CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, [AssessorCity]) END,
        [AssessorZip] = CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, [AssessorZip]) END,
        [AssessorPhone] = CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, [AssessorPhone]) END,
        [AssessorWebsiteURL] = CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, [AssessorWebsiteURL]) END,
        [APRASubmissionMethod] = ISNULL(@APRASubmissionMethod, [APRASubmissionMethod]),
        [APRAPortalURL] = CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, [APRAPortalURL]) END,
        [APRAFormURL] = CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, [APRAFormURL]) END,
        [APRAPolicyURL] = CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, [APRAPolicyURL]) END,
        [APRAFeeNotes] = CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, [APRAFeeNotes]) END,
        [ContactStatus] = ISNULL(@ContactStatus, [ContactStatus]),
        [ContactResearchedAt] = CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, [ContactResearchedAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCounties] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCounties]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCounty] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the County table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCounty]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCounty];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCounty
ON [indiana_tax].[County]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[County]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[County] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spUpdateCounty] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spDeleteCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCounty];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCounty]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[County]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCounty] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spDeleteCounty] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for CountyContact */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Contacts
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CountyID in table CountyContact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyContact_CountyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyContact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyContact_CountyID ON [indiana_tax].[CountyContact] ([CountyID]);

-- Index for foreign key EvidenceSourceDocumentID in table CountyContact
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyContact_EvidenceSourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyContact]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyContact_EvidenceSourceDocumentID ON [indiana_tax].[CountyContact] ([EvidenceSourceDocumentID]);

/* SQL text to update entity field related entity name field map for entity field ID 8F6EDF04-FB67-4085-A4C9-74441DBB1CA3 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='8F6EDF04-FB67-4085-A4C9-74441DBB1CA3', @RelatedEntityNameFieldMap='County';

/* Index for Foreign Keys for CountyResource */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Resources
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceRegistryID in table CountyResource
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyResource_SourceRegistryID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyResource]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyResource_SourceRegistryID ON [indiana_tax].[CountyResource] ([SourceRegistryID]);

-- Index for foreign key CountyID in table CountyResource
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyResource_CountyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyResource]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyResource_CountyID ON [indiana_tax].[CountyResource] ([CountyID]);

/* SQL text to update entity field related entity name field map for entity field ID D184553A-A9B1-4827-883E-645BEF035997 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D184553A-A9B1-4827-883E-645BEF035997', @RelatedEntityNameFieldMap='County';

/* Base View SQL for County Resources */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Resources
-- Item: vwCountyResources
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      County Resources
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CountyResource
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCountyResources]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCountyResources];
GO

CREATE VIEW [indiana_tax].[vwCountyResources]
AS
SELECT
    c.*,
    indianataxSourceRegistry_SourceRegistryID.[Name] AS [SourceRegistry],
    indianataxCounty_CountyID.[Name] AS [County]
FROM
    [indiana_tax].[CountyResource] AS c
LEFT OUTER JOIN
    [indiana_tax].[SourceRegistry] AS indianataxSourceRegistry_SourceRegistryID
  ON
    [c].[SourceRegistryID] = indianataxSourceRegistry_SourceRegistryID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[County] AS indianataxCounty_CountyID
  ON
    [c].[CountyID] = indianataxCounty_CountyID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCountyResources] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for County Resources */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Resources
-- Item: Permissions for vwCountyResources
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCountyResources] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for County Resources */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Resources
-- Item: spCreateCountyResource
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CountyResource
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCountyResource]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCountyResource];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCountyResource]
    @ID uniqueidentifier = NULL,
    @CountyName nvarchar(50),
    @ResourceLabel nvarchar(200),
    @ResourceCategory_Clear bit = 0,
    @ResourceCategory nvarchar(30) = NULL,
    @ResourceURL nvarchar(1000),
    @Phone_Clear bit = 0,
    @Phone nvarchar(30) = NULL,
    @SourceRegistryID_Clear bit = 0,
    @SourceRegistryID uniqueidentifier = NULL,
    @DiscoveredAt datetimeoffset = NULL,
    @CountyID_Clear bit = 0,
    @CountyID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CountyResource]
            (
                [ID],
                [CountyName],
                [ResourceLabel],
                [ResourceCategory],
                [ResourceURL],
                [Phone],
                [SourceRegistryID],
                [DiscoveredAt],
                [CountyID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyName,
                @ResourceLabel,
                CASE WHEN @ResourceCategory_Clear = 1 THEN NULL ELSE ISNULL(@ResourceCategory, NULL) END,
                @ResourceURL,
                CASE WHEN @Phone_Clear = 1 THEN NULL ELSE ISNULL(@Phone, NULL) END,
                CASE WHEN @SourceRegistryID_Clear = 1 THEN NULL ELSE ISNULL(@SourceRegistryID, NULL) END,
                ISNULL(@DiscoveredAt, sysdatetimeoffset()),
                CASE WHEN @CountyID_Clear = 1 THEN NULL ELSE ISNULL(@CountyID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CountyResource]
            (
                [CountyName],
                [ResourceLabel],
                [ResourceCategory],
                [ResourceURL],
                [Phone],
                [SourceRegistryID],
                [DiscoveredAt],
                [CountyID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyName,
                @ResourceLabel,
                CASE WHEN @ResourceCategory_Clear = 1 THEN NULL ELSE ISNULL(@ResourceCategory, NULL) END,
                @ResourceURL,
                CASE WHEN @Phone_Clear = 1 THEN NULL ELSE ISNULL(@Phone, NULL) END,
                CASE WHEN @SourceRegistryID_Clear = 1 THEN NULL ELSE ISNULL(@SourceRegistryID, NULL) END,
                ISNULL(@DiscoveredAt, sysdatetimeoffset()),
                CASE WHEN @CountyID_Clear = 1 THEN NULL ELSE ISNULL(@CountyID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCountyResources] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCountyResource] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for County Resources */

GRANT EXECUTE ON [indiana_tax].[spCreateCountyResource] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for County Resources */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Resources
-- Item: spUpdateCountyResource
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CountyResource
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCountyResource]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCountyResource];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCountyResource]
    @ID uniqueidentifier,
    @CountyName nvarchar(50) = NULL,
    @ResourceLabel nvarchar(200) = NULL,
    @ResourceCategory_Clear bit = 0,
    @ResourceCategory nvarchar(30) = NULL,
    @ResourceURL nvarchar(1000) = NULL,
    @Phone_Clear bit = 0,
    @Phone nvarchar(30) = NULL,
    @SourceRegistryID_Clear bit = 0,
    @SourceRegistryID uniqueidentifier = NULL,
    @DiscoveredAt datetimeoffset = NULL,
    @CountyID_Clear bit = 0,
    @CountyID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyResource]
    SET
        [CountyName] = ISNULL(@CountyName, [CountyName]),
        [ResourceLabel] = ISNULL(@ResourceLabel, [ResourceLabel]),
        [ResourceCategory] = CASE WHEN @ResourceCategory_Clear = 1 THEN NULL ELSE ISNULL(@ResourceCategory, [ResourceCategory]) END,
        [ResourceURL] = ISNULL(@ResourceURL, [ResourceURL]),
        [Phone] = CASE WHEN @Phone_Clear = 1 THEN NULL ELSE ISNULL(@Phone, [Phone]) END,
        [SourceRegistryID] = CASE WHEN @SourceRegistryID_Clear = 1 THEN NULL ELSE ISNULL(@SourceRegistryID, [SourceRegistryID]) END,
        [DiscoveredAt] = ISNULL(@DiscoveredAt, [DiscoveredAt]),
        [CountyID] = CASE WHEN @CountyID_Clear = 1 THEN NULL ELSE ISNULL(@CountyID, [CountyID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCountyResources] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCountyResources]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyResource] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CountyResource table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCountyResource]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCountyResource];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCountyResource
ON [indiana_tax].[CountyResource]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyResource]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CountyResource] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for County Resources */

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyResource] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for County Resources */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Resources
-- Item: spDeleteCountyResource
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CountyResource
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCountyResource]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCountyResource];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCountyResource]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CountyResource]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCountyResource] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for County Resources */

GRANT EXECUTE ON [indiana_tax].[spDeleteCountyResource] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for County Contacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Contacts
-- Item: vwCountyContacts
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      County Contacts
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CountyContact
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCountyContacts]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCountyContacts];
GO

CREATE VIEW [indiana_tax].[vwCountyContacts]
AS
SELECT
    c.*,
    indianataxCounty_CountyID.[Name] AS [County]
FROM
    [indiana_tax].[CountyContact] AS c
INNER JOIN
    [indiana_tax].[County] AS indianataxCounty_CountyID
  ON
    [c].[CountyID] = indianataxCounty_CountyID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCountyContacts] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for County Contacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Contacts
-- Item: Permissions for vwCountyContacts
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCountyContacts] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for County Contacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Contacts
-- Item: spCreateCountyContact
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CountyContact
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCountyContact]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCountyContact];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCountyContact]
    @ID uniqueidentifier = NULL,
    @CountyID uniqueidentifier,
    @Role nvarchar(20),
    @Name_Clear bit = 0,
    @Name nvarchar(150) = NULL,
    @Title_Clear bit = 0,
    @Title nvarchar(150) = NULL,
    @Email_Clear bit = 0,
    @Email nvarchar(200) = NULL,
    @Phone_Clear bit = 0,
    @Phone nvarchar(30) = NULL,
    @IsAPRARecipient bit = NULL,
    @EvidenceURL nvarchar(1000),
    @EvidenceSourceDocumentID uniqueidentifier,
    @Confidence nvarchar(6),
    @VerifiedAt_Clear bit = 0,
    @VerifiedAt datetimeoffset = NULL,
    @VerifiedBy_Clear bit = 0,
    @VerifiedBy nvarchar(100) = NULL,
    @IsActive bit = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CountyContact]
            (
                [ID],
                [CountyID],
                [Role],
                [Name],
                [Title],
                [Email],
                [Phone],
                [IsAPRARecipient],
                [EvidenceURL],
                [EvidenceSourceDocumentID],
                [Confidence],
                [VerifiedAt],
                [VerifiedBy],
                [IsActive],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyID,
                @Role,
                CASE WHEN @Name_Clear = 1 THEN NULL ELSE ISNULL(@Name, NULL) END,
                CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, NULL) END,
                CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, NULL) END,
                CASE WHEN @Phone_Clear = 1 THEN NULL ELSE ISNULL(@Phone, NULL) END,
                ISNULL(@IsAPRARecipient, 0),
                @EvidenceURL,
                @EvidenceSourceDocumentID,
                @Confidence,
                CASE WHEN @VerifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@VerifiedAt, NULL) END,
                CASE WHEN @VerifiedBy_Clear = 1 THEN NULL ELSE ISNULL(@VerifiedBy, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CountyContact]
            (
                [CountyID],
                [Role],
                [Name],
                [Title],
                [Email],
                [Phone],
                [IsAPRARecipient],
                [EvidenceURL],
                [EvidenceSourceDocumentID],
                [Confidence],
                [VerifiedAt],
                [VerifiedBy],
                [IsActive],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyID,
                @Role,
                CASE WHEN @Name_Clear = 1 THEN NULL ELSE ISNULL(@Name, NULL) END,
                CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, NULL) END,
                CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, NULL) END,
                CASE WHEN @Phone_Clear = 1 THEN NULL ELSE ISNULL(@Phone, NULL) END,
                ISNULL(@IsAPRARecipient, 0),
                @EvidenceURL,
                @EvidenceSourceDocumentID,
                @Confidence,
                CASE WHEN @VerifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@VerifiedAt, NULL) END,
                CASE WHEN @VerifiedBy_Clear = 1 THEN NULL ELSE ISNULL(@VerifiedBy, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCountyContacts] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCountyContact] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for County Contacts */

GRANT EXECUTE ON [indiana_tax].[spCreateCountyContact] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for County Contacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Contacts
-- Item: spUpdateCountyContact
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CountyContact
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCountyContact]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCountyContact];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCountyContact]
    @ID uniqueidentifier,
    @CountyID uniqueidentifier = NULL,
    @Role nvarchar(20) = NULL,
    @Name_Clear bit = 0,
    @Name nvarchar(150) = NULL,
    @Title_Clear bit = 0,
    @Title nvarchar(150) = NULL,
    @Email_Clear bit = 0,
    @Email nvarchar(200) = NULL,
    @Phone_Clear bit = 0,
    @Phone nvarchar(30) = NULL,
    @IsAPRARecipient bit = NULL,
    @EvidenceURL nvarchar(1000) = NULL,
    @EvidenceSourceDocumentID uniqueidentifier = NULL,
    @Confidence nvarchar(6) = NULL,
    @VerifiedAt_Clear bit = 0,
    @VerifiedAt datetimeoffset = NULL,
    @VerifiedBy_Clear bit = 0,
    @VerifiedBy nvarchar(100) = NULL,
    @IsActive bit = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyContact]
    SET
        [CountyID] = ISNULL(@CountyID, [CountyID]),
        [Role] = ISNULL(@Role, [Role]),
        [Name] = CASE WHEN @Name_Clear = 1 THEN NULL ELSE ISNULL(@Name, [Name]) END,
        [Title] = CASE WHEN @Title_Clear = 1 THEN NULL ELSE ISNULL(@Title, [Title]) END,
        [Email] = CASE WHEN @Email_Clear = 1 THEN NULL ELSE ISNULL(@Email, [Email]) END,
        [Phone] = CASE WHEN @Phone_Clear = 1 THEN NULL ELSE ISNULL(@Phone, [Phone]) END,
        [IsAPRARecipient] = ISNULL(@IsAPRARecipient, [IsAPRARecipient]),
        [EvidenceURL] = ISNULL(@EvidenceURL, [EvidenceURL]),
        [EvidenceSourceDocumentID] = ISNULL(@EvidenceSourceDocumentID, [EvidenceSourceDocumentID]),
        [Confidence] = ISNULL(@Confidence, [Confidence]),
        [VerifiedAt] = CASE WHEN @VerifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@VerifiedAt, [VerifiedAt]) END,
        [VerifiedBy] = CASE WHEN @VerifiedBy_Clear = 1 THEN NULL ELSE ISNULL(@VerifiedBy, [VerifiedBy]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCountyContacts] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCountyContacts]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyContact] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CountyContact table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCountyContact]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCountyContact];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCountyContact
ON [indiana_tax].[CountyContact]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyContact]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CountyContact] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for County Contacts */

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyContact] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for County Contacts */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Contacts
-- Item: spDeleteCountyContact
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CountyContact
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCountyContact]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCountyContact];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCountyContact]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CountyContact]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCountyContact] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for County Contacts */

GRANT EXECUTE ON [indiana_tax].[spDeleteCountyContact] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 6 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '17d88dc5-6c31-45f1-a565-ee592312e4dd' OR (EntityID = 'CC733EA2-3B74-46E2-96D3-43F75056606B' AND Name = 'County')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '17d88dc5-6c31-45f1-a565-ee592312e4dd',
            'CC733EA2-3B74-46E2-96D3-43F75056606B', -- Entity: County Resources
            100025,
            'County',
            'County',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a5d4b7a2-b07e-42df-986e-32a0d5b0f052' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'County')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a5d4b7a2-b07e-42df-986e-32a0d5b0f052',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100069,
            'County',
            'County',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '543aac8b-99ed-4c16-9e1b-8be6aef4f72e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'CountyContact')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '543aac8b-99ed-4c16-9e1b-8be6aef4f72e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100070,
            'CountyContact',
            'County Contact',
            NULL,
            'nvarchar',
            300,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'db54dda5-736f-4a41-a04d-0e099e80b070' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'Template')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'db54dda5-736f-4a41-a04d-0e099e80b070',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100071,
            'Template',
            'Template',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3beda3b0-16b7-4f56-9c32-389f2ee860bc' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'CommunicationLog')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3beda3b0-16b7-4f56-9c32-389f2ee860bc',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100072,
            'CommunicationLog',
            'Communication Log',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd3336d87-47e3-4cb5-b4dd-37b80b278b04' OR (EntityID = '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3' AND Name = 'County')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd3336d87-47e3-4cb5-b4dd-37b80b278b04',
            '2EB91A8D-02C0-48F7-A7D4-DE096FE7F6F3', -- Entity: County Contacts
            100035,
            'County',
            'County',
            NULL,
            'nvarchar',
            100,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

