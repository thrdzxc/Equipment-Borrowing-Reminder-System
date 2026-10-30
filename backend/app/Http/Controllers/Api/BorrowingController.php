<?php
namespace App\Http\Controllers\Api;
use App\Models\Borrowing;
use App\Models\Equipment;
use Illuminate\Routing\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
class BorrowingController extends Controller {
 public function index(){ return Borrowing::with('equipment:id,name,asset_tag')->orderByDesc('id')->limit(100)->get(); }
 public function store(Request $request){
  $data=$request->validate([
   'equipment_id'=>['required','integer','exists:equipment,id'],
   'borrower_name'=>['required','string','max:100'],
   'due_at'=>['required','date','after:now'],
  ]);
  $loan=DB::transaction(function () use ($data) {
   $item=Equipment::whereKey($data['equipment_id'])->lockForUpdate()->firstOrFail();
   // Conditional update protects stock even when concurrent transactions race.
   $updated=Equipment::whereKey($item->id)->where('quantity_available','>',0)->decrement('quantity_available');
   if(!$updated){throw ValidationException::withMessages(['equipment_id'=>'No units available.']);}
   return Borrowing::create([
    'equipment_id'=>$item->id,'borrower_name'=>$data['borrower_name'],
    'borrowed_at'=>now(),'due_at'=>$data['due_at'],
    'status'=>'active','reminder_status'=>'pending','reminder_attempts'=>0,
   ]);
  });
  return response()->json($loan->load('equipment:id,name,asset_tag'),201);
 }
 public function returnItem(Borrowing $borrowing){
  return DB::transaction(function () use($borrowing){
   $loan=Borrowing::whereKey($borrowing->id)->lockForUpdate()->firstOrFail();
   if($loan->status==='returned'){return response()->json(['message'=>'Already returned'],409);}
   $loan->update(['status'=>'returned','returned_at'=>now()]);
   Equipment::whereKey($loan->equipment_id)->increment('quantity_available');
   return response()->json($loan->load('equipment:id,name,asset_tag'));
  });
 }
 public function resetReminder(Borrowing $borrowing){
  if($borrowing->status!=='active' || $borrowing->reminder_status!=='needs_review'){
   return response()->json(['message'=>'Only active loans needing review can be reset'],409);
  }
  $borrowing->update(['reminder_status'=>'pending','reminder_attempts'=>0,'last_error_code'=>null,'next_attempt_at'=>null]);
  return response()->json($borrowing->refresh());
 }
}
