
<?php

return [
    'paths' => ['api/*'],

    'allowed_methods' => ['GET', 'POST', 'OPTIONS'],

    'allowed_origins' => array_values(array_filter(array_unique([
        env('FRONTEND_ORIGIN', 'http://localhost:3000'),

        env('APP_ENV', 'production') === 'local'
            ? 'http://127.0.0.1:3000'
            : null,
    ]))),

    'allowed_origins_patterns' => [],

    'allowed_headers' => [
        'Accept',
        'Authorization',
        'Content-Type',
        'X-Requested-With',
    ],

    'exposed_headers' => [],

    'max_age' => 600,

    'supports_credentials' => false,
];
