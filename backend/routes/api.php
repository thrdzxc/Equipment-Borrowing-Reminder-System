<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EquipmentController;
use App\Http\Controllers\Api\BorrowingController;
use App\Http\Controllers\Api\AutomationController;

Route::get('/health', fn () => response()->json(['status'=>'ok','service'=>'equipment-reminder-api','delivery'=>'simulation-only']));
Route::post('/auth/login', [AuthController::class,'login'])->middleware('throttle:5,1');
Route::middleware('auth:sanctum')->group(function () {
 Route::post('/auth/logout',[AuthController::class,'logout']);
 Route::get('/dashboard',[AutomationController::class,'dashboard']);
 Route::get('/equipment',[EquipmentController::class,'index']);
 Route::post('/equipment',[EquipmentController::class,'store']);
 Route::get('/borrowings',[BorrowingController::class,'index']);
 Route::post('/borrowings',[BorrowingController::class,'store']);
 Route::post('/borrowings/{borrowing}/return',[BorrowingController::class,'returnItem']);
 Route::post('/borrowings/{borrowing}/reset-reminder',[BorrowingController::class,'resetReminder']);
 Route::get('/automation/events',[AutomationController::class,'events']);
 Route::post('/automation/run',[AutomationController::class,'run'])->middleware('throttle:10,1');
});
