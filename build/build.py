# -*- coding: utf-8 -*-
"""
판서노트 빌드 스크립트

  app.template.html  (사람이 읽고 고치는 원본)
      +  lib/*       (PDF.js, jsPDF, 한글 글자표, 기본 글꼴)
      =  index.html  (전자칠판에서 실행되는 파일 하나)

쓰는 법:  python3 build.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
LIB = HERE / 'lib'
OUT = HERE / 'index.html'

SLOTS = [
    ('/*__PDFJS__*/',      'pdfjs.js'),
    ('/*__PDFWORKER__*/',  'pdfworker.js'),
    ('/*__JSPDF__*/',      'jspdf.js'),
    ('{"__CMAPS__":1}',    'cmaps.json'),
    ('{"__FONTS__":1}',    'fonts.json'),
]


def main():
    html = (HERE / 'app.template.html').read_text(encoding='utf-8')

    for mark, name in SLOTS:
        n = html.count(mark)
        if n != 1:
            raise SystemExit(f'표식 {mark} 이 {n}번 나옵니다 — 1번이어야 합니다')
        body = (LIB / name).read_text(encoding='utf-8')
        html = html.replace(mark, body)
        print(f'  {mark:22s} <- lib/{name}  ({len(body):,}자)')

    if '__' in html and any(m.strip('/*{}":1') in html for m, _ in SLOTS):
        raise SystemExit('채우지 못한 표식이 남아 있습니다')

    OUT.write_text(html, encoding='utf-8')
    print(f'\nindex.html 만들었습니다 — {OUT.stat().st_size:,} 바이트')

    ver = ''
    for line in html.split('\n'):
        if "APP_VER='" in line:
            ver = line.split("APP_VER='")[1].split("'")[0]
            break
    print(f'버전 {ver}')
    print('\n다음 할 일')
    print('  1) sw.js 의 CACHE 를 panseo-note-%s 로 맞추세요' % (ver or 'X.X'))
    print('  2) version.json 을 {"version":"%s"} 로 맞추세요' % (ver or 'X.X'))
    print('  3) index.html 을 판서노트.html 로도 복사해 두세요 (USB용)')


if __name__ == '__main__':
    main()
