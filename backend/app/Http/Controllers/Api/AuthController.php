<?php
namespace App\Http\Controllers\Api;
use Illuminate\Routing\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
class AuthController extends Controller {
 public function login(Request $request) {
  $data=$request->validate(['email'=>['required','email'],'password'=>['required','string']]);
   $user=User::where('email',$data['email'])->first();
  if(!$user || !Hash::check($data['password'],$user->password)) {return response()->json(['message'=>'Invalid credentials'],401);}
  $token=$user->createToken('flutter-web-session',['*'],now()->addHours(2))->plainTextToken;
  return response()->json(['token'=>$token,'user'=>['name'=>$user->name,'email'=>$user->email],'expires_in_minutes'=>120]);
 }
 public function logout(Request $request) {
  $request->user()->currentAccessToken()?->delete();
  return response()->json(['message'=>'Logged out']);
 }
}
