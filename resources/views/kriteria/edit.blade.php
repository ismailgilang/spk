<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Edit Kriteria') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <form action="{{ route('kriteria.update', ['kriterium' => $kriterium]) }}" method="POST">
                        @csrf
                        @method('PUT')
                        <div class="mb-4">
                            <label for="kode_kriteria" class="block text-sm font-medium text-gray-700">Kode Kriteria</label>
                            <input type="text" name="kode_kriteria" id="kode_kriteria" value="{{ $kriterium->kode_kriteria }}" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                        </div>
                        <div class="mb-4">
                            <label for="nama_kriteria" class="block text-sm font-medium text-gray-700">Nama Kriteria</label>
                            <input type="text" name="nama_kriteria" id="nama_kriteria" value="{{ $kriterium->nama_kriteria }}" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                        </div>
                        <div class="mb-4">
                            <label for="tipe" class="block text-sm font-medium text-gray-700">Tipe</label>
                            <select name="tipe" id="tipe" class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                                <option value="core_factor" @if($kriterium->tipe == 'core_factor') selected @endif>Core Factor</option>
                                <option value="secondary_factor" @if($kriterium->tipe == 'secondary_factor') selected @endif>Secondary Factor</option>
                            </select>
                        </div>
                        <div class="mb-4">
                            <label for="bobot" class="block text-sm font-medium text-gray-700">Bobot</label>
                            <input type="number" name="bobot" id="bobot" step="0.01" value="{{ $kriterium->bobot }}" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                        </div>
                        <div class="mb-4">
                            <label for="nilai_target" class="block text-sm font-medium text-gray-700">Nilai Target</label>
                            <input type="number" name="nilai_target" id="nilai_target" value="{{ $kriterium->nilai_target }}" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                        </div>
                        <div class="mb-4">
                            <label for="keterangan" class="block text-sm font-medium text-gray-700">Keterangan</label>
                            <textarea name="keterangan" id="keterangan" rows="3" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">{{ $kriterium->keterangan }}</textarea>
                        </div>
                        <div>
                            <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                                Update
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
