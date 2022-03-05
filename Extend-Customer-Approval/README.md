# Extend-Customer-Approval

## Requirment - 

- [x] Every New Customer Require Approval before its used in Sales Transaction (Other Than Sales Quotes).
- [x] If Customer Bank Account is changed the Customer Requires approval Again.
- [x] If Customer Default Dimension Change customer record requires approval again.
- [x] If Customer Record is modified then customer record requires approval again.

## Additional Setup
During Setup of Workflow, Before Enabling the workflow make sure -

- [ ] For workflow event An Approval Request is approved (Pending Approval:0)  
    **Add a Response - Release the document.**