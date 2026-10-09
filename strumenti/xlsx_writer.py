import io
import zipfile
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape


def _xml_header():
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'


def _inline_cell(value):
    if value is None:
        return '<c t="inlineStr"><is><t></t></is></c>'
    text = escape(str(value))
    return f'<c t="inlineStr"><is><t>{text}</t></is></c>'


def _num_cell(value):
    if value is None:
        return '<c><v>0</v></c>'
    try:
        v = float(value)
    except (TypeError, ValueError):
        return _inline_cell(value)
    return f'<c><v>{v}</v></c>'


def _bool_cell(value):
    v = "1" if value else "0"
    return f'<c t="bool"><v>{v}</v></c>'


def _make_worksheet(rows):
    parts = [_xml_header()]
    parts.append('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">')
    parts.append('<sheetData>')
    for r_idx, row in enumerate(rows, 1):
        parts.append(f'<row r="{r_idx}">')
        for c_idx, cell in enumerate(row, 1):
            col = _col_letter(c_idx)
            value, kind = cell
            if kind == "num":
                parts.append(f'<c r="{col}{r_idx}"><v>{value}</v></c>')
            elif kind == "bool":
                parts.append(f'<c r="{col}{r_idx}" t="bool"><v>{"1" if value else "0"}</v></c>')
            else:
                text = escape(str(value))
                parts.append(f'<c r="{col}{r_idx}" t="inlineStr"><is><t>{text}</t></is></c>')
        parts.append('</row>')
    parts.append('</sheetData>')
    parts.append('</worksheet>')
    return ''.join(parts)


def _col_letter(n):
    s = ''
    while n > 0:
        n, r = divmod(n - 1, 26)
        s = chr(65 + r) + s
    return s


def _content_types(sheet_count):
    parts = [_xml_header()]
    parts.append('<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">')
    parts.append('<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>')
    parts.append('<Default Extension="xml" ContentType="application/xml"/>')
    parts.append('<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>')
    parts.append('<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>')
    for i in range(1, sheet_count + 1):
        parts.append(f'<Override PartName="/xl/worksheets/sheet{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>')
    parts.append('</Types>')
    return ''.join(parts)


def _rels():
    return (_xml_header() +
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
            '</Relationships>')


def _workbook_rels(sheet_count):
    parts = [_xml_header()]
    parts.append('<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">')
    for i in range(1, sheet_count + 1):
        parts.append(f'<Relationship Id="rId{i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i}.xml"/>')
    parts.append(f'<Relationship Id="rId{sheet_count + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>')
    parts.append('</Relationships>')
    return ''.join(parts)


def _workbook(sheet_names):
    parts = [_xml_header()]
    parts.append('<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">')
    parts.append('<sheets>')
    for i, name in enumerate(sheet_names, 1):
        safe = escape(str(name))
        parts.append(f'<sheet name="{safe}" sheetId="{i}" r:id="rId{i}"/>')
    parts.append('</sheets>')
    parts.append('</workbook>')
    return ''.join(parts)


def _styles():
    return (_xml_header() +
            '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
            '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
            '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
            '<fills count="1"><fill><patternFill patternType="none"/></fill></fills>'
            '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
            '<cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>'
            '<xf numFmtId="0" fontId="1" fillId="0" borderId="0"/></cellXfs>'
            '</styleSheet>')


class Sheet:
    def __init__(self, name):
        self.name = name
        self.rows = []

    def add_row(self, values):
        # values: list of tuples (value, kind) or just plain values (treated as string)
        row = []
        for v in values:
            if isinstance(v, tuple) and len(v) == 2:
                row.append(v)
            elif isinstance(v, bool):
                row.append((v, 'bool'))
            elif isinstance(v, (int, float)):
                row.append((v, 'num'))
            else:
                row.append((v, 'str'))
        self.rows.append(row)


class Workbook:
    def __init__(self):
        self.sheets = []

    def add_sheet(self, sheet: Sheet):
        self.sheets.append(sheet)

    def save(self, path: str):
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as zf:
            zf.writestr('_rels/.rels', _rels())
            zf.writestr('[Content_Types].xml', _content_types(len(self.sheets)))
            zf.writestr('xl/workbook.xml', _workbook([s.name for s in self.sheets]))
            zf.writestr('xl/_rels/workbook.xml.rels', _workbook_rels(len(self.sheets)))
            zf.writestr('xl/styles.xml', _styles())
            for i, sheet in enumerate(self.sheets, 1):
                xml = _make_worksheet(sheet.rows)
                zf.writestr(f'xl/worksheets/sheet{i}.xml', xml)
        with open(path, 'wb') as f:
            f.write(buf.getvalue())
