import re
import sys
import zipfile
import xml.etree.ElementTree as ET

NS = {
    "a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
}


def col_to_num(col):
    n = 0
    for ch in col:
        n = n * 26 + ord(ch) - 64
    return n


def cell_sort_key(ref):
    m = re.match(r"([A-Z]+)(\d+)", ref)
    return int(m.group(2)), col_to_num(m.group(1))


def load_shared_strings(zf):
    try:
        root = ET.fromstring(zf.read("xl/sharedStrings.xml"))
    except KeyError:
        return []
    strings = []
    for si in root.findall("a:si", NS):
        text = "".join(t.text or "" for t in si.findall(".//a:t", NS))
        strings.append(text)
    return strings


def cell_value(cell, shared_strings):
    cell_type = cell.attrib.get("t")
    v = cell.find("a:v", NS)
    if cell_type == "s" and v is not None:
        return shared_strings[int(v.text)]
    if cell_type == "inlineStr":
        return "".join(t.text or "" for t in cell.findall(".//a:t", NS))
    return v.text if v is not None else ""


def workbook_sheets(zf):
    wb = ET.fromstring(zf.read("xl/workbook.xml"))
    rels = ET.fromstring(zf.read("xl/_rels/workbook.xml.rels"))
    rel_map = {rel.attrib["Id"]: rel.attrib["Target"] for rel in rels}
    result = []
    for sheet in wb.find("a:sheets", NS):
        rid = sheet.attrib[f"{{{NS['r']}}}id"]
        result.append((sheet.attrib["name"], "xl/" + rel_map[rid]))
    return result


def inspect(path, max_row=80, max_col=30):
    with zipfile.ZipFile(path) as zf:
        shared_strings = load_shared_strings(zf)
        print(f"\nFILE: {path}")
        for name, target in workbook_sheets(zf):
            root = ET.fromstring(zf.read(target))
            print(f"\nSHEET: {name} ({target})")
            dim = root.find("a:dimension", NS)
            if dim is not None:
                print(f"DIMENSION: {dim.attrib.get('ref')}")
            merges = root.find("a:mergeCells", NS)
            if merges is not None:
                refs = [m.attrib["ref"] for m in merges.findall("a:mergeCell", NS)]
                print("MERGES:", ", ".join(refs[:30]))
            cells = []
            for row in root.findall(".//a:row", NS):
                r = int(row.attrib.get("r", "0"))
                if r > max_row:
                    continue
                for cell in row.findall("a:c", NS):
                    ref = cell.attrib.get("r", "")
                    m = re.match(r"([A-Z]+)(\d+)", ref)
                    if not m or col_to_num(m.group(1)) > max_col:
                        continue
                    value = cell_value(cell, shared_strings)
                    if value != "":
                        cells.append((ref, value.replace("\n", "\\n")))
            for ref, value in sorted(cells, key=lambda x: cell_sort_key(x[0])):
                print(f"{ref}: {value}")


if __name__ == "__main__":
    for workbook in sys.argv[1:]:
        inspect(workbook)
