"""Check bundled app assets and 16 KB ELF alignment for 64-bit libraries."""
from pathlib import Path
import struct
import zipfile

bundle = Path(__file__).resolve().parents[1] / (
    'build/app/outputs/bundle/release/app-release.aab'
)
with zipfile.ZipFile(bundle) as archive:
    names = archive.namelist()
    for asset in (
        'base/assets/flutter_assets/assets/branding/logo.png',
        'base/assets/flutter_assets/assets/fonts/NanumMyeongjo-Regular.ttf',
        'base/assets/flutter_assets/assets/fonts/OFL.txt',
    ):
        assert asset in names, f'Missing asset: {asset}'
    assert any(n.startswith('META-INF/') and n.endswith('.RSA') for n in names), (
        'Bundle is not signed'
    )
    for name in names:
        if not name.endswith('.so') or not any(
            abi in name for abi in ('arm64-v8a/', 'x86_64/')
        ):
            continue
        data = archive.read(name)
        assert data[:5] == b'\x7fELF\x02', f'Expected ELF64: {name}'
        endian = '<' if data[5] == 1 else '>'
        offset = struct.unpack_from(endian + 'Q', data, 32)[0]
        size, count = struct.unpack_from(endian + 'HH', data, 54)
        alignments = []
        for index in range(count):
            fields = struct.unpack_from(endian + 'IIQQQQQQ', data, offset + index * size)
            if fields[0] == 1:  # PT_LOAD
                alignment = fields[7]
                assert alignment >= 16384, f'Unaligned library: {name}: {alignment}'
                alignments.append(alignment)
        print(f'{name}: PT_LOAD alignment {alignments}')
print(f'Assets, signature presence and ELF alignment OK: {bundle.stat().st_size:,} bytes')
