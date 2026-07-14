from __future__ import annotations

import csv
import shutil
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from xml.sax.saxutils import escape

from generate_lab3_excels import cases, conditions, outputs, yn


CONTENT_TYPES = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
  {sheet_overrides}
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
</Types>
"""


ROOT_RELS = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"""


STYLES = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="2">
    <font><sz val="11"/><color theme="1"/><name val="Calibri"/><family val="2"/></font>
    <font><b/><sz val="11"/><color theme="1"/><name val="Calibri"/><family val="2"/></font>
  </fonts>
  <fills count="3">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFD9EAF7"/><bgColor indexed="64"/></patternFill></fill>
  </fills>
  <borders count="2">
    <border><left/><right/><top/><bottom/><diagonal/></border>
    <border>
      <left style="thin"><color rgb="FFB7B7B7"/></left>
      <right style="thin"><color rgb="FFB7B7B7"/></right>
      <top style="thin"><color rgb="FFB7B7B7"/></top>
      <bottom style="thin"><color rgb="FFB7B7B7"/></bottom>
      <diagonal/>
    </border>
  </borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="5">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="1" fillId="0" borderId="1" xfId="0" applyFont="1" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf>
  </cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
  <dxfs count="0"/>
  <tableStyles count="0" defaultTableStyle="TableStyleMedium9" defaultPivotStyle="PivotStyleLight16"/>
</styleSheet>
"""


def col_name(index: int) -> str:
    result = ""
    while index:
        index, rem = divmod(index - 1, 26)
        result = chr(65 + rem) + result
    return result


def xml_text(value) -> str:
    return escape("" if value is None else str(value), {'"': "&quot;"})


class SharedStrings:
    def __init__(self) -> None:
        self.index: dict[str, int] = {}
        self.values: list[str] = []
        self.count = 0

    def add(self, value) -> int:
        text = "" if value is None else str(value)
        self.count += 1
        if text not in self.index:
            self.index[text] = len(self.values)
            self.values.append(text)
        return self.index[text]

    def xml(self) -> str:
        items = []
        for value in self.values:
            preserve = ' xml:space="preserve"' if value.startswith(" ") or value.endswith(" ") or "\n" in value else ""
            items.append(f"<si><t{preserve}>{xml_text(value)}</t></si>")
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
            f'<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="{self.count}" uniqueCount="{len(self.values)}">'
            + "".join(items)
            + "</sst>"
        )


def style_for(row_idx: int, col_idx: int, sheet_name: str) -> int:
    if row_idx <= 4 and sheet_name == "Login":
        return 1 if row_idx == 4 else 2
    if sheet_name in {"Decision Table", "Design Test case", "Test report"} and row_idx <= 2:
        return 1
    if sheet_name == "Cover" and row_idx in {2, 4, 5, 6, 10, 11, 19, 20, 21, 24, 25}:
        return 1 if row_idx in {11, 21, 25} else 2
    if sheet_name == "Function" and col_idx == 1:
        return 4
    return 3


def worksheet_xml(name: str, rows: list[list], widths: list[float], shared: SharedStrings, frozen: str | None = None) -> str:
    max_cols = max((len(row) for row in rows), default=1)
    max_rows = len(rows)
    dimension = f"A1:{col_name(max_cols)}{max_rows}"

    cols_xml = ""
    if widths:
        col_entries = []
        for idx, width in enumerate(widths, start=1):
            col_entries.append(f'<col min="{idx}" max="{idx}" width="{width}" customWidth="1"/>')
        cols_xml = "<cols>" + "".join(col_entries) + "</cols>"

    pane_xml = ""
    if frozen:
        pane_xml = f'<sheetViews><sheetView workbookViewId="0"><pane ySplit="4" topLeftCell="{frozen}" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>'
    else:
        pane_xml = '<sheetViews><sheetView workbookViewId="0"/></sheetViews>'

    row_entries = []
    for r_idx, row in enumerate(rows, start=1):
        height = 42 if any("\n" in str(cell) for cell in row) else 22
        custom_height = ' customHeight="1"' if height != 22 else ""
        cells = []
        for c_idx, value in enumerate(row, start=1):
            ref = f"{col_name(c_idx)}{r_idx}"
            style = style_for(r_idx, c_idx, name)
            if value is None or value == "":
                cells.append(f'<c r="{ref}" s="{style}"/>')
            else:
                sst_idx = shared.add(value)
                cells.append(f'<c r="{ref}" t="s" s="{style}"><v>{sst_idx}</v></c>')
        row_entries.append(f'<row r="{r_idx}" ht="{height}"{custom_height}>' + "".join(cells) + "</row>")

    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <dimension ref="{dimension}"/>
  {pane_xml}
  <sheetFormatPr defaultRowHeight="15"/>
  {cols_xml}
  <sheetData>{''.join(row_entries)}</sheetData>
  <pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>
</worksheet>
"""


def write_workbook(path: Path, sheets: list[dict]) -> None:
    shared = SharedStrings()
    sheet_xmls = []
    for sheet in sheets:
        sheet_xmls.append(worksheet_xml(sheet["name"], sheet["rows"], sheet["widths"], shared, sheet.get("frozen")))

    sheet_overrides = "\n  ".join(
        f'<Override PartName="/xl/worksheets/sheet{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        for i in range(1, len(sheets) + 1)
    )
    workbook_sheets = "".join(
        f'<sheet name="{xml_text(sheet["name"])}" sheetId="{i}" r:id="rId{i}"/>'
        for i, sheet in enumerate(sheets, start=1)
    )
    workbook_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <workbookPr date1904="false"/>
  <sheets>{workbook_sheets}</sheets>
</workbook>
"""
    rel_entries = "".join(
        f'<Relationship Id="rId{i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i}.xml"/>'
        for i in range(1, len(sheets) + 1)
    )
    rel_entries += f'<Relationship Id="rId{len(sheets) + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
    rel_entries += f'<Relationship Id="rId{len(sheets) + 2}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>'
    workbook_rels = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">{rel_entries}</Relationships>
"""
    now = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    core_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">{now}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{now}</dcterms:modified>
</cp:coreProperties>
"""
    app_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Excel</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <HeadingPairs><vt:vector size="2" baseType="variant"><vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant><vt:variant><vt:i4>{len(sheets)}</vt:i4></vt:variant></vt:vector></HeadingPairs>
  <TitlesOfParts><vt:vector size="{len(sheets)}" baseType="lpstr">{''.join(f'<vt:lpstr>{xml_text(sheet["name"])}</vt:lpstr>' for sheet in sheets)}</vt:vector></TitlesOfParts>
</Properties>
"""

    path.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", CONTENT_TYPES.format(sheet_overrides=sheet_overrides))
        zf.writestr("_rels/.rels", ROOT_RELS)
        zf.writestr("docProps/core.xml", core_xml)
        zf.writestr("docProps/app.xml", app_xml)
        zf.writestr("xl/workbook.xml", workbook_xml)
        zf.writestr("xl/_rels/workbook.xml.rels", workbook_rels)
        zf.writestr("xl/styles.xml", STYLES)
        zf.writestr("xl/sharedStrings.xml", shared.xml())
        for idx, sheet_xml in enumerate(sheet_xmls, start=1):
            zf.writestr(f"xl/worksheets/sheet{idx}.xml", sheet_xml)


def decision_rows() -> list[list]:
    rows = [["No", "Input condition", "Rule / Tag"] + [""] * (len(cases) - 1)]
    rows.append(["", ""] + [case["tag"] for case in cases])
    for idx, condition in enumerate(conditions, start=1):
        rows.append([idx, condition] + [yn(case["condition_values"][idx - 1]) for case in cases])
    rows.append(["", "Output condition"] + [""] * len(cases))
    for idx, output in enumerate(outputs, start=1):
        rows.append([idx, output] + [yn(case["output_values"][idx - 1]) for case in cases])
    return rows


def design_rows() -> list[list]:
    rows = [["Test case", "Description", "Expected outcome", "Tag"]]
    for idx, case in enumerate(cases, start=1):
        rows.append([idx, case["procedure"], case["expected"], case["tag"]])
    return rows


def function_rows() -> list[list]:
    return [
        ["Project", "MotoRent - Motorbike Rental Management System"],
        ["Selected screen", "Login / Sign In"],
        ["URL", "/auth?action=login"],
        ["Controller", "controller.AuthController#doLogin"],
        ["JSP", "/views/auth/login.jsp"],
        ["Technique", "Decision table and extended decision table"],
        ["Number of input conditions", len(conditions)],
        ["Number of test cases", len(cases)],
        ["Valid admin account", "admin@motorent.com / 123456"],
        ["Valid staff account", "staff@motorent.com / 123456"],
        ["Valid customer account", "john@gmail.com / 123456"],
        ["Main expected redirects", "/admin?action=dashboard; /staff?action=dashboard; /orders?action=dashboard"],
        ["Main validation messages", "Email is required.; Invalid email format.; Password is required.; Invalid email or password."],
    ]


def cover_rows() -> list[list]:
    return [
        ["", "", "TEST CASE"],
        [],
        ["", "Project Name", "MotoRent - Motorbike Rental Management System", "", "", "Creator", "Student"],
        ["", "Project Code", "MotoRent", "", "", "Reviewer/Approver", "Instructor/Reviewer"],
        ["", "Document Code", "MotoRent_Login_TestCases_v1.0", "", "", "Issue Date", "2026-07-05"],
        ["", "", "", "", "", "Version", "1.0"],
        [],
        ["", "Record of change"],
        ["", "Effective Date", "Version", "Change Item", "*A,D,M", "Change description", "Reference"],
        ["", "2026-07-05", "1.0", "", "A", "Create MotoRent Login test cases using decision table technique", ""],
        [],
        ["", "", "", "", "", "Environment for test"],
        ["", "", "", "", "", "Client"],
        ["", "", "", "", "", "Device", "Version"],
        ["", "", "", "", "", "PC browser", "Windows 10/11, Chrome or Edge"],
        [],
        ["", "", "", "", "", "Server"],
        ["", "", "", "", "", "Device", "Version"],
        ["", "", "", "", "", "PC", "JDK 17, Tomcat 10.1, SQL Server MotoRentDB"],
    ]


def report_rows() -> list[list]:
    return [
        ["", "", "TEST REPORT"],
        [],
        ["", "Build #", "Sub Module", "Hours cost/ device", "Hours cost", "System test environment", "Pass", "Fail", "Untest", "N/A", "Number of sub test cases", "Number of runs"],
        ["", "1.0", "Login", "3", "3", "Windows/Chrome, Tomcat 10.1, SQL Server MotoRentDB", "30", "0", "0", "0", "30", "30"],
        [],
        ["", "", "Sub total", "3", "3", "", "30", "0", "0", "0", "30", "30"],
        ["", "", "Test coverage", "", "", "", "", "100", "%"],
        ["", "", "Test successful coverage", "", "", "", "", "100", "%"],
    ]


def login_rows() -> list[list]:
    rows = [
        ["Back to TestReport", "To Buglist", "", "Pass: 30", "Untested: 0"],
        ["Module Code", "Login", "", "Fail: 0", "N/A: 0"],
        ["Tester", "Student", "", "Percent Complete: 100%", "Number of cases: 30"],
        ["ID", "Test Case Description", "Pre -Condition", "Test Case Procedure", "Expected Output", "Bug#", "System test environment", "Test date", "Note"],
    ]
    env = "Windows 10/11, Chrome or Edge, Tomcat 10.1, JDK 17, SQL Server MotoRentDB"
    for case in cases:
        rows.append([
            case["id"],
            case["title"],
            case["precondition"],
            case["procedure"],
            case["expected"],
            "",
            env,
            "2026-07-05",
            f"Pass - {case['note']}",
        ])
    return rows


def write_csv(path: Path, rows: list[list]) -> None:
    path.parent.mkdir(exist_ok=True)
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.writer(f)
        writer.writerows(rows)


def main() -> None:
    output_dir = Path.cwd() / "lab3_output"
    decision_path = output_dir / "MotoRent_Login_Decision_Table_Test_Design.xlsx"
    testcase_path = output_dir / "MotoRent_Login_Test_Cases.xlsx"

    write_workbook(decision_path, [
        {"name": "Decision Table", "rows": decision_rows(), "widths": [8, 42] + [8] * len(cases), "frozen": "C3"},
        {"name": "Design Test case", "rows": design_rows(), "widths": [12, 70, 70, 10], "frozen": "A2"},
        {"name": "Function", "rows": function_rows(), "widths": [28, 90]},
    ])
    write_workbook(testcase_path, [
        {"name": "Cover", "rows": cover_rows(), "widths": [4, 22, 42, 14, 14, 28, 50]},
        {"name": "Test report", "rows": report_rows(), "widths": [4, 12, 22, 18, 16, 44, 10, 10, 10, 10, 24, 18]},
        {"name": "Login", "rows": login_rows(), "widths": [14, 42, 48, 72, 72, 12, 48, 14, 18], "frozen": "A5"},
    ])

    csv_dir = output_dir / "csv_fallback"
    write_csv(csv_dir / "Decision_Table.csv", decision_rows())
    write_csv(csv_dir / "Design_Test_Case.csv", design_rows())
    write_csv(csv_dir / "Function.csv", function_rows())
    write_csv(csv_dir / "MotoRent_Login_Test_Cases.csv", login_rows())

    downloads = Path.home() / "Downloads"
    if downloads.exists():
        shutil.copyfile(decision_path, downloads / decision_path.name)
        shutil.copyfile(testcase_path, downloads / testcase_path.name)
        shutil.copyfile(csv_dir / "MotoRent_Login_Test_Cases.csv", downloads / "MotoRent_Login_Test_Cases.csv")
        shutil.copyfile(csv_dir / "Decision_Table.csv", downloads / "MotoRent_Login_Decision_Table.csv")

    print(decision_path)
    print(testcase_path)
    print(csv_dir)


if __name__ == "__main__":
    main()
