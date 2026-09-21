/* The four vwStoreYear columns omitted from V202609082115 — self-evident in isolation,
   but the wide view documents its equivalents, and a half-documented entity reads as an
   oversight rather than a decision. */

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Surrogate key of the store this row belongs to. Joins to Stores; hidden in the grid because the store is already named by Occupant and Address.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'StoreID';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indiana county the store sits in. Determines the assessor, the record-card layout and the local tax rate, so it is a first-class filter rather than a label.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'County';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City or town of the store, as carried on the roster.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'City';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Street address of the store. With Occupant and City this is the key the parsing pipeline matches on, since the roster carries no single stable store identifier.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'VIEW',   @level1name = N'vwStoreYear', @level2type = N'COLUMN', @level2name = N'Address';
GO
