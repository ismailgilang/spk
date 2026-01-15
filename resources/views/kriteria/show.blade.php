<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Show Kriteria') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <div class="mb-4">
                        <p><strong>Kode:</strong> {{ $kriterium->kode_kriteria }}</p>
                        <p><strong>Nama:</strong> {{ $kriterium->nama_kriteria }}</p>
                        <p><strong>Tipe:</strong> {{ $kriterium->tipe }}</p>
                        <p><strong>Bobot:</strong> {{ $kriterium->bobot }}</p>
                        <p><strong>Nilai Target:</strong> {{ $kriterium->nilai_target }}</p>
                        <p><strong>Keterangan:</strong> {{ $kriterium->keterangan }}</p>
                    </div>

                    <h3 class="font-semibold text-lg text-gray-800 leading-tight mt-6">
                        Sub Kriteria
                    </h3>

                    <div class="mt-4">
                        <form action="{{ route('sub-kriteria.store') }}" method="POST">
                            @csrf
                            <input type="hidden" name="kriteria_id" value="{{ $kriterium->id }}">
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div>
                                    <label for="nilai" class="block text-sm font-medium text-gray-700">Nilai</label>
                                    <input type="number" name="nilai" id="nilai" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                                </div>
                                <div>
                                    <label for="keterangan" class="block text-sm font-medium text-gray-700">Keterangan</label>
                                    <input type="text" name="keterangan" id="keterangan" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md">
                                </div>
                                <div>
                                    <button type="submit" class="inline-flex items-center px-4 py-2 bg-blue-500 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 active:bg-blue-900 focus:outline-none focus:border-blue-900 focus:ring ring-blue-300 disabled:opacity-25 transition ease-in-out duration-150 mt-6">
                                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                                        Add Sub Kriteria
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>

                    <table class="min-w-full divide-y divide-gray-200 mt-6">
                        <thead class="bg-gray-50">
                            <tr>
                                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                    Nilai
                                </th>
                                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                    Keterangan
                                </th>
                                <th scope="col" class="relative px-6 py-3">
                                    <span class="sr-only">Actions</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            @foreach ($kriterium->subKriterias as $subKriteria)
                                <tr>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        {{ $subKriteria->nilai }}
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        {{ $subKriteria->keterangan }}
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <form action="{{ route('sub-kriteria.destroy', $subKriteria) }}" method="POST" class="inline-flex">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="inline-flex items-center p-2 border border-transparent rounded-full text-red-600 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2" aria-label="Delete Sub Kriteria">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>

                </div>
            </div>
        </div>
    </div>
</x-app-layout>
