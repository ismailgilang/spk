<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Show Kandidat') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <div class="mb-4">
                        @if ($kandidat->foto)
                            <img src="{{ asset('storage/' . $kandidat->foto) }}" alt="Foto" class="h-40 mb-4">
                        @endif
                        <p><strong>NIP:</strong> {{ $kandidat->nip }}</p>
                        <p><strong>Nama:</strong> {{ $kandidat->nama }}</p>
                        <p><strong>Jenis Kelamin:</strong> {{ $kandidat->jenis_kelamin == 'L' ? 'Laki-laki' : 'Perempuan' }}</p>
                        <p><strong>Pendidikan Terakhir:</strong> {{ $kandidat->pendidikan_terakhir }}</p>
                        <p><strong>Pengalaman Mengajar:</strong> {{ $kandidat->pengalaman_mengajar }} tahun</p>
                        <p><strong>Alamat:</strong> {{ $kandidat->alamat }}</p>
                        <p><strong>No. Telepon:</strong> {{ $kandidat->no_telp }}</p>
                    </div>
                    <a href="{{ route('kandidat.index') }}" class="text-indigo-600 hover:text-indigo-900">Back to list</a>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
