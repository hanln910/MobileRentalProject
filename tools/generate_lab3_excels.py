from __future__ import annotations

import copy
import os
import re
import shutil
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

NS_MAIN = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
NS_REL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
NS_XML = "http://www.w3.org/XML/1998/namespace"

NS = {
    "a": NS_MAIN,
    "r": NS_REL,
}

ET.register_namespace("", NS_MAIN)
ET.register_namespace("r", NS_REL)


def q(name: str) -> str:
    return f"{{{NS_MAIN}}}{name}"


def col_to_num(col: str) -> int:
    result = 0
    for ch in col:
        result = result * 26 + ord(ch.upper()) - 64
    return result


def num_to_col(num: int) -> str:
    result = ""
    while num:
        num, rem = divmod(num - 1, 26)
        result = chr(65 + rem) + result
    return result


def split_ref(ref: str) -> tuple[str, int]:
    match = re.match(r"([A-Z]+)(\d+)$", ref)
    if not match:
        raise ValueError(f"Invalid cell reference: {ref}")
    return match.group(1), int(match.group(2))


def cell_sort_key(cell: ET.Element) -> tuple[int, int]:
    col, row = split_ref(cell.attrib["r"])
    return row, col_to_num(col)


def get_sheet_targets(xlsx_path: Path) -> dict[str, str]:
    with zipfile.ZipFile(xlsx_path) as zf:
        workbook = ET.fromstring(zf.read("xl/workbook.xml"))
        rels = ET.fromstring(zf.read("xl/_rels/workbook.xml.rels"))
    rel_map = {rel.attrib["Id"]: rel.attrib["Target"] for rel in rels}
    sheets = {}
    for sheet in workbook.find(q("sheets")):
        rel_id = sheet.attrib[f"{{{NS_REL}}}id"]
        sheets[sheet.attrib["name"]] = "xl/" + rel_map[rel_id]
    return sheets


def read_xml_from_xlsx(xlsx_path: Path, member: str) -> ET.ElementTree:
    with zipfile.ZipFile(xlsx_path) as zf:
        return ET.ElementTree(ET.fromstring(zf.read(member)))


def write_members_to_xlsx(xlsx_path: Path, replacements: dict[str, bytes]) -> None:
    temp_path = xlsx_path.with_suffix(".tmp.xlsx")
    with zipfile.ZipFile(xlsx_path, "r") as zin:
        with zipfile.ZipFile(temp_path, "w", zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = replacements.get(item.filename)
                if data is None:
                    data = zin.read(item.filename)
                zout.writestr(item, data)
    temp_path.replace(xlsx_path)


def worksheet_root(tree: ET.ElementTree) -> ET.Element:
    return tree.getroot()


def sheet_data(root: ET.Element) -> ET.Element:
    found = root.find(q("sheetData"))
    if found is None:
        found = ET.SubElement(root, q("sheetData"))
    return found


def find_row(root: ET.Element, row_index: int, create: bool = True) -> ET.Element | None:
    data = sheet_data(root)
    for row in data.findall(q("row")):
        if int(row.attrib.get("r", "0")) == row_index:
            return row
    if not create:
        return None
    row = ET.Element(q("row"), {"r": str(row_index)})
    rows = data.findall(q("row"))
    inserted = False
    for idx, existing in enumerate(rows):
        if int(existing.attrib.get("r", "0")) > row_index:
            data.insert(idx, row)
            inserted = True
            break
    if not inserted:
        data.append(row)
    return row


def find_cell(root: ET.Element, ref: str, create: bool = True, style_from: str | None = None) -> ET.Element | None:
    col, row_index = split_ref(ref)
    row = find_row(root, row_index, create=create)
    if row is None:
        return None
    for cell in row.findall(q("c")):
        if cell.attrib.get("r") == ref:
            return cell
    if not create:
        return None
    attrs = {"r": ref}
    if style_from:
        style_cell = find_cell(root, style_from, create=False)
        if style_cell is not None and "s" in style_cell.attrib:
            attrs["s"] = style_cell.attrib["s"]
    cell = ET.Element(q("c"), attrs)
    cells = row.findall(q("c"))
    target_col = col_to_num(col)
    inserted = False
    for idx, existing in enumerate(cells):
        existing_col, _ = split_ref(existing.attrib["r"])
        if col_to_num(existing_col) > target_col:
            row.insert(idx, cell)
            inserted = True
            break
    if not inserted:
        row.append(cell)
    return cell


def clear_cell(cell: ET.Element) -> None:
    for child in list(cell):
        cell.remove(child)
    cell.attrib.pop("t", None)


def set_cell(root: ET.Element, ref: str, value, style_from: str | None = None) -> None:
    cell = find_cell(root, ref, create=True, style_from=style_from)
    assert cell is not None
    clear_cell(cell)
    if value is None:
        return
    text = str(value)
    cell.set("t", "inlineStr")
    is_el = ET.SubElement(cell, q("is"))
    t_el = ET.SubElement(is_el, q("t"))
    if text.startswith(" ") or text.endswith(" ") or "\n" in text:
        t_el.set(f"{{{NS_XML}}}space", "preserve")
    t_el.text = text


def clear_range(root: ET.Element, start_ref: str, end_ref: str) -> None:
    start_col, start_row = split_ref(start_ref)
    end_col, end_row = split_ref(end_ref)
    for row_index in range(start_row, end_row + 1):
        row = find_row(root, row_index, create=False)
        if row is None:
            continue
        for cell in list(row.findall(q("c"))):
            col, _ = split_ref(cell.attrib["r"])
            if col_to_num(start_col) <= col_to_num(col) <= col_to_num(end_col):
                row.remove(cell)


def set_dimension(root: ET.Element, ref: str) -> None:
    dimension = root.find(q("dimension"))
    if dimension is None:
        dimension = ET.Element(q("dimension"), {"ref": ref})
        root.insert(0, dimension)
    dimension.set("ref", ref)


def replace_merge(root: ET.Element, old_ref: str, new_ref: str) -> None:
    merge_cells = root.find(q("mergeCells"))
    if merge_cells is None:
        return
    for merge in merge_cells.findall(q("mergeCell")):
        if merge.attrib.get("ref") == old_ref:
            merge.set("ref", new_ref)
            return


def remove_merges(root: ET.Element, refs: set[str]) -> None:
    merge_cells = root.find(q("mergeCells"))
    if merge_cells is None:
        return
    for merge in list(merge_cells.findall(q("mergeCell"))):
        if merge.attrib.get("ref") in refs:
            merge_cells.remove(merge)
    merge_cells.set("count", str(len(merge_cells.findall(q("mergeCell")))))


def tree_bytes(tree: ET.ElementTree) -> bytes:
    return ET.tostring(tree.getroot(), encoding="utf-8", xml_declaration=True)


def update_workbook_sheet_name(xlsx_path: Path, old_name: str, new_name: str) -> bytes:
    tree = read_xml_from_xlsx(xlsx_path, "xl/workbook.xml")
    root = tree.getroot()
    for sheet in root.find(q("sheets")):
        if sheet.attrib.get("name") == old_name:
            sheet.set("name", new_name)
    return tree_bytes(tree)


def yn(value: bool | None) -> str:
    if value is True:
        return "T"
    if value is False:
        return "F"
    return "-"


conditions = [
    "Form được submit với action=login",
    "Email được nhập (không rỗng sau trim)",
    "Email đúng định dạng sau trim",
    "Email có khoảng trắng đầu/cuối cần trim",
    "Password được nhập (không rỗng sau trim)",
    "Password khớp chính xác với DB",
    "Tài khoản đang active",
    "Tài khoản có role Admin",
    "Tài khoản có role Staff",
    "Session có redirectUrl trước đăng nhập",
]

outputs = [
    'Hiển thị lỗi "Email is required."',
    'Hiển thị lỗi "Invalid email format."',
    'Hiển thị lỗi "Password is required."',
    'Hiển thị lỗi "Invalid email or password."',
    'Hiển thị lỗi "Your account has been locked. Please contact admin."',
    "Tạo session user và timeout 30 phút",
    "Redirect tới /admin?action=dashboard",
    "Redirect tới /staff?action=dashboard",
    "Redirect tới /orders?action=dashboard",
    "Redirect tới URL được lưu trong session.redirectUrl",
    "Hiển thị lại Login form và giữ email đã nhập",
    "Password không được hiển thị lại sau lỗi",
    "Remember me không làm thay đổi kết quả phía server",
]


def make_case(
    idx: int,
    title: str,
    email: str,
    password: str,
    expected: str,
    cond: list[bool | None],
    out: list[bool],
    precondition: str = "MotoRentDB đã được import; Tomcat 10.1 đang chạy; người dùng chưa đăng nhập.",
    extra_steps: list[str] | None = None,
    note: str = "Alternative flow",
) -> dict:
    steps = [
        "Mở http://localhost:8080/MobileRentalProject/auth?action=login",
        f'Nhập Email: "{email}"',
        f'Nhập Password: "{password}"',
    ]
    if extra_steps:
        steps.extend(extra_steps)
    steps.append("Click nút Log In")
    return {
        "tag": f"L{idx:02d}",
        "id": f"[Login-{idx}]",
        "title": title,
        "email": email,
        "password": password,
        "precondition": precondition,
        "procedure": "\n".join(f"{i + 1}. {step}" for i, step in enumerate(steps)),
        "expected": expected,
        "condition_values": cond,
        "output_values": out,
        "note": note,
    }


def out_values(*true_indexes: int) -> list[bool]:
    values = [False] * len(outputs)
    for index in true_indexes:
        values[index - 1] = True
    return values


cases = [
    make_case(
        1,
        "Đăng nhập thành công với tài khoản Admin",
        "admin@motorent.com",
        "123456",
        "Hệ thống tạo session user và chuyển tới /admin?action=dashboard.",
        [True, True, True, False, True, True, True, True, False, False],
        out_values(6, 7),
        note="Basic flow",
    ),
    make_case(
        2,
        "Đăng nhập thành công với tài khoản Staff",
        "staff@motorent.com",
        "123456",
        "Hệ thống tạo session user và chuyển tới /staff?action=dashboard.",
        [True, True, True, False, True, True, True, False, True, False],
        out_values(6, 8),
        note="Basic flow",
    ),
    make_case(
        3,
        "Đăng nhập thành công với tài khoản Customer",
        "john@gmail.com",
        "123456",
        "Hệ thống tạo session user và chuyển tới /orders?action=dashboard.",
        [True, True, True, False, True, True, True, False, False, False],
        out_values(6, 9),
        note="Basic flow",
    ),
    make_case(
        4,
        "Email hợp lệ có khoảng trắng đầu/cuối vẫn đăng nhập được",
        "  john@gmail.com  ",
        "123456",
        "Email được trim; hệ thống đăng nhập thành công và chuyển tới /orders?action=dashboard.",
        [True, True, True, True, True, True, True, False, False, False],
        out_values(6, 9),
    ),
    make_case(
        5,
        "Admin đăng nhập thành công và có redirectUrl trong session",
        "  admin@motorent.com ",
        "123456",
        "Email được trim; hệ thống đăng nhập thành công và chuyển tới URL đã lưu trong session.redirectUrl.",
        [True, True, True, True, True, True, True, True, False, True],
        out_values(6, 10),
        precondition="Session đã có redirectUrl=/admin?action=manage-users.",
    ),
    make_case(
        6,
        "Customer đăng nhập thành công và quay lại trang được yêu cầu trước đó",
        "john@gmail.com",
        "123456",
        "Hệ thống đăng nhập thành công và chuyển tới URL đã lưu trong session.redirectUrl.",
        [True, True, True, False, True, True, True, False, False, True],
        out_values(6, 10),
        precondition="Session đã có redirectUrl=/orders?action=dashboard.",
    ),
    make_case(
        7,
        "Không nhập email",
        "",
        "123456",
        'Hệ thống không submit thành công; hiển thị lỗi "Email is required."; form login vẫn hiển thị.',
        [True, False, None, False, True, None, None, None, None, False],
        out_values(1, 11, 12),
        note="Exception flow",
    ),
    make_case(
        8,
        "Email chỉ gồm khoảng trắng",
        "   ",
        "123456",
        'Email sau trim là rỗng; hiển thị lỗi "Email is required."; form login vẫn hiển thị.',
        [True, False, None, True, True, None, None, None, None, False],
        out_values(1, 11, 12),
        note="Exception flow",
    ),
    make_case(
        9,
        "Email thiếu ký tự @",
        "admin.motorent.com",
        "123456",
        'Hiển thị lỗi "Invalid email format."; không gọi đăng nhập DB.',
        [True, True, False, False, True, None, None, None, None, False],
        out_values(2, 11, 12),
        note="Exception flow",
    ),
    make_case(
        10,
        "Email thiếu phần domain suffix",
        "admin@motorent",
        "123456",
        'Hiển thị lỗi "Invalid email format."; không gọi đăng nhập DB.',
        [True, True, False, False, True, None, None, None, None, False],
        out_values(2, 11, 12),
        note="Exception flow",
    ),
    make_case(
        11,
        "Email có ký tự plus không được regex hiện tại chấp nhận",
        "john+test@gmail.com",
        "123456",
        'Hiển thị lỗi "Invalid email format."; form login giữ lại email đã nhập.',
        [True, True, False, False, True, None, None, None, None, False],
        out_values(2, 11, 12),
        note="Exception flow",
    ),
    make_case(
        12,
        "Không nhập password",
        "admin@motorent.com",
        "",
        'Hiển thị lỗi "Password is required."; không đăng nhập.',
        [True, True, True, False, False, None, None, None, None, False],
        out_values(3, 11, 12),
        note="Exception flow",
    ),
    make_case(
        13,
        "Password chỉ gồm khoảng trắng",
        "admin@motorent.com",
        "   ",
        'Password sau trim là rỗng; hiển thị lỗi "Password is required."; không đăng nhập.',
        [True, True, True, False, False, None, None, None, None, False],
        out_values(3, 11, 12),
        note="Exception flow",
    ),
    make_case(
        14,
        "Không nhập email và password",
        "",
        "",
        'Hiển thị đồng thời lỗi "Email is required." và "Password is required.".',
        [True, False, None, False, False, None, None, None, None, False],
        out_values(1, 3, 11, 12),
        note="Exception flow",
    ),
    make_case(
        15,
        "Email sai định dạng và password rỗng",
        "admin.motorent.com",
        "",
        'Hiển thị lỗi "Invalid email format." và "Password is required.".',
        [True, True, False, False, False, None, None, None, None, False],
        out_values(2, 3, 11, 12),
        note="Exception flow",
    ),
    make_case(
        16,
        "Admin nhập sai password",
        "admin@motorent.com",
        "wrongpass",
        'Hiển thị lỗi "Invalid email or password."; không tạo session.',
        [True, True, True, False, True, False, None, None, None, False],
        out_values(4, 11, 12),
        note="Exception flow",
    ),
    make_case(
        17,
        "Customer nhập password sai chữ hoa/thường",
        "john@gmail.com",
        "123456A",
        'Hiển thị lỗi "Invalid email or password."; không tạo session.',
        [True, True, True, False, True, False, None, None, None, False],
        out_values(4, 11, 12),
        note="Exception flow",
    ),
    make_case(
        18,
        "Password đúng nhưng có khoảng trắng đầu chuỗi",
        "john@gmail.com",
        " 123456",
        'Password không được trim khi so sánh DB; hiển thị lỗi "Invalid email or password.".',
        [True, True, True, False, True, False, None, None, None, False],
        out_values(4, 11, 12),
        note="Exception flow",
    ),
    make_case(
        19,
        "Password đúng nhưng có khoảng trắng cuối chuỗi",
        "john@gmail.com",
        "123456 ",
        'Password không khớp chính xác; hiển thị lỗi "Invalid email or password.".',
        [True, True, True, False, True, False, None, None, None, False],
        out_values(4, 11, 12),
        note="Exception flow",
    ),
    make_case(
        20,
        "Email hợp lệ nhưng không tồn tại trong DB",
        "notfound@motorent.com",
        "123456",
        'Hiển thị lỗi "Invalid email or password."; không tiết lộ email có tồn tại hay không.',
        [True, True, True, False, True, False, False, None, None, False],
        out_values(4, 11, 12),
        note="Exception flow",
    ),
    make_case(
        21,
        "Tài khoản bị khóa đăng nhập",
        "locked@motorent.com",
        "123456",
        'Hiển thị lỗi "Your account has been locked. Please contact admin."; không tạo session.',
        [True, True, True, False, True, True, False, None, None, False],
        out_values(5, 11, 12),
        precondition="DB có user locked@motorent.com/password 123456 với isActive=0.",
        note="Exception flow",
    ),
    make_case(
        22,
        "Customer đăng nhập với checkbox Remember me được chọn",
        "john@gmail.com",
        "123456",
        "Đăng nhập thành công; checkbox Remember me không tạo thay đổi server-side vì backend chưa xử lý.",
        [True, True, True, False, True, True, True, False, False, False],
        out_values(6, 9, 13),
        extra_steps=["Tick checkbox Remember me for 30 days"],
    ),
    make_case(
        23,
        "Đăng nhập thành công với customer khác",
        "sarah@gmail.com",
        "123456",
        "Hệ thống tạo session user và chuyển tới /orders?action=dashboard.",
        [True, True, True, False, True, True, True, False, False, False],
        out_values(6, 9),
        note="Basic flow",
    ),
    make_case(
        24,
        "Email đúng định dạng dạng subdomain nhưng không tồn tại",
        "john.doe@mail.example.com",
        "123456",
        'Email qua validation; hệ thống báo "Invalid email or password.".',
        [True, True, True, False, True, False, False, None, None, False],
        out_values(4, 11, 12),
    ),
    make_case(
        25,
        "Email bắt đầu bằng dấu chấm qua regex nhưng không tồn tại DB",
        ".john@gmail.com",
        "123456",
        'Email qua regex hiện tại; hệ thống báo "Invalid email or password.".',
        [True, True, True, False, True, False, False, None, None, False],
        out_values(4, 11, 12),
    ),
    make_case(
        26,
        "Email có hai dấu chấm liên tiếp qua regex nhưng không tồn tại DB",
        "john..doe@gmail.com",
        "123456",
        'Email qua regex hiện tại; hệ thống báo "Invalid email or password.".',
        [True, True, True, False, True, False, False, None, None, False],
        out_values(4, 11, 12),
    ),
    make_case(
        27,
        "Password chứa chuỗi SQL injection",
        "admin@motorent.com",
        "' OR '1'='1",
        'PreparedStatement không cho bypass; hiển thị lỗi "Invalid email or password.".',
        [True, True, True, False, True, False, None, None, None, False],
        out_values(4, 11, 12),
        note="Security flow",
    ),
    make_case(
        28,
        "Email chứa chuỗi SQL injection sai định dạng",
        "admin@motorent.com'--",
        "123456",
        'Validation chặn email sai định dạng; hiển thị lỗi "Invalid email format.".',
        [True, True, False, False, True, None, None, None, None, False],
        out_values(2, 11, 12),
        note="Security flow",
    ),
    make_case(
        29,
        "Password quá dài và không khớp",
        "staff@motorent.com",
        "123456789012345678901234567890",
        'Hiển thị lỗi "Invalid email or password."; không tạo session.',
        [True, True, True, False, True, False, None, None, None, False],
        out_values(4, 11, 12),
        note="Exception flow",
    ),
    make_case(
        30,
        "POST thiếu action nhưng controller mặc định xử lý login",
        "john@gmail.com",
        "123456",
        "Do action null được default thành login, hệ thống vẫn đăng nhập thành công và chuyển tới /orders?action=dashboard.",
        [False, True, True, False, True, True, True, False, False, False],
        out_values(6, 9),
        extra_steps=["Dùng devtools/proxy xóa hidden input action=login trước khi submit"],
        note="Alternative flow",
    ),
]


def generate_decision_workbook(template: Path, output: Path) -> None:
    shutil.copyfile(template, output)
    sheets = get_sheet_targets(output)
    replacements: dict[str, bytes] = {}

    decision_tree = read_xml_from_xlsx(output, sheets["Decision Table"])
    decision_root = worksheet_root(decision_tree)
    clear_range(decision_root, "A1", "AF60")
    set_dimension(decision_root, "A1:AF27")
    replace_merge(decision_root, "C1:S1", "C1:AF1")
    set_cell(decision_root, "A1", "No", "A1")
    set_cell(decision_root, "B1", "Input condition", "B1")
    set_cell(decision_root, "C1", "Rule / Tag", "C1")
    for index, case in enumerate(cases, start=3):
        set_cell(decision_root, f"{num_to_col(index)}2", case["tag"], "C2")
    for row_index, condition in enumerate(conditions, start=3):
        set_cell(decision_root, f"A{row_index}", row_index - 2, "A3")
        set_cell(decision_root, f"B{row_index}", condition, "B3")
        for col_index, case in enumerate(cases, start=3):
            set_cell(decision_root, f"{num_to_col(col_index)}{row_index}", yn(case["condition_values"][row_index - 3]), "C3")
    output_label_row = 14
    set_cell(decision_root, f"B{output_label_row}", "Output condition", "B19")
    for row_offset, output_condition in enumerate(outputs, start=0):
        row_index = output_label_row + 1 + row_offset
        set_cell(decision_root, f"A{row_index}", row_offset + 1, "A20")
        set_cell(decision_root, f"B{row_index}", output_condition, "B20")
        for col_index, case in enumerate(cases, start=3):
            set_cell(decision_root, f"{num_to_col(col_index)}{row_index}", yn(case["output_values"][row_offset]), "C20")
    replacements[sheets["Decision Table"]] = tree_bytes(decision_tree)

    design_tree = read_xml_from_xlsx(output, sheets["Design Test case"])
    design_root = worksheet_root(design_tree)
    clear_range(design_root, "A3", "D60")
    set_dimension(design_root, "A1:D32")
    for idx, case in enumerate(cases, start=3):
        set_cell(design_root, f"A{idx}", idx - 2, "A3")
        set_cell(design_root, f"B{idx}", case["procedure"], "B3")
        set_cell(design_root, f"C{idx}", case["expected"], "C3")
        set_cell(design_root, f"D{idx}", case["tag"], "D3")
    replacements[sheets["Design Test case"]] = tree_bytes(design_tree)

    function_tree = read_xml_from_xlsx(output, sheets["Function"])
    function_root = worksheet_root(function_tree)
    clear_range(function_root, "A1", "N40")
    set_dimension(function_root, "A1:B18")
    function_rows = [
        ("Project", "MotoRent - Motorbike Rental Management System"),
        ("Selected screen", "Login / Sign In"),
        ("URL", "/auth?action=login"),
        ("Controller", "controller.AuthController#doLogin"),
        ("JSP", "/views/auth/login.jsp"),
        ("Technique", "Decision table and extended decision table"),
        ("Number of input conditions", str(len(conditions))),
        ("Number of test cases", str(len(cases))),
        ("Valid admin account", "admin@motorent.com / 123456"),
        ("Valid staff account", "staff@motorent.com / 123456"),
        ("Valid customer account", "john@gmail.com / 123456"),
        ("Main expected redirects", "/admin?action=dashboard; /staff?action=dashboard; /orders?action=dashboard"),
        ("Main validation messages", "Email is required.; Invalid email format.; Password is required.; Invalid email or password."),
    ]
    for row_index, (key, value) in enumerate(function_rows, start=1):
        set_cell(function_root, f"A{row_index}", key)
        set_cell(function_root, f"B{row_index}", value)
    replacements[sheets["Function"]] = tree_bytes(function_tree)
    write_members_to_xlsx(output, replacements)


def generate_testcase_workbook(template: Path, output: Path) -> None:
    shutil.copyfile(template, output)
    sheets = get_sheet_targets(output)
    replacements: dict[str, bytes] = {}

    cover_tree = read_xml_from_xlsx(output, sheets["Cover"])
    cover_root = worksheet_root(cover_tree)
    clear_range(cover_root, "B13", "G17")
    clear_range(cover_root, "F20", "G32")
    set_cell(cover_root, "C4", "MotoRent - Motorbike Rental Management System", "C4")
    set_cell(cover_root, "G4", "Student", "G4")
    set_cell(cover_root, "C5", "MotoRent", "C5")
    set_cell(cover_root, "G5", "Instructor/Reviewer", "G5")
    set_cell(cover_root, "C6", "MotoRent_Login_TestCases_v1.0", "C6")
    set_cell(cover_root, "G6", "2026-07-05", "G6")
    set_cell(cover_root, "G7", "1.0", "G7")
    set_cell(cover_root, "B12", "2026-07-05", "B12")
    set_cell(cover_root, "C12", "1.0", "C12")
    set_cell(cover_root, "E12", "A", "E12")
    set_cell(cover_root, "F12", "Create MotoRent Login test cases using decision table technique", "F12")
    set_cell(cover_root, "F19", "Environment for test", "F19")
    set_cell(cover_root, "F20", "Client", "F20")
    set_cell(cover_root, "F21", "Device", "F21")
    set_cell(cover_root, "G21", "Version", "G21")
    set_cell(cover_root, "F22", "PC browser", "F22")
    set_cell(cover_root, "G22", "Windows 10/11, Chrome or Edge", "G22")
    set_cell(cover_root, "F24", "Server", "F29")
    set_cell(cover_root, "F25", "Device", "F30")
    set_cell(cover_root, "G25", "Version", "G30")
    set_cell(cover_root, "F26", "PC", "F31")
    set_cell(cover_root, "G26", "JDK 17, Tomcat 10.1, SQL Server MotoRentDB", "G31")
    replacements[sheets["Cover"]] = tree_bytes(cover_tree)

    report_tree = read_xml_from_xlsx(output, sheets["Test report"])
    report_root = worksheet_root(report_tree)
    clear_range(report_root, "B6", "L22")
    for ref, value in {
        "B5": "1.0",
        "C5": "Login",
        "D5": "3",
        "E5": "3",
        "F5": "Windows/Chrome, Tomcat 10.1, SQL Server MotoRentDB",
        "G5": "0",
        "H5": "0",
        "I5": "30",
        "J5": "0",
        "K5": "30",
        "L5": "30",
        "C23": "Sub total",
        "D23": "3",
        "E23": "3",
        "G23": "0",
        "H23": "0",
        "I23": "30",
        "J23": "0",
        "K23": "30",
        "L23": "30",
        "C25": "Test coverage",
        "H25": "100",
        "I25": "%",
        "C26": "Test successful coverage",
        "H26": "0",
        "I26": "%",
    }.items():
        set_cell(report_root, ref, value, ref)
    replacements[sheets["Test report"]] = tree_bytes(report_tree)

    login_sheet_target = sheets["Hybrid"]
    login_tree = read_xml_from_xlsx(output, login_sheet_target)
    login_root = worksheet_root(login_tree)
    clear_range(login_root, "A1", "I80")
    remove_merges(login_root, {"B23:B28"})
    set_dimension(login_root, "A1:I34")
    header_values = {
        "A1": "Back to TestReport",
        "B1": "To Buglist",
        "D1": "Pass: 0",
        "E1": "Untested: 30",
        "A2": "Module Code",
        "B2": "Login",
        "D2": "Fail: 0",
        "E2": "N/A: 0",
        "A3": "Tester",
        "B3": "Student",
        "D3": "Percent Complete: 0%",
        "E3": "Number of cases: 30",
        "A4": "ID",
        "B4": "Test Case Description",
        "C4": "Pre -Condition",
        "D4": "Test Case Procedure",
        "E4": "Expected Output",
        "F4": "Bug#",
        "G4": "System test environment",
        "H4": "Test date",
        "I4": "Note",
    }
    for ref, value in header_values.items():
        set_cell(login_root, ref, value, ref)
    environment = "Windows 10/11, Chrome or Edge, Tomcat 10.1, JDK 17, SQL Server MotoRentDB"
    for row_index, case in enumerate(cases, start=5):
        set_cell(login_root, f"A{row_index}", case["id"], "A5")
        set_cell(login_root, f"B{row_index}", case["title"], "B5")
        set_cell(login_root, f"C{row_index}", case["precondition"], "C5")
        set_cell(login_root, f"D{row_index}", case["procedure"], "D5")
        set_cell(login_root, f"E{row_index}", case["expected"], "E5")
        set_cell(login_root, f"F{row_index}", "", "F5")
        set_cell(login_root, f"G{row_index}", environment, "G5")
        set_cell(login_root, f"H{row_index}", "", "H5")
        set_cell(login_root, f"I{row_index}", case["note"], "I5")
    replacements[login_sheet_target] = tree_bytes(login_tree)
    replacements["xl/workbook.xml"] = update_workbook_sheet_name(output, "Hybrid", "Login")
    write_members_to_xlsx(output, replacements)


def main() -> None:
    source_dir = Path(r"C:\Users\ThinkPad\Downloads\01_07_2026___d28c747a-05ce-41b7-b4b1-de35c257bfbd\SWT Lab 3 system test")
    workspace = Path.cwd()
    output_dir = workspace / "lab3_output"
    output_dir.mkdir(exist_ok=True)
    decision_template = source_dir / "Sample_decision_table_test_design.xlsx"
    testcase_template = source_dir / "Sample_Test Cases.xlsx"
    decision_output = output_dir / "MotoRent_Login_Decision_Table_Test_Design.xlsx"
    testcase_output = output_dir / "MotoRent_Login_Test_Cases.xlsx"
    generate_decision_workbook(decision_template, decision_output)
    generate_testcase_workbook(testcase_template, testcase_output)
    print(decision_output)
    print(testcase_output)


if __name__ == "__main__":
    main()
