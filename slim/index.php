<?php
require 'vendor/autoload.php';

// Create container
$configuration = [
  'settings' => [
    'displayErrorDetails' => true,
  ],
];
$container = new \Slim\Container($configuration);

// Register component on container
$container['view'] = function ($c) {
  $view = new \Slim\Views\Twig('templates', [
    'cache' => 'cache',
    'auto_reload' => true,
  ]);
  $view->addExtension(new \Slim\Views\TwigExtension(
    $c['router'],
    $c['request']->getUri()
  ));

  return $view;
};

// Create and configure Slim app
$app = new \Slim\App($container);

// Render Twig template in route
$app->get('/gallery', function ($request, $response, $args) {
  // Define our testimage data.
  $images = [
    "pete_1" => "https://flic.kr/p/9Yd37s",
    "pete_2" => "https://flic.kr/p/xjFhnR",
    "pete_3" => "https://flic.kr/p/nVP5fh",
    "pete_4" => "https://flic.kr/p/vvC6hq"
  ];

  return $this->view->render($response, 'gallery.html', [
    'images' => $images,
  ]);

})->setName('gallery');

// Run app
$app->run();