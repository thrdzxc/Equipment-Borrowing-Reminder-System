<?php
namespace App\Http\Controllers\Api;

use Illuminate\Routing\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email', 'max:254'],
            'password' => ['required', 'string', 'max:256'],
        ]);
        $user = User::where('email', $data['email'])->first();
        if (!$user || !Hash::check($data['password'], $user->password)) {
            // A uniform error avoids revealing whether a user exists.
            return response()->json(['message' => 'Invalid credentials'], 401);
        }
        $ttl = max(5, min(120, (int) config('secure_exchange.token_ttl_minutes', 60)));
        // Sanctum stores the token as a SHA-256 hash, not the plaintext bearer token.
        $token = $user->createToken('equiptrack-web', ['*'], now()->addMinutes($ttl))->plainTextToken;
        return response()->json([
            'token' => $token,
            'user' => ['name' => $user->name, 'role' => $user->role],
            'expires_in_minutes' => $ttl,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['message' => 'Logged out']);
    }
}
