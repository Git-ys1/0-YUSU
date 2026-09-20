# SheetJS

Vendored package: `xlsx@0.18.5`

Use: browser-side parsing for the `/routine/` Tomato ToDo import page.

Reason: the Tomato ToDo `.xls` export is an old OLE/BIFF workbook. Browser-side SheetJS correctly preserves Chinese text, while direct backend Excel COM/xlrd attempts on Windows can produce mojibake in non-interactive Python subprocesses.

License: Apache-2.0, see `LICENSE`.
