<?php
require 'vendor/autoload.php';

// Create container
$container = new \Slim\Container;

// Register component on container
$container['view'] = function ($c) {
  $view = new \Slim\Views\Twig('templates', [
    'cache' => 'cache'
  ]);
  $view->addExtension(new \Slim\Views\TwigExtension(
    $c['router'],
    $c['request']->getUri()
  ));

  return $view;
};

// Create and configure Slim app
$app = new \Slim\App;

// Define app routes
$app->get('/gallery', function ($request, $response, $args) {
  return $response->write("Hello ");
});

// Run app
$app->run();