<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }} - Survey</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans antialiased bg-gray-100">
        <div class="min-h-screen flex flex-col sm:justify-center items-center pt-6 sm:pt-0 bg-gray-100">
            <div class="w-[10vw]">
                <a href="/">
                    <x-application-logo class="w-10 h-10 fill-current text-gray-500" />
                </a>
            </div>

            <div class="w-full sm:max-w-md mt-6 px-6 py-4 bg-white shadow-md overflow-hidden sm:rounded-lg">
                <h2 class="text-xl font-semibold text-gray-800 leading-tight mb-4 text-center">
                    Form Survey untuk Kandidat: {{ $kandidat->nama }}
                </h2>

                @if (session('success'))
                    <div class="mb-4 font-medium text-sm text-green-600">
                        {{ session('success') }}
                    </div>
                @endif

                <form action="{{ route('public.survey.store', $kandidat) }}" method="POST">
                    @csrf
                    <input type="hidden" name="kandidat_id" value="{{ $kandidat->id }}">

                    <div class="mb-4">
                        <label for="surveyor_name" class="block text-sm font-medium text-gray-700">Nama Penilai (Opsional)</label>
                        <input type="text" name="surveyor_name" id="surveyor_name" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                    </div>
                    
                    @foreach ($kriterias as $kriteria)
                        <div class="mb-4">
                            <label for="penilaian_{{ $kriteria->id }}" class="block text-sm font-medium text-gray-700">{{ $kriteria->nama_kriteria }}</label>
                            <input type="hidden" name="penilaian[{{ $loop->index }}][kriteria_id]" value="{{ $kriteria->id }}">
                            <select name="penilaian[{{ $loop->index }}][nilai]" id="penilaian_{{ $kriteria->id }}" class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                                @foreach ($kriteria->subKriterias as $subKriteria)
                                    <option value="{{ $subKriteria->nilai }}">{{ $subKriteria->keterangan }}</option>
                                @endforeach
                            </select>
                        </div>
                    @endforeach

                    <div class="flex items-center justify-end mt-4">
                        <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                            Kirim Penilaian
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>
