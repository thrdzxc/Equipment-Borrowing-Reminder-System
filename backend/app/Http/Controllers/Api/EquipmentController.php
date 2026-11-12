<?php
namespace App\Http\Controllers\Api;

use App\Models\Equipment;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class EquipmentController extends Controller
{
    public function index()
    {
        // W15-H01: expose only the fields needed by the inventory interface.
        // Database timestamps and internal model fields are not part of the public API.
        return Equipment::query()
            ->select('id', 'asset_tag', 'name', 'category', 'quantity_total', 'quantity_available')
            ->orderBy('name')
            ->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'asset_tag' => ['required', 'string', 'max:40', 'alpha_dash', 'unique:equipment,asset_tag'],
            'name' => ['required', 'string', 'max:100'],
            'category' => ['required', 'string', 'max:70'],
            'quantity_total' => ['required', 'integer', 'min:1', 'max:1000'],
        ]);
        $data['quantity_available'] = $data['quantity_total'];
        return response()->json(Equipment::create($data), 201);
    }
}
