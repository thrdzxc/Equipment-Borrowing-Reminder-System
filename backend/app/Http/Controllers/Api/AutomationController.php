<?php
namespace App\Http\Controllers\Api;
use App\Models\Borrowing;
use App\Models\Equipment;
use App\Models\AutomationEvent;
use App\Services\ReminderRunner;
use Illuminate\Routing\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
class AutomationController extends Controller {
 public function dashboard(){return response()->json([
   'equipment_types'=>Equipment::count(),
   'available_units'=>Equipment::sum('quantity_available'),
   'active_borrowings'=>Borrowing::where('status','active')->count(),
   'due_soon'=>Borrowing::where('status','active')->where('due_at','<=',now()->addHours(48))->where('due_at','>=',now())->count(),
   'needs_review'=>Borrowing::where('reminder_status','needs_review')->where('status','active')->count(),
   'delivery'=>'simulated_only',
 ]);}
 public function events(){return AutomationEvent::orderByDesc('id')->limit(100)->get();}
 public function run(Request $request,ReminderRunner $runner){
  $data=$request->validate(['mode'=>['nullable',Rule::in(['success','transient_once','transient_always','permanent_failure'])]]);
  if(!app()->environment(['local','testing']) && array_key_exists('mode',$data)){
   return response()->json(['message'=>'Simulation mode override is local-only'],403);
  }
  $result=$runner->run($data['mode']??'success');
  return response()->json($result,(($result['status']??null)==='busy' ? 409 : 200));
 }
}
