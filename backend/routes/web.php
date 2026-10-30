<?php
use Illuminate\Support\Facades\Route;
Route::get('/', fn () => response()->json(['message' => 'Equipment Borrowing Reminder API','api' => '/api/health']));
