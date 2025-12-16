# SAP Commissions XML Parser – Modernization TODO

## Scope

I've created an Excel workbook with a few macro's that read from a SAP Commissions xml file and load the contents of it into an easy to read format.

I've personally used this file many times to assess new requirements, check my plan design for errors and many other things.

If you have any suggestions for improvements, please make use of the GitHub Issues and/or Pull Requests.

Installation
To use this project, clone the repository or download a copy of the SAP-Commissions-XML.xlsm.

Download an XML export of your Plan or any other related object.
Hit the Select File button and select your XML file.
Hit the Plan to Excel button to read the XML data.

## Modernization Notes (Fork)

This fork is being updated to better support newer SAP Commissions XML exports
(e.g. XML VERSION="33.0") and additional rule types.

Goals:

- Improve compatibility with current SAP Commissions XML schema.
- Add coverage for missing rule types (e.g. certain INDIRECT rules).
- Strengthen error handling and logging for easier debugging.
- Avoid storing any customer or confidential XML in this repository.