<!DOCTYPE html>
<html>
<head>
    <title>Laporan Hasil Perhitungan</title>
    <style>
        @page {
            margin: 20px;
        }
        body {
            font-family: sans-serif;
            margin: 0;
        }
        h1, h2, h3 {
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
        thead {
            background-color: #f2f2f2;
        }
        .page-break {
            page-break-after: always;
        }
        .summary-table {
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <h1>Laporan Rinci Hasil Perhitungan</h1>

    @foreach ($detailed_results as $result)
        <h2>Detail Perhitungan: {{ $result['nama'] }}</h2>
        <h3>Hasil Survey & Pemetaan GAP</h3>
        <table>
            <thead>
                <tr>
                    <th>Kriteria</th>
                    <th>Rata-rata Nilai Survey</th>
                    <th>Nilai Target</th>
                    <th>GAP</th>
                    <th>Bobot</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($result['penilaian_detail'] as $penilaian)
                    <tr>
                        <td>{{ $penilaian['kriteria'] }}</td>
                        <td>{{ number_format($penilaian['rata_rata_nilai_survey'], 2) }}</td>
                        <td>{{ $penilaian['nilai_target'] }}</td>
                        <td>{{ number_format($penilaian['gap'], 2) }}</td>
                        <td>{{ $penilaian['bobot'] }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        <h3>Perhitungan Core & Secondary Factor</h3>
        <p><strong>Nilai Core Factor (NCF):</strong> {{ number_format($result['ncf'], 2) }}</p>
        <p><strong>Nilai Secondary Factor (NSF):</strong> {{ number_format($result['nsf'], 2) }}</p>
        <p><strong>Nilai Total:</strong> {{ number_format($result['total'], 2) }}</p>

        @if (!$loop->last)
            <div class="page-break"></div>
        @endif
    @endforeach
    
    <div class="page-break"></div>

    <div class="summary-table">
        <h1>Tabel Perankingan</h1>
        <table>
            <thead>
                <tr>
                    <th>Ranking</th>
                    <th>Nama Kandidat</th>
                    <th>Nilai Core Factor (NCF)</th>
                    <th>Nilai Secondary Factor (NSF)</th>
                    <th>Nilai Total</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($perhitungans as $perhitungan)
                    <tr>
                        <td>{{ $perhitungan->ranking }}</td>
                        <td>{{ $perhitungan->kandidat->nama }}</td>
                        <td>{{ number_format($perhitungan->ncf, 2) }}</td>
                        <td>{{ number_format($perhitungan->nsf, 2) }}</td>
                        <td>{{ number_format($perhitungan->nilai_total, 2) }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</body>
</html>
