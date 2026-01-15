<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }} - Terima Kasih</title>

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
                    Terima Kasih!
                </h2>
                <p class="text-gray-600 text-center">
                    Penilaian Anda telah berhasil direkam.
                </p>
                <div class="flex items-center justify-center mt-4">
                    <a href="{{ route('kandidat.index') }}" class="text-sm text-gray-600 hover:text-gray-900">Kembali ke Daftar Kandidat (Admin Only)</a>
                </div>
            </div>
        </div>
    </body>
</html>
