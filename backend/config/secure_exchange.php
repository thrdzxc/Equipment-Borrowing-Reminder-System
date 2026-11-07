<?php
return [
    // Local HTTP is permitted for a demonstration only. Hosted staging/production
    // rejects HTTP independently of this setting (see SecureApiTransport).
    'require_https' => (bool) env('SECURE_REQUIRE_HTTPS', false),
    'token_ttl_minutes' => (int) env('TOKEN_TTL_MINUTES', 60),
];
