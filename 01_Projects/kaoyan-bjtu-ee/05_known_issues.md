# Known Issues

## 学硕和专硕容易混

2026 catalog lists both:

- `080800 电气工程` - academic master's, target of this project.
- `085801 电气工程（专业学位）` - professional master's, not the target.

They share similar initial/retake exam subjects in the 2026 catalog, so future analysis must always filter by专业代码.

## 2026 数据不能直接当 2027 最终要求

2026 admissions requirements are useful for planning, but 27 考研 must refresh against 2027 official documents once published.

## 官网附件需要本地抽取

The professional catalog and exam scope are hosted as binary XLSX/PDF attachments. Cite the official hosting article, but extract rows locally for precise target information.

## Bundled Python may lack requests

On 2026-06-15, bundled Python did not have `requests`. Use `urllib` for small official-page scraping or use web/browser tools.

## CSV can drop leading zero in major codes

When reading generated CSVs back with pandas, `080800` may be inferred as integer `80800`. Always coerce major codes with `astype(str).str.zfill(6)` before filtering or grouping.

## Bundled Python may lack matplotlib

On 2026-06-16, bundled Python did not have `matplotlib`. For lightweight admissions charts, generate SVG directly or use another available plotting path instead of stopping for dependency installation.
