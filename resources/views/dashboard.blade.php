<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Dashboard') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <h3 class="text-lg font-medium text-gray-900 mb-4">Statistik</h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <!-- Card Jumlah Kandidat -->
                        <div class="bg-blue-100 p-6 rounded-lg shadow-md">
                            <h4 class="text-gray-600 text-sm font-medium">Jumlah Kandidat</h4>
                            <p class="text-3xl font-bold text-gray-900">{{ $jumlahKandidat }}</p>
                        </div>

                        <!-- Card Jumlah Kriteria -->
                        <div class="bg-green-100 p-6 rounded-lg shadow-md">
                            <h4 class="text-gray-600 text-sm font-medium">Jumlah Kriteria</h4>
                            <p class="text-3xl font-bold text-gray-900">{{ $jumlahKriteria }}</p>
                        </div>

                        <!-- Card Jumlah Penilaian -->
                        <div class="bg-yellow-100 p-6 rounded-lg shadow-md">
                            <h4 class="text-gray-600 text-sm font-medium">Data Penilaian</h4>
                            <p class="text-3xl font-bold text-gray-900">{{ $jumlahPenilaian }}</p>
                        </div>
                    </div>

                    <h3 class="text-lg font-medium text-gray-900 mt-8 mb-4">Kandidat Peringkat Teratas</h3>
                    <div class="bg-gray-50 p-6 rounded-lg shadow-md">
                        @if ($topKandidat)
                            <div class="flex items-center">
                                <div class="flex-shrink-0 h-20 w-20">
                                    <img class="h-20 w-20 rounded-full" src="{{ $topKandidat->kandidat->foto ? asset('storage/' . $topKandidat->kandidat->foto) : 'https://ui-avatars.com/api/?name='.urlencode($topKandidat->kandidat->nama).'&color=7F9CF5&background=EBF4FF' }}" alt="Foto Kandidat">
                                </div>
                                <div class="ml-4">
                                    <div class="text-xl font-bold text-gray-900">{{ $topKandidat->kandidat->nama }}</div>
                                    <div class="text-sm text-gray-600">Nilai Total: <span class="font-semibold">{{ number_format($topKandidat->nilai_total, 2) }}</span></div>
                                </div>
                            </div>
                        @else
                            <p class="text-gray-600">Perhitungan belum dilakukan. Silakan lakukan perhitungan pada menu Perhitungan.</p>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
